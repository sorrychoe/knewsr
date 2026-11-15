
<!-- README.md is generated from README.Rmd. Please edit that file -->

# knewsr

[Korean](https://github.com/sorrychoe/knewsr/blob/release/README.ko.md)

knewsr collects and preprocesses Korean news data and runs basic text
analysis in a few lines of R: term frequencies, TF-IDF, document-term
matrices, co-occurrence, keyness and term trends over time. Excel, CSV
and JSON files (including BigKinds exports), any data frame with title
or body columns, the Naver News Search API and RSS/Atom feeds all feed
into the same pipeline.

## Installation

knewsr is not on CRAN yet. Install the development version from GitHub:

``` r
devtools::install_github("sorrychoe/knewsr")
```

Morphological analysis of article bodies (`tokenize_ko(field = "text")`)
needs the MeCab-ko system library, mecab-ko-dic and the `RcppMeCab`
package. The default path, which uses the BigKinds keyword column, needs
nothing extra. Reading JSON files needs `jsonlite`, collecting from
Naver needs `httr2` and collecting RSS needs `xml2`. Set the Naver API
keys in the `NAVER_CLIENT_ID` and `NAVER_CLIENT_SECRET` environment
variables.

## Usage

``` r
library(knewsr)

news <- as_news(president_lee_2026_08) |> clean_news()
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`,
#> title <- `제목`, keyword <- `키워드`
# or read_news("folder/"), collect_naver("query"), collect_rss("https://.../rss")
tokens <- tokenize_ko(news, keep = "source")

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
keyness(tokens, group = "source", target = "조선일보")
#> # A tibble: 10,098 × 5
#>    token n_target n_reference keyness        p
#>    <chr>    <int>       <int>   <dbl>    <dbl>
#>  1 장씨        30           0   160.  1.41e-36
#>  2 실종        26          17    83.0 8.16e-20
#>  3 발견        20           9    71.7 2.49e-17
#>  4 경장        17           4    70.5 4.60e-17
#>  5 한미        24          35    53.0 3.41e-13
#>  6 시신        11           1    51.7 6.39e-13
#>  7 후보        82         425    49.3 2.21e-12
#>  8 훈련        23          37    47.8 4.78e-12
#>  9 골프        15          17    38.0 7.21e-10
#> 10 펜션         7           0    37.2 1.07e- 9
#> # ℹ 10,088 more rows
```

| Step | Functions |
|----|----|
| Input | `read_news()`, `read_bigkinds()`, `as_news()` |
| Collection | `collect_naver()`, `collect_rss()` |
| Preprocessing | `clean_news()`, `tokenize_ko()`, `ngrams_ko()`, `stopwords_ko()` |
| Analysis | `count_terms()`, `tf_idf()`, `as_dtm()`, `as_tdm()`, `cooccurrence()`, `keyness()`, `term_trend()`, `summarise_corpus()` |
| Visualization | `plot_terms()`, `plot_keyness()`, `plot_trend()`, `plot_wordcloud()`, `plot_network()` |

See `vignette("getting-started", package = "knewsr")` for the full
workflow.

## License

[MIT](https://choosealicense.com/licenses/mit/)

## Issues

Please report problems on [GitHub
issues](https://github.com/sorrychoe/knewsr/issues).
