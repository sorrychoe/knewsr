# Korean n-grams

Builds n-grams from consecutive tokens of each document, after
[`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
has filtered parts of speech and stopwords.

## Usage

``` r
ngrams_ko(news, n = 2, sep = " ", ...)
```

## Arguments

- news:

  A tibble from
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md).

- n:

  Number of tokens per n-gram.

- sep:

  Separator between the tokens of an n-gram.

- ...:

  Passed on to
  [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md).

## Value

A tibble with `doc_id`, the `keep` columns and `token`, where `token`
holds the n-gram, so it works with every counting function.

## Examples

``` r
news <- as_news(president_lee_2026_08)
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
ngrams_ko(news, n = 2, field = "keyword")
#> # A tibble: 63,645 × 2
#>    doc_id                     token                
#>    <chr>                      <chr>                
#>  1 01101001.20260831191916001 뉴스룸 이승준        
#>  2 01101001.20260831191916001 이승준 정치데스크    
#>  3 01101001.20260831191916001 정치데스크 전쟁      
#>  4 01101001.20260831191916001 전쟁 17              
#>  5 01101001.20260831191916001 17 전당대회          
#>  6 01101001.20260831191916001 전당대회 더불어민주당
#>  7 01101001.20260831191916001 더불어민주당 전당    
#>  8 01101001.20260831191916001 전당 대회            
#>  9 01101001.20260831191916001 대회 가지            
#> 10 01101001.20260831191916001 가지 장면            
#> # ℹ 63,635 more rows
```
