#' Keyness between groups
#'
#' Compares how often each term occurs in a target group versus the rest of
#' the corpus (or a chosen reference group), using a 2 x 2 contingency table
#' per term.
#'
#' The statistic is signed: positive when the term is relatively more
#' frequent in the target, negative when it is more frequent in the
#' reference. `p` comes from a chi-square distribution with one degree of
#' freedom.
#'
#' @inheritParams count_terms
#' @param group Grouping column of `tokens`, e.g. `"source"` (carry it over
#'   with `tokenize_ko(keep = )`).
#' @param target Value of `group` to compare.
#' @param reference Value(s) of `group` to compare against. `NULL` uses every
#'   other group.
#' @param measure `"lr"` for the log-likelihood ratio (G2), `"chi2"` for
#'   Pearson's chi-square (no continuity correction).
#'
#' @return A tibble with `token`, `n_target`, `n_reference`, `keyness` and
#'   `p`, sorted by `keyness`.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#' keyness(tokens, group = "source", target = unique(tokens$source)[1])
#' @export
keyness <- function(tokens, group, target, reference = NULL,
                    measure = c("lr", "chi2")) {
  check_tokens(tokens, group)
  measure <- rlang::arg_match(measure)
  g <- tokens[[group]]
  if (length(target) != 1 || !target %in% g) {
    rlang::abort(paste0("`target` must be one value of `", group, "`."))
  }
  if (is.null(reference)) reference <- setdiff(unique(g), target)
  is_ref <- g %in% reference & g != target
  if (!any(is_ref)) rlang::abort("The reference group has no tokens.")

  in_t <- g == target & !is.na(g)
  terms <- unique(tokens$token[in_t | is_ref])
  a <- as.numeric(tabulate(match(tokens$token[in_t], terms), length(terms)))
  b <- as.numeric(tabulate(match(tokens$token[is_ref], terms), length(terms)))
  a2 <- sum(a) - a # other terms in target
  b2 <- sum(b) - b # other terms in reference

  tot <- a + b + a2 + b2
  e <- function(row, col) row * col / tot
  obs <- list(a, b, a2, b2)
  exp <- list(e(a + b, a + a2), e(a + b, b + b2), e(a2 + b2, a + a2), e(a2 + b2, b + b2))
  stat <- if (measure == "lr") {
    2 * Reduce(`+`, Map(function(o, ex) ifelse(o > 0, o * log(o / ex), 0), obs, exp))
  } else {
    Reduce(`+`, Map(function(o, ex) (o - ex)^2 / ex, obs, exp))
  }
  sign <- ifelse(a / sum(a) >= b / sum(b), 1, -1)

  tibble::tibble(
    token = terms,
    n_target = as.integer(a),
    n_reference = as.integer(b),
    keyness = sign * stat,
    p = stats::pchisq(stat, df = 1, lower.tail = FALSE)
  ) |>
    dplyr::arrange(dplyr::desc(.data$keyness))
}

#' Term trends over time
#'
#' Counts selected terms per day, week (starting Monday) or month. Periods
#' with no occurrence of a term get `n = 0`.
#'
#' @inheritParams count_terms
#' @param news The news tibble the tokens came from, used for the dates.
#' @param terms Terms to follow.
#' @param unit `"day"`, `"week"` or `"month"`.
#'
#' @return A tibble with `date` (start of the period), `token` and `n`.
#' @examples
#' news <- as_news(president_lee_2026_08)
#' tokens <- tokenize_ko(news)
#' term_trend(tokens, news, terms = count_terms(tokens)$token[1:3], unit = "week")
#' @export
term_trend <- function(tokens, news, terms, unit = c("day", "week", "month")) {
  check_tokens(tokens)
  check_news(news)
  stopifnot(is.character(terms), length(terms) >= 1)
  unit <- rlang::arg_match(unit)
  period <- floor_date(news$date, unit)
  periods <- sort(unique(stats::na.omit(period)))
  if (!length(periods)) rlang::abort("`news` has no dates.")

  hits <- tokens[tokens$token %in% terms, c("doc_id", "token")]
  hits$date <- period[match(hits$doc_id, news$doc_id)]
  counts <- dplyr::count(hits[!is.na(hits$date), ], .data$date, .data$token)

  grid <- tibble::tibble(
    date = rep(periods, each = length(terms)),
    token = rep(terms, times = length(periods))
  )
  out <- dplyr::left_join(grid, counts, by = c("date", "token"))
  out$n[is.na(out$n)] <- 0L
  out
}

floor_date <- function(x, unit) {
  switch(unit,
    day = x,
    week = x - (as.integer(format(x, "%u")) - 1L),
    month = as.Date(format(x, "%Y-%m-01"))
  )
}

