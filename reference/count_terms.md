# Count terms

Term frequencies, or document frequencies with `by_doc = TRUE`, overall
or per group.

## Usage

``` r
count_terms(tokens, by = NULL, by_doc = FALSE)
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- by:

  Optional grouping columns of `tokens`, e.g. `"source"`.

- by_doc:

  If `TRUE`, count each term at most once per document, giving the
  number of documents that contain it.

## Value

A tibble with the `by` columns, `token` and `n`, sorted by `n`.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
count_terms(tokens)
#> # A tibble: 10,098 × 2
#>    token      n
#>    <chr>  <int>
#>  1 대통령  1400
#>  2 정부     585
#>  3 후보     507
#>  4 이재명   463
#>  5 대표     454
#>  6 의원     423
#>  7 국민     407
#>  8 민주당   283
#>  9 정책     278
#> 10 청와대   272
#> # ℹ 10,088 more rows
count_terms(tokens, by = "source", by_doc = TRUE)
#> # A tibble: 23,334 × 3
#>    source   token      n
#>    <chr>    <chr>  <int>
#>  1 세계일보 이재명    46
#>  2 세계일보 대통령    43
#>  3 한국일보 이재명    38
#>  4 한국일보 대통령    36
#>  5 문화일보 이재명    34
#>  6 세계일보 정부      34
#>  7 한겨레   이재명    34
#>  8 한겨레   대통령    32
#>  9 경향신문 이재명    29
#> 10 중앙일보 이재명    29
#> # ℹ 23,324 more rows
```
