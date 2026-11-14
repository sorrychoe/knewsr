#' Plot helpers
#'
#' Thin wrappers that return \pkg{ggplot2} objects, so you can add themes,
#' labels or Korean fonts (e.g. `+ ggplot2::theme(text = ggplot2::element_text(family = "NanumGothic"))`).
#' They do no computation beyond picking the top rows.
#'
#' * `plot_terms()`: horizontal bar chart of [count_terms()] or [tf_idf()]
#'   output.
#' * `plot_keyness()`: the most distinctive terms on each side of
#'   [keyness()].
#' * `plot_trend()`: lines of [term_trend()] output.
#' * `plot_wordcloud()`: word cloud via \pkg{ggwordcloud}.
#' * `plot_network()`: co-occurrence network of [cooccurrence()] output via
#'   \pkg{ggraph} and \pkg{igraph}.
#'
#' @param counts Output of [count_terms()] or [tf_idf()].
#' @param k Output of [keyness()].
#' @param trend Output of [term_trend()].
#' @param cooc Output of [cooccurrence()] with `output = "tibble"`.
#' @param top_n Number of terms (or, for `plot_network()`, edges) to show.
#' @param value Column of `counts` that sizes the bars or words.
#'
#' @return A ggplot object.
#' @examples
#' tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   p1 <- plot_terms(count_terms(tokens), top_n = 10)
#'   p2 <- plot_keyness(keyness(tokens, "source", unique(tokens$source)[1]))
#'   # print(p1) to draw; set a Korean font if Hangul shows as boxes
#' }
#' @name plot_helpers
NULL

#' @rdname plot_helpers
#' @export
plot_terms <- function(counts, top_n = 25, value = "n") {
  need_ggplot()
  check_cols(counts, c("token", value), "counts")
  d <- utils::head(counts[order(-counts[[value]]), ], top_n)
  d$token <- stats::reorder(d$token, d[[value]])
  ggplot2::ggplot(d, ggplot2::aes(x = .data[[value]], y = .data$token)) +
    ggplot2::geom_col() +
    ggplot2::labs(x = value, y = NULL)
}

#' @rdname plot_helpers
#' @export
plot_keyness <- function(k, top_n = 20) {
  need_ggplot()
  check_cols(k, c("token", "keyness"), "k")
  k <- k[order(-k$keyness), ]
  d <- unique(rbind(utils::head(k, top_n), utils::tail(k, top_n)))
  d$side <- ifelse(d$keyness >= 0, "target", "reference")
  d$token <- stats::reorder(d$token, d$keyness)
  ggplot2::ggplot(d, ggplot2::aes(x = .data$keyness, y = .data$token, fill = .data$side)) +
    ggplot2::geom_col() +
    ggplot2::labs(x = "keyness", y = NULL, fill = NULL)
}

#' @rdname plot_helpers
#' @export
plot_trend <- function(trend) {
  need_ggplot()
  check_cols(trend, c("date", "token", "n"), "trend")
  ggplot2::ggplot(trend, ggplot2::aes(x = .data$date, y = .data$n, colour = .data$token)) +
    ggplot2::geom_line() +
    ggplot2::labs(x = NULL, y = "n", colour = NULL)
}

#' @rdname plot_helpers
#' @export
plot_wordcloud <- function(counts, top_n = 100, value = "n") {
  need_ggplot()
  rlang::check_installed("ggwordcloud", reason = "to draw word clouds.")
  check_cols(counts, c("token", value), "counts")
  d <- utils::head(counts[order(-counts[[value]]), ], top_n)
  ggplot2::ggplot(d, ggplot2::aes(label = .data$token, size = .data[[value]])) +
    ggwordcloud::geom_text_wordcloud() +
    ggplot2::scale_size_area(max_size = 15) +
    ggplot2::theme_minimal()
}

#' @rdname plot_helpers
#' @export
plot_network <- function(cooc, top_n = 50) {
  need_ggplot()
  rlang::check_installed(c("ggraph", "igraph"), reason = "to draw networks.")
  check_cols(cooc, c("term1", "term2", "n"), "cooc")
  g <- igraph::graph_from_data_frame(utils::head(cooc[order(-cooc$n), ], top_n), directed = FALSE)
  ggraph::ggraph(g, layout = "fr") +
    ggraph::geom_edge_link(ggplot2::aes(edge_alpha = .data$n, edge_width = .data$n),
                           show.legend = FALSE) +
    ggraph::geom_node_point(size = 3) +
    ggraph::geom_node_text(ggplot2::aes(label = .data$name), repel = TRUE) +
    ggraph::theme_graph()
}

need_ggplot <- function() rlang::check_installed("ggplot2", reason = "to draw plots.")
