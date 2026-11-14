#' Count terms
#'
#' Term frequencies, or document frequencies with `by_doc = TRUE`, overall or
#' per group.
#'
#' @param tokens A token table from [tokenize_ko()] (`doc_id`, `token`).
#' @param by Optional grouping columns of `tokens`, e.g. `"source"`.
#' @param by_doc If `TRUE`, count each term at most once per document, giving
#'   the number of documents that contain it.
#'
#' @return A tibble with the `by` columns, `token` and `n`, sorted by `n`.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#' count_terms(tokens)
#' count_terms(tokens, by = "source", by_doc = TRUE)
#' @export
count_terms <- function(tokens, by = NULL, by_doc = FALSE) {
  check_tokens(tokens, by)
  if (by_doc) tokens <- dplyr::distinct(tokens, dplyr::across(dplyr::all_of(c("doc_id", by, "token"))))
  tokens |>
    dplyr::count(dplyr::across(dplyr::all_of(c(by, "token"))), sort = TRUE) |>
    tibble::as_tibble()
}

#' TF-IDF
#'
#' Term frequency-inverse document frequency of every term in every
#' document, or in every group when `by` names a grouping column (each group
#' is then treated as one document).
#'
#' `tf` is the term count divided by the total count in the document and
#' `idf` is `log(number of documents / documents containing the term)`.
#'
#' @inheritParams count_terms
#' @param by Column that defines a document. Defaults to `"doc_id"`.
#'
#' @return A tibble with `by`, `token`, `n`, `tf`, `idf` and `tf_idf`,
#'   sorted by `tf_idf`.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#' tf_idf(tokens)
#' tf_idf(tokens, by = "source")
#' @export
tf_idf <- function(tokens, by = "doc_id") {
  check_tokens(tokens, by)
  stopifnot(length(by) == 1)
  n_docs <- dplyr::n_distinct(tokens[[by]])
  tokens |>
    dplyr::count(dplyr::across(dplyr::all_of(c(by, "token")))) |>
    dplyr::mutate(tf = .data$n / sum(.data$n), .by = dplyr::all_of(by)) |>
    dplyr::mutate(idf = log(n_docs / dplyr::n()), .by = "token") |>
    dplyr::mutate(tf_idf = .data$tf * .data$idf) |>
    dplyr::arrange(dplyr::desc(.data$tf_idf)) |>
    tibble::as_tibble()
}

#' Summarise a news corpus
#'
#' Number of articles and the first and last publication date, overall or
#' per group. Replaces counting articles per outlet and checking the date
#' range by hand.
#'
#' @param news A tibble from [as_news()].
#' @param by Optional grouping columns, e.g. `"source"`.
#'
#' @return A tibble with the `by` columns, `n`, `first_date` and `last_date`,
#'   sorted by `n`.
#' @examples
#' news <- as_news(president_lee_2026_08)
#' summarise_corpus(news)
#' summarise_corpus(news, by = "source")
#' @export
summarise_corpus <- function(news, by = NULL) {
  check_news(news)
  check_cols(news, by, "news")
  news |>
    dplyr::summarise(
      n = dplyr::n(),
      first_date = safe_range(.data$date, min),
      last_date = safe_range(.data$date, max),
      .by = dplyr::all_of(by)
    ) |>
    dplyr::arrange(dplyr::desc(.data$n)) |>
    tibble::as_tibble()
}

check_tokens <- function(tokens, by = NULL) {
  if (!is.data.frame(tokens) || !all(c("doc_id", "token") %in% names(tokens))) {
    rlang::abort("`tokens` must be a token table; create one with `tokenize_ko()`.")
  }
  check_cols(tokens, by, "tokens")
}

check_cols <- function(df, cols, what) {
  bad <- setdiff(cols, names(df))
  if (length(bad)) {
    rlang::abort(paste0("Column(s) not found in `", what, "`: ", paste(bad, collapse = ", ")))
  }
}

safe_range <- function(x, f) if (all(is.na(x))) x[NA_integer_][1] else f(x, na.rm = TRUE)
