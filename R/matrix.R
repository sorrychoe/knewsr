#' Document-term and term-document matrices
#'
#' Builds a sparse document-term matrix (rows are documents, columns are
#' terms) from a token table. `as_tdm()` returns its transpose.
#'
#' @inheritParams count_terms
#' @param weight `"count"` for raw counts, `"tfidf"` for the TF-IDF weights of
#'   [tf_idf()], `"binary"` for presence (1) or absence.
#' @param ... Passed on to `as_dtm()`.
#'
#' @return A [Matrix::dgCMatrix-class] with document ids and terms as
#'   dimnames. Documents without tokens are not included.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08))
#' dtm <- as_dtm(tokens, weight = "tfidf")
#' dim(dtm)
#' as_tdm(tokens)[1:5, 1:3]
#' @export
as_dtm <- function(tokens, weight = c("count", "tfidf", "binary")) {
  check_tokens(tokens)
  weight <- rlang::arg_match(weight)
  w <- tf_idf(tokens)
  value <- switch(weight, count = w$n, tfidf = w$tf_idf, binary = rep(1, nrow(w)))
  docs <- unique(tokens$doc_id)
  terms <- sort(unique(tokens$token))
  Matrix::sparseMatrix(
    i = match(w$doc_id, docs),
    j = match(w$token, terms),
    x = value,
    dims = c(length(docs), length(terms)),
    dimnames = list(docs, terms)
  )
}

#' @rdname as_dtm
#' @export
as_tdm <- function(tokens, ...) {
  Matrix::t(as_dtm(tokens, ...))
}

#' Term co-occurrence
#'
#' Counts how often pairs of terms appear together, either in the same
#' document or within a sliding window of tokens.
#'
#' @inheritParams count_terms
#' @param window `"doc"` counts the documents in which both terms occur. A
#'   number `w` counts the times two terms occur within `w` tokens of each
#'   other in the same document (in the order of `tokens`).
#' @param top_n Only consider the `top_n` most frequent terms (by document
#'   frequency). `NULL` keeps all terms.
#' @param output `"tibble"` for a pair list or `"matrix"` for a symmetric
#'   sparse term-by-term matrix.
#'
#' @return A tibble with `term1`, `term2` and `n` sorted by `n`, or a
#'   [Matrix::dsCMatrix-class] with a zero diagonal.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08))
#' cooccurrence(tokens, top_n = 30)
#' cooccurrence(tokens, window = 2, top_n = 30)
#' @export
cooccurrence <- function(tokens, window = "doc", top_n = 50,
                         output = c("tibble", "matrix")) {
  check_tokens(tokens)
  output <- rlang::arg_match(output)
  if (!identical(window, "doc") && !(is.numeric(window) && length(window) == 1 && window >= 1)) {
    rlang::abort('`window` must be "doc" or a positive number.')
  }
  if (!is.null(top_n)) {
    keep <- utils::head(count_terms(tokens, by_doc = TRUE)$token, top_n)
  } else {
    keep <- unique(tokens$token)
  }
  terms <- sort(keep)

  if (identical(window, "doc")) {
    b <- as_dtm(tokens[tokens$token %in% terms, ], weight = "binary")
    m <- Matrix::crossprod(b)[terms, terms]
  } else {
    # Pair each token with the tokens up to `window` positions after it,
    # within the same document, before dropping infrequent terms.
    pairs <- lapply(seq_len(window), function(k) {
      same <- dplyr::lead(tokens$doc_id, k) == tokens$doc_id
      data.frame(a = tokens$token, b = dplyr::lead(tokens$token, k))[!is.na(same) & same, ]
    })
    pairs <- do.call(rbind, pairs)
    pairs <- pairs[pairs$a %in% terms & pairs$b %in% terms & pairs$a != pairs$b, ]
    i <- match(pairs$a, terms)
    j <- match(pairs$b, terms)
    m <- Matrix::sparseMatrix(i = pmin(i, j), j = pmax(i, j), x = 1,
                              dims = c(length(terms), length(terms)),
                              dimnames = list(terms, terms))
    m <- m + Matrix::t(m)
  }
  Matrix::diag(m) <- 0
  m <- Matrix::forceSymmetric(Matrix::drop0(m), uplo = "U")
  if (output == "matrix") return(m)

  up <- methods::as(m, "TsparseMatrix") # upper triangle, 0-based indices
  tibble::tibble(term1 = terms[up@i + 1], term2 = terms[up@j + 1], n = up@x) |>
    dplyr::arrange(dplyr::desc(.data$n))
}
