# Term co-occurrence

Counts how often pairs of terms appear together, either in the same
document or within a sliding window of tokens.

## Usage

``` r
cooccurrence(
  tokens,
  window = "doc",
  top_n = 50,
  output = c("tibble", "matrix")
)
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- window:

  `"doc"` counts the documents in which both terms occur. A number `w`
  counts the times two terms occur within `w` tokens of each other in
  the same document (in the order of `tokens`).

- top_n:

  Only consider the `top_n` most frequent terms (by document frequency).
  `NULL` keeps all terms.

- output:

  `"tibble"` for a pair list or `"matrix"` for a symmetric sparse
  term-by-term matrix.

## Value

A tibble with `term1`, `term2` and `n` sorted by `n`, or a
[Matrix::dsCMatrix](https://rdrr.io/pkg/Matrix/man/dsCMatrix-class.html)
with a zero diagonal.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08))
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
cooccurrence(tokens, top_n = 30)
#> # A tibble: 435 × 3
#>    term1        term2      n
#>    <chr>        <chr>  <dbl>
#>  1 대통령       이재명   270
#>  2 이재명       정부     186
#>  3 대통령       정부     165
#>  4 국민         이재명   150
#>  5 국민         대통령   143
#>  6 이재명       청와대   112
#>  7 강조         이재명   111
#>  8 대통령       청와대   111
#>  9 이재명       추진     108
#> 10 더불어민주당 이재명   103
#> # ℹ 425 more rows
cooccurrence(tokens, window = 2, top_n = 30)
#> # A tibble: 331 × 3
#>    term1  term2      n
#>    <chr>  <chr>  <dbl>
#>  1 대통령 이재명   328
#>  2 이재명 정부      95
#>  3 대통령 청와대    60
#>  4 부동산 정책      46
#>  5 민주당 의원      41
#>  6 대통령 대표      39
#>  7 대통령 민주당    39
#>  8 국민   대통령    36
#>  9 서울   시장      36
#> 10 대통령 의원      36
#> # ℹ 321 more rows
```
