# Term trends over time

Counts selected terms per day, week (starting Monday) or month. Periods
with no occurrence of a term get `n = 0`.

## Usage

``` r
term_trend(tokens, news, terms, unit = c("day", "week", "month"))
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- news:

  The news tibble the tokens came from, used for the dates.

- terms:

  Terms to follow.

- unit:

  `"day"`, `"week"` or `"month"`.

## Value

A tibble with `date` (start of the period), `token` and `n`.

## Examples

``` r
news <- as_news(president_lee_2026_08)
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
tokens <- tokenize_ko(news)
term_trend(tokens, news, terms = count_terms(tokens)$token[1:3], unit = "week")
#> # A tibble: 18 × 3
#>    date       token      n
#>    <date>     <chr>  <int>
#>  1 2026-07-27 대통령    73
#>  2 2026-07-27 정부      30
#>  3 2026-07-27 후보      58
#>  4 2026-08-03 대통령   223
#>  5 2026-08-03 정부     129
#>  6 2026-08-03 후보     122
#>  7 2026-08-10 대통령   328
#>  8 2026-08-10 정부     142
#>  9 2026-08-10 후보     238
#> 10 2026-08-17 대통령   402
#> 11 2026-08-17 정부     129
#> 12 2026-08-17 후보      57
#> 13 2026-08-24 대통령   330
#> 14 2026-08-24 정부     142
#> 15 2026-08-24 후보      32
#> 16 2026-08-31 대통령    44
#> 17 2026-08-31 정부      13
#> 18 2026-08-31 후보       0
```
