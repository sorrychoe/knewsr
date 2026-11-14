# Plot helpers

Thin wrappers that return ggplot2 objects, so you can add themes, labels
or Korean fonts (e.g.
`+ ggplot2::theme(text = ggplot2::element_text(family = "NanumGothic"))`).
They do no computation beyond picking the top rows.

## Usage

``` r
plot_terms(counts, top_n = 25, value = "n")

plot_keyness(k, top_n = 20)

plot_trend(trend)

plot_wordcloud(counts, top_n = 100, value = "n")

plot_network(cooc, top_n = 50)
```

## Arguments

- counts:

  Output of
  [`count_terms()`](https://sorrychoe.github.io/knewsr/reference/count_terms.md)
  or
  [`tf_idf()`](https://sorrychoe.github.io/knewsr/reference/tf_idf.md).

- top_n:

  Number of terms (or, for `plot_network()`, edges) to show.

- value:

  Column of `counts` that sizes the bars or words.

- k:

  Output of
  [`keyness()`](https://sorrychoe.github.io/knewsr/reference/keyness.md).

- trend:

  Output of
  [`term_trend()`](https://sorrychoe.github.io/knewsr/reference/term_trend.md).

- cooc:

  Output of
  [`cooccurrence()`](https://sorrychoe.github.io/knewsr/reference/cooccurrence.md)
  with `output = "tibble"`.

## Value

A ggplot object.

## Details

- `plot_terms()`: horizontal bar chart of
  [`count_terms()`](https://sorrychoe.github.io/knewsr/reference/count_terms.md)
  or
  [`tf_idf()`](https://sorrychoe.github.io/knewsr/reference/tf_idf.md)
  output.

- `plot_keyness()`: the most distinctive terms on each side of
  [`keyness()`](https://sorrychoe.github.io/knewsr/reference/keyness.md).

- `plot_trend()`: lines of
  [`term_trend()`](https://sorrychoe.github.io/knewsr/reference/term_trend.md)
  output.

- `plot_wordcloud()`: word cloud via ggwordcloud.

- `plot_network()`: co-occurrence network of
  [`cooccurrence()`](https://sorrychoe.github.io/knewsr/reference/cooccurrence.md)
  output via ggraph and igraph.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
if (requireNamespace("ggplot2", quietly = TRUE)) {
  p1 <- plot_terms(count_terms(tokens), top_n = 10)
  p2 <- plot_keyness(keyness(tokens, "source", unique(tokens$source)[1]))
  # print(p1) to draw; set a Korean font if Hangul shows as boxes
}
```
