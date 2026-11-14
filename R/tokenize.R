#' Tokenize Korean news
#'
#' Turns a news tibble into a long token table with one row per token.
#'
#' With `field = "keyword"` (the default) the comma-separated BigKinds
#' `keyword` column is split, which is fast and needs no morphological
#' analyser. With `field = "text"` or `"title"` the text is analysed with
#' MeCab-ko through the \pkg{RcppMeCab} package, which needs a system MeCab
#' installation and the mecab-ko-dic dictionary.
#'
#' @param news A tibble from [as_news()].
#' @param field Column to tokenize: `"keyword"`, `"text"` or `"title"`.
#' @param pos Part-of-speech tags to keep when analysing text. `"noun"` keeps
#'   common and proper nouns (`NNG`, `NNP`); otherwise a vector of Sejong tags
#'   such as `c("NNG", "NNP", "VV")`. Ignored for `field = "keyword"`.
#' @param stopwords Tokens to drop.
#' @param min_nchar Drop tokens shorter than this many characters.
#' @param keep Columns of `news` (e.g. `"source"`, `"date"`) to carry over to
#'   the token table, for grouped counts and [keyness()].
#' @param dic Path to the mecab-ko-dic system dictionary, passed to
#'   [RcppMeCab::pos()] as `sys_dic`. `""` uses the MeCab default. Set it once
#'   with `options(knewsr.mecab_dic = "...")`.
#'
#' @return A tibble with `doc_id`, the `keep` columns and `token`, in text
#'   order.
#' @examples
#' news <- as_news(president_lee_2026_08)
#' tokenize_ko(news, keep = "source")
#'
#' \dontrun{
#' # needs MeCab-ko and mecab-ko-dic on the system
#' tokenize_ko(news, field = "title")
#' }
#' @export
tokenize_ko <- function(news,
                        field = c("keyword", "text", "title"),
                        pos = "noun",
                        stopwords = stopwords_ko(),
                        min_nchar = 2,
                        keep = NULL,
                        dic = getOption("knewsr.mecab_dic", "")) {
  check_news(news)
  field <- rlang::arg_match(field)
  stopifnot(is.character(pos), is.numeric(min_nchar), length(min_nchar) == 1)
  missing_keep <- setdiff(keep, names(news))
  if (length(missing_keep)) {
    rlang::abort(paste0("Unknown `keep` column(s): ", paste(missing_keep, collapse = ", ")))
  }

  x <- news[[field]]
  x[is.na(x)] <- ""
  if (field == "keyword") {
    toks <- lapply(strsplit(x, ",", fixed = TRUE), trimws)
  } else {
    rlang::check_installed("RcppMeCab", reason = "to analyse Korean text.")
    tags <- if (identical(pos, "noun")) c("NNG", "NNP") else pos
    toks <- lapply(RcppMeCab::pos(x, join = FALSE, sys_dic = dic), function(t) {
      unname(t[sub("\\+.*", "", names(t)) %in% tags])
    })
  }

  lens <- lengths(toks)
  out <- news[rep(seq_len(nrow(news)), lens), c("doc_id", keep), drop = FALSE]
  out$token <- as.character(unlist(toks, use.names = FALSE))
  out[nchar(out$token) >= min_nchar & !out$token %in% stopwords, , drop = FALSE]
}

#' Korean n-grams
#'
#' Builds n-grams from consecutive tokens of each document, after
#' [tokenize_ko()] has filtered parts of speech and stopwords.
#'
#' @inheritParams tokenize_ko
#' @param n Number of tokens per n-gram.
#' @param sep Separator between the tokens of an n-gram.
#' @param ... Passed on to [tokenize_ko()].
#'
#' @return A tibble with `doc_id`, the `keep` columns and `token`, where
#'   `token` holds the n-gram, so it works with every counting function.
#' @examples
#' news <- as_news(president_lee_2026_08)
#' ngrams_ko(news, n = 2, field = "keyword")
#' @export
ngrams_ko <- function(news, n = 2, sep = " ", ...) {
  stopifnot(is.numeric(n), length(n) == 1, n >= 1)
  toks <- tokenize_ko(news, ...)
  grams <- toks |>
    dplyr::mutate(
      token = do.call(paste, c(lapply(seq_len(n) - 1, function(k) dplyr::lead(.data$token, k)),
                               sep = sep)),
      .last = dplyr::lead(.data$doc_id, n - 1) == .data$doc_id
    )
  grams <- grams[!is.na(grams$.last) & grams$.last, , drop = FALSE]
  grams$.last <- NULL
  grams
}
