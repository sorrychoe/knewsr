# Keyness between groups

Compares how often each term occurs in a target group versus the rest of
the corpus (or a chosen reference group), using a 2 x 2 contingency
table per term.

## Usage

``` r
keyness(tokens, group, target, reference = NULL, measure = c("lr", "chi2"))
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- group:

  Grouping column of `tokens`, e.g. `"source"` (carry it over with
  `tokenize_ko(keep = )`).

- target:

  Value of `group` to compare.

- reference:

  Value(s) of `group` to compare against. `NULL` uses every other group.

- measure:

  `"lr"` for the log-likelihood ratio (G2), `"chi2"` for Pearson's
  chi-square (no continuity correction).

## Value

A tibble with `token`, `n_target`, `n_reference`, `keyness` and `p`,
sorted by `keyness`.

## Details

The statistic is signed: positive when the term is relatively more
frequent in the target, negative when it is more frequent in the
reference. `p` comes from a chi-square distribution with one degree of
freedom.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
keyness(tokens, group = "source", target = unique(tokens$source)[1])
#> # A tibble: 10,098 × 5
#>    token    n_target n_reference keyness        p
#>    <chr>       <int>       <int>   <dbl>    <dbl>
#>  1 판사           37          41    62.1 3.20e-15
#>  2 크로스         17           2    61.2 5.14e-15
#>  3 긍정           36          50    51.0 9.25e-13
#>  4 의약품         12           1    45.1 1.90e-11
#>  5 데드           12           2    40.9 1.62e-10
#>  6 사관학교       16           8    40.6 1.89e-10
#>  7 방위백서        9           0    38.9 4.45e-10
#>  8 경남도          9           1    32.6 1.10e- 8
#>  9 심사           12           6    30.4 3.46e- 8
#> 10 중지           12           6    30.4 3.46e- 8
#> # ℹ 10,088 more rows
```
