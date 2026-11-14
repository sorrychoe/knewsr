
.std_cols <- c("doc_id", "date", "source", "title", "text", "keyword")

# Column name candidates for auto-detection, in order of preference.
# Matching is case-insensitive. Korean names are unicode-escaped by the
# escape step so R/ stays ASCII-only.
.col_candidates <- list(
  doc_id  = c("\ub274\uc2a4 \uc2dd\ubcc4\uc790", "doc_id", "id", "article_id", "news_id", "guid"),
  date    = c("\uc77c\uc790", "\ub0a0\uc9dc", "\uc791\uc131\uc77c", "date", "pubdate", "pub_date", "published",
              "published_at", "datetime", "time"),
  source  = c("\uc5b8\ub860\uc0ac", "\ub9e4\uccb4", "source", "press", "media", "publisher", "outlet"),
  title   = c("\uc81c\ubaa9", "title", "headline"),
  text    = c("\ubcf8\ubb38", "\ub0b4\uc6a9", "text", "body", "content", "article", "description", "summary"),
  keyword = c("\ud0a4\uc6cc\ub4dc", "keyword", "keywords", "tags")
)

#' Read news files
#'
#' Reads one or more news files, or every supported file in a directory, and
#' converts them to the standard news schema with [as_news()].
#'
#' Supported formats are `.xlsx`/`.xls`, `.csv`, `.tsv`, `.json` and `.jsonl`
#' (newline-delimited JSON). CSV/TSV files are read as UTF-8 and, if that is
#' not valid, as CP949 (EUC-KR), the usual encoding of Korean Excel exports.
#' A JSON object that wraps the articles (e.g. `{"items": [...]}`) is
#' unwrapped. Each file is mapped to the standard schema on its own, so
#' files with different layouts can be combined; unmapped extra columns become
#' character.
#'
#' @param path File paths or a directory.
#' @param ... Column mapping and options passed on to [as_news()], applied to
#'   each file. With several files, a named column is used in the files that
#'   have it and the others fall back to detection.
#' @param dedup If `TRUE`, drop repeated articles across all files (see
#'   [as_news()]).
#'
#' @return A tibble in the standard news schema.
#' @examples
#' path <- system.file("extdata", "bigkinds_sample.xlsx", package = "knewsr")
#' read_news(path)
#'
#' csv <- tempfile(fileext = ".csv")
#' write.csv(data.frame(headline = "\uc81c\ubaa9", body = "\ubcf8\ubb38\uc785\ub2c8\ub2e4",
#'                      pubDate = "2024.01.02", press = "A\uc77c\ubcf4"),
#'           csv, row.names = FALSE, fileEncoding = "UTF-8")
#' read_news(csv)
#' @export
read_news <- function(path, ..., dedup = FALSE) {
  stopifnot(is.character(path), length(path) >= 1)
  if (length(path) == 1 && dir.exists(path)) {
    path <- list.files(path, pattern = "\\.(xlsx|xls|csv|tsv|json|jsonl)$",
                       full.names = TRUE, ignore.case = TRUE)
    if (!length(path)) rlang::abort("No supported news files in the directory.")
  }
  missing <- path[!file.exists(path)]
  if (length(missing)) rlang::abort(paste0("File not found: ", paste(missing, collapse = ", ")))
  if (length(path) == 1) return(with_file(as_news(read_one(path), ..., dedup = dedup), path))

  # Map each file on its own, so files with different layouts still line up.
  # A column named in `...` is used in the files that have it; the other
  # files fall back to detection. It must exist in at least one file.
  raw <- lapply(path, read_one)
  args <- list(...)
  named <- names(args)[vapply(args, function(a) is.character(a) && length(a) == 1 && !is.na(a), logical(1))]
  named <- intersect(named, c("text", "title", "date", "source", "keyword", "id"))
  for (arg in named) {
    if (!any(vapply(raw, function(d) args[[arg]] %in% names(d), logical(1)))) {
      rlang::abort(paste0("Column `", args[[arg]], "` not found in any file."))
    }
  }
  parts <- Map(function(df, p) {
    file_args <- args
    for (arg in named) if (!args[[arg]] %in% names(df)) file_args[[arg]] <- NULL
    news <- with_file(do.call(as_news, c(list(df), file_args)), p)
    # Row-number ids would collide across files; prefix them with the file.
    if (identical(news$doc_id, as.character(seq_len(nrow(news))))) {
      news$doc_id <- paste0(basename(p), ":", news$doc_id)
    }
    extra <- setdiff(names(news), .std_cols)
    dplyr::mutate(news, dplyr::across(dplyr::all_of(extra), as.character))
  }, raw, path)
  as_news(dplyr::bind_rows(parts), dedup = dedup, quiet = TRUE)
}

