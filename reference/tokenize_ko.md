# Tokenize Korean news

Turns a news tibble into a long token table with one row per token.

## Usage

``` r
tokenize_ko(
  news,
  field = c("keyword", "text", "title"),
  pos = "noun",
  stopwords = stopwords_ko(),
  min_nchar = 2,
  keep = NULL,
  dic = getOption("knewsr.mecab_dic", "")
)
```

## Arguments

- news:

  A tibble from
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md).

- field:

  Column to tokenize: `"keyword"`, `"text"` or `"title"`.

- pos:

  Part-of-speech tags to keep when analysing text. `"noun"` keeps common
  and proper nouns (`NNG`, `NNP`); otherwise a vector of Sejong tags
  such as `c("NNG", "NNP", "VV")`. Ignored for `field = "keyword"`.

- stopwords:

  Tokens to drop.

- min_nchar:

  Drop tokens shorter than this many characters.

- keep:

  Columns of `news` (e.g. `"source"`, `"date"`) to carry over to the
  token table, for grouped counts and
  [`keyness()`](https://sorrychoe.github.io/knewsr/reference/keyness.md).

- dic:

  Path to the mecab-ko-dic system dictionary, passed to
  [`RcppMeCab::pos()`](https://rdrr.io/pkg/RcppMeCab/man/pos.html) as
  `sys_dic`. `""` uses the MeCab default. Set it once with
  `options(knewsr.mecab_dic = "...")`.

## Value

A tibble with `doc_id`, the `keep` columns and `token`, in text order.

## Details

With `field = "keyword"` (the default) the comma-separated BigKinds
`keyword` column is split, which is fast and needs no morphological
analyser. With `field = "text"` or `"title"` the text is analysed with
MeCab-ko through the RcppMeCab package, which needs a system MeCab
installation and the mecab-ko-dic dictionary.

## Examples

``` r
news <- as_news(president_lee_2026_08)
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
tokenize_ko(news, keep = "source")
#> # A tibble: 63,945 × 3
#>    doc_id                     source token       
#>    <chr>                      <chr>  <chr>       
#>  1 01101001.20260831191916001 한겨레 뉴스룸      
#>  2 01101001.20260831191916001 한겨레 이승준      
#>  3 01101001.20260831191916001 한겨레 정치데스크  
#>  4 01101001.20260831191916001 한겨레 전쟁        
#>  5 01101001.20260831191916001 한겨레 17          
#>  6 01101001.20260831191916001 한겨레 전당대회    
#>  7 01101001.20260831191916001 한겨레 더불어민주당
#>  8 01101001.20260831191916001 한겨레 전당        
#>  9 01101001.20260831191916001 한겨레 대회        
#> 10 01101001.20260831191916001 한겨레 가지        
#> # ℹ 63,935 more rows

if (FALSE) { # \dontrun{
# needs MeCab-ko and mecab-ko-dic on the system
tokenize_ko(news, field = "title")
} # }
```
