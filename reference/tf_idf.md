# TF-IDF

Term frequency-inverse document frequency of every term in every
document, or in every group when `by` names a grouping column (each
group is then treated as one document).

## Usage

``` r
tf_idf(tokens, by = "doc_id")
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- by:

  Column that defines a document. Defaults to `"doc_id"`.

## Value

A tibble with `by`, `token`, `n`, `tf`, `idf` and `tf_idf`, sorted by
`tf_idf`.

## Details

`tf` is the term count divided by the total count in the document and
`idf` is `log(number of documents / documents containing the term)`.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08), keep = "source")
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
tf_idf(tokens)
#> # A tibble: 39,336 × 6
#>    doc_id                     token     n     tf   idf tf_idf
#>    <chr>                      <chr> <int>  <dbl> <dbl>  <dbl>
#>  1 01100701.20260824223453001 몽골     15 0.0872  5.70  0.497
#>  2 01100611.20260810001216001 종목     18 0.140   3.22  0.449
#>  3 01100701.20260817231439001 축사      2 0.1     4.32  0.432
#>  4 01100101.20260824171417001 정지     15 0.0704  5.70  0.402
#>  5 01100401.20260813231837001 결혼     16 0.0925  4.32  0.399
#>  6 01100611.20260821182714001 선포      8 0.0889  4.32  0.384
#>  7 01100801.20260813143715001 모병      7 0.0660  5.70  0.377
#>  8 01100701.20260817231439001 영상      2 0.1     3.76  0.376
#>  9 01100501.20260814120340002 사면      5 0.0658  5.70  0.375
#> 10 01100501.20260814120340002 특사      5 0.0658  5.70  0.375
#> # ℹ 39,326 more rows
tf_idf(tokens, by = "source")
#> # A tibble: 23,334 × 6
#>    source   token        n      tf   idf  tf_idf
#>    <chr>    <chr>    <int>   <dbl> <dbl>   <dbl>
#>  1 조선일보 장씨        30 0.00668  2.30 0.0154 
#>  2 서울신문 하우스      15 0.00281  2.30 0.00647
#>  3 경향신문 정지        15 0.00270  2.30 0.00621
#>  4 동아일보 요금        12 0.00251  2.30 0.00578
#>  5 문화일보 병역        15 0.00236  2.30 0.00544
#>  6 서울신문 버스        24 0.00450  1.20 0.00542
#>  7 동아일보 전술        11 0.00230  2.30 0.00530
#>  8 서울신문 딥페이크    11 0.00206  2.30 0.00475
#>  9 국민일보 토허구역     8 0.00190  2.30 0.00437
#> 10 동아일보 채점         9 0.00188  2.30 0.00433
#> # ℹ 23,324 more rows
```