# Prefix as_news()'s missing-column warning with the file it came from.
with_file <- function(expr, path) {
  withCallingHandlers(expr, knewsr_missing_columns = function(w) {
    rlang::warn(paste0(basename(path), ": ", conditionMessage(w)), class = "knewsr_missing_columns")
    invokeRestart("muffleWarning")
  })
}

#' @rdname read_news
#' @export
read_bigkinds <- function(path, ...) read_news(path, ...)

read_one <- function(path) {
  ext <- tolower(sub(".*\\.", "", basename(path)))
  if (ext %in% c("json", "jsonl")) rlang::check_installed("jsonlite", reason = "to read JSON files.")
  df <- switch(ext,
    xlsx = , xls = readxl::read_excel(path),
    csv = read_delim_ko(path, ","),
    tsv = read_delim_ko(path, "\t"),
    json = unwrap_json(jsonlite::fromJSON(path, flatten = TRUE)),
    jsonl = jsonlite::stream_in(file(path), verbose = FALSE, flatten = TRUE),
    rlang::abort(paste0("Unsupported file type: .", ext))
  )
  tibble::as_tibble(df, .name_repair = "minimal")
}

read_delim_ko <- function(path, sep) {
  raw <- readLines(path, warn = FALSE, encoding = "bytes")
  enc <- if (all(validUTF8(raw))) "UTF-8-BOM" else "CP949"
  utils::read.table(path, sep = sep, header = TRUE, quote = "\"", comment.char = "",
                    fileEncoding = enc, check.names = FALSE, stringsAsFactors = FALSE,
                    na.strings = c("", "NA"), fill = TRUE)
}

unwrap_json <- function(x) {
  if (is.data.frame(x)) return(x)
  dfs <- Filter(is.data.frame, x)
  if (!length(dfs)) rlang::abort("JSON file does not contain a table of articles.")
  dfs[[1]]
}

#' Convert a data frame to the standard news schema
#'
#' Maps the columns of any news data frame to the standard schema used by
#' every other function: `doc_id` (chr), `date` (Date), `source` (chr),
#' `title` (chr), `text` (chr) and `keyword` (chr, comma-separated). Columns
#' that are not mapped are kept after the standard ones.
#'
#' Columns left as `NULL` are detected by name, case-insensitively, from a
#' list of common names: BigKinds' Korean headers, `title`/`headline`,
#' `text`/`body`/`content`/`description`, `date`/`pubDate`/`published`,
#' `source`/`press`/`media`, `id`/`guid` and others. The chosen mapping is
#' reported in a message. A column you name must exist; `NA` skips a field.
#' At least one of `text` and `keyword` is required.
#'
#' Dates are parsed element by element from `YYYY-MM-DD`, `YYYY.MM.DD`,
#' `YYYY/MM/DD`, `YYYYMMDD`, Korean \ifelse{latex}{YYYY nyeon M wol D il}{YYYY년 M월 D일} and RFC 822
#' (`Mon, 02 Jan 2024 13:05:00 +0900`, as in RSS) forms, with or without a
#' time; the calendar date as written is kept. Values that cannot be parsed
#' become `NA` with a warning.
#'
#' @param df A data frame of news articles, one row per article.
#' @param text,title,date,source,keyword,id Column names in `df`, `NULL` to
#'   detect, or `NA` to leave empty. Without an id column, row numbers are
#'   used.
#' @param keyword_sep Separator used in the keyword column; it is converted to
#'   commas. A list column of keywords is also accepted.
#' @param dedup If `TRUE`, drop repeated articles: rows with the same id, or
#'   the same title, date and source (or text, when there are no titles).
#' @param quiet If `TRUE`, do not report detected columns. A warning is still
#'   raised when `title`, `date` or `source` cannot be detected; pass `NA`
#'   for a field to leave it empty on purpose.

