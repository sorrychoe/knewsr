#' Collect news from the Naver News Search API
#'
#' Searches Naver News through the official Open API and returns the results
#' in the standard news schema. The API returns headlines, a short summary
#' (`text`), the publication time and links, but not full article bodies.
#' `source` is the domain of the original article link.
#'
#' Register an application at <https://developers.naver.com/main/> to get a client
#' id and secret, and store them as the environment variables
#' `NAVER_CLIENT_ID` and `NAVER_CLIENT_SECRET` (e.g. in `.Renviron`) rather
#' than in scripts. The API returns at most 1,000 results per query and
#' allows 25,000 calls per day.
#'
#' @param query Search query.
#' @param n Number of articles to collect (at most 1,000).
#' @param sort `"date"` for newest first, `"sim"` for relevance.
#' @param client_id,client_secret Naver Open API credentials.
#'
#' @return A tibble in the standard news schema with the extra columns
#'   `query`, `originallink` and `link`.
#' @examples
#' \dontrun{
#' news <- collect_naver("\uae30\uc900\uae08\ub9ac", n = 300)
#' tokenize_ko(news, field = "text")
#' }
#' @export
collect_naver <- function(query, n = 100, sort = c("date", "sim"),
                          client_id = Sys.getenv("NAVER_CLIENT_ID"),
                          client_secret = Sys.getenv("NAVER_CLIENT_SECRET")) {
  rlang::check_installed("httr2", reason = "to call the Naver API.")
  stopifnot(is.character(query), length(query) == 1, nzchar(query))
  stopifnot(is.numeric(n), length(n) == 1, n >= 1)
  sort <- rlang::arg_match(sort)
  if (!nzchar(client_id) || !nzchar(client_secret)) {
    rlang::abort(c(
      "Naver API credentials are missing.",
      i = "Set NAVER_CLIENT_ID and NAVER_CLIENT_SECRET, e.g. with `usethis::edit_r_environ()`."
    ))
  }
  n <- min(n, 1000)

  pages <- list()
  for (start in seq(1, n, by = 100)) {
    display <- min(100, n - start + 1)
    resp <- httr2::request("https://openapi.naver.com/v1/search/news.json") |>
      httr2::req_url_query(query = query, display = display, start = start, sort = sort) |>
      httr2::req_headers(`X-Naver-Client-Id` = client_id,
                         `X-Naver-Client-Secret` = client_secret,
                         .redact = c("X-Naver-Client-Id", "X-Naver-Client-Secret")) |>
      httr2::req_error(body = function(resp) httr2::resp_body_json(resp)$errorMessage) |>
      httr2::req_retry(max_tries = 3) |>
      httr2::req_perform()
    items <- httr2::resp_body_json(resp, simplifyVector = TRUE)$items
    if (!is.data.frame(items) || !nrow(items)) break
    pages[[length(pages) + 1]] <- items
    if (nrow(items) < display) break
  }
  if (!length(pages)) {
    rlang::abort(paste0("No Naver News results for \"", query, "\"."))
  }

  items <- dplyr::bind_rows(pages)
  link <- ifelse(nzchar(items$originallink), items$originallink, items$link)
  df <- tibble::tibble(
    id = link,
    title = strip_html(items$title),
    text = strip_html(items$description),
    date = items$pubDate,
    source = url_domain(link),
    query = query,
    originallink = items$originallink,
    link = items$link
  )
  as_news(df, id = "id", title = "title", text = "text", date = "date",
          source = "source", keyword = NA, dedup = TRUE, quiet = TRUE)
}

#' Collect news from RSS or Atom feeds
#'
#' Reads RSS 2.0 or Atom feeds, from URLs or local files, and returns their
#' items in the standard news schema. `text` is the full content
#' (`content:encoded`) when the feed provides it, otherwise the summary.
#' `source` is the feed title. HTML tags are removed.
#'
#' @param url One or more feed URLs or file paths.
#'
#' @return A tibble in the standard news schema with the extra columns
#'   `feed` (the feed URL) and `link`. Items that appear in several feeds are
#'   kept once.
#' @examples
#' # a trimmed Yonhap News feed (titles and links only)
#' feed <- system.file("extdata", "sample_rss.xml", package = "knewsr")
#' collect_rss(feed)
#' @export
collect_rss <- function(url) {
  rlang::check_installed("xml2", reason = "to read RSS feeds.")
  stopifnot(is.character(url), length(url) >= 1)
  items <- dplyr::bind_rows(lapply(url, read_feed))
  if (!nrow(items)) rlang::abort("The feed(s) contain no items.")
  as_news(items, id = "id", title = "title", text = "text", date = "date",
          source = "source", keyword = NA, dedup = TRUE, quiet = TRUE)
}

read_feed <- function(url) {
  doc <- xml2::read_xml(url)
  node <- function(x, names) {
    xp <- paste0("./*[", paste0("local-name()='", names, "'", collapse = " or "), "]")
    xml2::xml_find_first(x, xp)
  }
  first_text <- function(x, ...) {
    for (nm in c(...)) {
      v <- xml2::xml_text(node(x, nm))
      if (!is.na(v) && nzchar(trimws(v))) return(v)
    }
    NA_character_
  }

  items <- xml2::xml_find_all(doc, "//*[local-name()='item' or local-name()='entry']")
  feed_title <- xml2::xml_text(xml2::xml_find_first(
    doc, "/*/*[local-name()='title'] | /*/*[local-name()='channel']/*[local-name()='title']"
  ))
  rows <- lapply(items, function(it) {
    link_node <- node(it, "link")
    link <- xml2::xml_attr(link_node, "href")
    if (is.na(link)) link <- xml2::xml_text(link_node)
    list(
      id = if (is.na(id <- first_text(it, "guid", "id"))) link else id,
      title = first_text(it, "title"),
      text = first_text(it, "encoded", "description", "content", "summary"),
      date = first_text(it, "pubDate", "published", "updated", "date"),
      link = link
    )
  })
  tibble::tibble(
    id = vapply(rows, `[[`, "", "id"),
    title = strip_html(vapply(rows, `[[`, "", "title")),
    text = strip_html(vapply(rows, `[[`, "", "text")),
    date = vapply(rows, `[[`, "", "date"),
    source = rep(trimws(feed_title), length(rows)),
    feed = rep(url, length(rows)),
    link = vapply(rows, `[[`, "", "link")
  )
}

strip_html <- function(x) {
  na <- is.na(x)
  x <- gsub("<[^>]*>", " ", x)
  ents <- c("&quot;" = "\"", "&apos;" = "'", "&#39;" = "'", "&lt;" = "<",
            "&gt;" = ">", "&nbsp;" = " ", "&middot;" = "\u00b7")
  for (e in names(ents)) x <- gsub(e, ents[[e]], x, fixed = TRUE)
  x <- gsub_num_entities(x)
  x <- gsub("&amp;", "&", x, fixed = TRUE) # last, so "&amp;quot;" stays literal
  x <- trimws(gsub("[[:space:]]+", " ", x))
  x[na] <- NA_character_
  x
}

gsub_num_entities <- function(x) {
  m <- gregexpr("&#[0-9]+;", x)
  regmatches(x, m) <- lapply(regmatches(x, m), function(e) {
    vapply(as.integer(gsub("\\D", "", e)), intToUtf8, "")
  })
  x
}

url_domain <- function(url) {
  sub("^www\\.", "", sub("^[a-z]+://([^/:?#]+).*$", "\\1", url, ignore.case = TRUE))
}
