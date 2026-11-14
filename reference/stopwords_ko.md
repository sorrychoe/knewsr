# Korean news stopwords

A small default list of words that are frequent in Korean news but
rarely informative (bylines, wire service names, time words,
connectives). Extend it with `c(stopwords_ko(), "...")`.

## Usage

``` r
stopwords_ko()
```

## Value

A character vector.

## Examples

``` r
head(stopwords_ko())
#> [1] "기자"     "특파원"   "뉴스"     "연합뉴스" "뉴시스"   "뉴스1"   
```