#'
#' @return A tibble in the standard news schema.
#' @examples
#' df <- data.frame(
#'   headline = c("first", "second", "second"),
#'   body = c("first article", "second article", "second article"),
#'   published = c("2024.01.01", "2024\ub144 1\uc6d4 2\uc77c", "2024\ub144 1\uc6d4 2\uc77c"),
#'   media = "A\uc77c\ubcf4"
#' )
#' as_news(df, dedup = TRUE)
#' as_news(df, text = "body", title = NA, quiet = TRUE)
#'
#' as_news(president_lee_2026_08)
#' @export
as_news <- function(df, text = NULL, title = NULL, date = NULL, source = NULL,
                    keyword = NULL, id = NULL, keyword_sep = ",",
                    dedup = FALSE, quiet = FALSE) {
  if (!is.data.frame(df)) rlang::abort("`df` must be a data frame.")
  args <- list(doc_id = id, date = date, source = source,
               title = title, text = text, keyword = keyword)

  cols <- character()
  for (std in names(args)) {
    col <- args[[std]]
    if (is.null(col)) {
      hit <- names(df)[match(tolower(.col_candidates[[std]]), tolower(names(df)))]
      hit <- setdiff(stats::na.omit(hit), cols)
      cols[[std]] <- if (length(hit)) hit[[1]] else NA_character_
    } else if (length(col) == 1 && is.na(col)) {
      cols[[std]] <- NA_character_
    } else {
      if (!is.character(col) || length(col) != 1) rlang::abort(paste0("`", std, "` must be one column name."))
      if (!col %in% names(df)) rlang::abort(paste0("Column `", col, "` not found in `df`."))
      cols[[std]] <- col
    }
  }
  if (is.na(cols[["text"]]) && is.na(cols[["keyword"]])) {
    rlang::abort("`df` needs a text or a keyword column; name it with `text =` or `keyword =`.")
  }

  detected <- names(args)[vapply(args, is.null, logical(1))]
  missing <- intersect(c("title", "date", "source"), detected[is.na(cols[detected])])
  if (length(missing)) {
    rlang::warn(paste0("No column detected for ", paste0("`", missing, "`", collapse = ", "),
                       "; filled with NA. Name it explicitly, or pass NA to silence this."),
                class = "knewsr_missing_columns")
  }
  shown <- cols[detected][!is.na(cols[detected]) & cols[detected] != detected]
  if (!quiet && length(shown)) {
    rlang::inform(paste0("Detected columns: ", paste0(names(shown), " <- `", shown, "`", collapse = ", ")))
  }

  n <- nrow(df)
  pick <- function(std) {
    if (is.na(cols[[std]])) rep(NA_character_, n) else as.character(df[[cols[[std]]]])
  }
  kw <- if (is.na(cols[["keyword"]])) rep(NA_character_, n) else df[[cols[["keyword"]]]]
  out <- tibble::tibble(
    doc_id  = if (is.na(cols[["doc_id"]])) as.character(seq_len(n)) else pick("doc_id"),
    date    = if (is.na(cols[["date"]])) rep(as.Date(NA), n) else parse_date(df[[cols[["date"]]]]),
    source  = pick("source"),
    title   = pick("title"),
    text    = pick("text"),
    keyword = normalize_keywords(kw, keyword_sep)
  )
  rest <- df[, setdiff(names(df), c(stats::na.omit(cols), names(out))), drop = FALSE]
  out <- dplyr::bind_cols(out, tibble::as_tibble(rest, .name_repair = "minimal"))

  if (dedup) {
    key <- if (all(is.na(out$title))) out["text"] else out[c("title", "date", "source")]
    out <- out[!duplicated(out$doc_id) & !duplicated(key), , drop = FALSE]
  }
  if (anyDuplicated(out$doc_id)) {
    rlang::abort("Document ids must be unique; use `dedup = TRUE` to drop repeated articles.")
  }
  out
}

normalize_keywords <- function(x, sep) {
  if (is.list(x)) {
    return(vapply(x, function(k) if (length(k)) paste(trimws(k), collapse = ",") else NA_character_,
                  character(1)))
  }
  x <- as.character(x)
  if (sep != ",") x <- gsub(sep, ",", x, fixed = TRUE)
  x
}

parse_date <- function(x) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, "POSIXt")) return(as.Date(format(x, "%Y-%m-%d")))
  x <- trimws(as.character(x))
  ymd <- matrix(NA_character_, length(x), 3)

  fill <- function(pattern, order) {
    todo <- is.na(ymd[, 1]) & !is.na(x)
    m <- regmatches(x[todo], regexec(pattern, x[todo], perl = TRUE))
    ok <- lengths(m) > 0
    if (any(ok)) ymd[which(todo)[ok], ] <<- do.call(rbind, lapply(m[ok], function(g) g[order + 1]))
  }
  # YYYY-MM-DD, YYYY.MM.DD, YYYY/MM/DD, Korean YYYY년 M월 D일 (+ optional time)
  fill("^(\\d{4})\\s*[-./\ub144]\\s*(\\d{1,2})\\s*[-./\uc6d4]\\s*(\\d{1,2})", 1:3)
  # YYYYMMDD with optional HHMM(SS)
  fill("^(\\d{4})(\\d{2})(\\d{2})(\\d{4,6})?$", 1:3)
  # RFC 822: "Mon, 02 Jan 2024 13:05:00 +0900"
  fill("^(?:[A-Za-z]{3},\\s*)?(\\d{1,2})\\s+([A-Za-z]{3})[A-Za-z]*\\s+(\\d{4})", c(3, 2, 1))
  mon <- match(tolower(ymd[, 2]), tolower(month.abb))
  ymd[!is.na(mon), 2] <- mon[!is.na(mon)]

  out <- as.Date(sprintf("%s-%s-%s", ymd[, 1], ymd[, 2], ymd[, 3]), format = "%Y-%m-%d")
  bad <- is.na(out) & !is.na(x) & x != ""
  if (any(bad)) {
    rlang::warn(paste0(sum(bad), " date value(s) could not be parsed and were set to NA, e.g. \"",
                       x[bad][1], "\"."))
  }
  out
}
