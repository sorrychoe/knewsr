# Document-term and term-document matrices

Builds a sparse document-term matrix (rows are documents, columns are
terms) from a token table. `as_tdm()` returns its transpose.

## Usage

``` r
as_dtm(tokens, weight = c("count", "tfidf", "binary"))

as_tdm(tokens, ...)
```

## Arguments

- tokens:

  A token table from
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  (`doc_id`, `token`).

- weight:

  `"count"` for raw counts, `"tfidf"` for the TF-IDF weights of
  [`tf_idf()`](https://sorrychoe.github.io/knewsr/reference/tf_idf.md),
  `"binary"` for presence (1) or absence.

- ...:

  Passed on to `as_dtm()`.

## Value

A
[Matrix::dgCMatrix](https://rdrr.io/pkg/Matrix/man/dgCMatrix-class.html)
with document ids and terms as dimnames. Documents without tokens are
not included.

## Examples

``` r
tokens <- tokenize_ko(as_news(president_lee_2026_08))
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
dtm <- as_dtm(tokens, weight = "tfidf")
dim(dtm)
#> [1]   300 10098
as_tdm(tokens)[1:5, 1:3]
#> 5 x 3 sparse Matrix of class "dgCMatrix"
#>       01101001.20260831191916001 01101101.20260831163230001
#> 0.04%                          .                          .
#> 0.1%                           .                          .
#> 0.1점                          .                          .
#> 0.3%                           .                          .
#> 0.4%                           .                          .
#>       01100701.20260831142845001
#> 0.04%                          .
#> 0.1%                           .
#> 0.1점                          .
#> 0.3%                           .
#> 0.4%                           .
```
