# Summarise a news corpus

Number of articles and the first and last publication date, overall or
per group. Replaces counting articles per outlet and checking the date
range by hand.

## Usage

``` r
summarise_corpus(news, by = NULL)
```

## Arguments

- news:

  A tibble from
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md).

- by:

  Optional grouping columns, e.g. `"source"`.

## Value

A tibble with the `by` columns, `n`, `first_date` and `last_date`,
sorted by `n`.

## Examples

``` r
news <- as_news(president_lee_2026_08)
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
summarise_corpus(news)
#> # A tibble: 1 × 3
#>       n first_date last_date 
#>   <int> <date>     <date>    
#> 1   300 2026-08-01 2026-08-31
summarise_corpus(news, by = "source")
#> # A tibble: 10 × 4
#>    source       n first_date last_date 
#>    <chr>    <int> <date>     <date>    
#>  1 세계일보    48 2026-08-02 2026-08-31
#>  2 한국일보    38 2026-08-01 2026-08-31
#>  3 한겨레      35 2026-08-02 2026-08-31
#>  4 문화일보    34 2026-08-01 2026-08-31
#>  5 중앙일보    30 2026-08-02 2026-08-30
#>  6 경향신문    29 2026-08-03 2026-08-30
#>  7 서울신문    23 2026-08-02 2026-08-28
#>  8 동아일보    22 2026-08-01 2026-08-26
#>  9 조선일보    21 2026-08-05 2026-08-30
#> 10 국민일보    20 2026-08-01 2026-08-30
```
