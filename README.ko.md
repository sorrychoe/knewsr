
<!-- README.ko.md is generated from README.ko.Rmd. Please edit that file -->

# knewsr

[English](https://github.com/sorrychoe/knewsr/blob/release/README.md)

knewsr는 한국어 뉴스 데이터의 수집과 전처리를 자동화하고,
빈도·TF-IDF·DTM·공기어·키니스·기간별 추이 같은 기초 텍스트 분석을 몇
줄의 R 코드로 끝내는 패키지입니다. Excel·CSV·JSON 파일(BigKinds 내보내기
포함), 제목·본문 컬럼이 있는 어떤 data.frame, 네이버 뉴스 검색 API,
RSS/Atom 피드를 모두 같은 파이프라인에 넣을 수 있습니다.

## 설치

아직 CRAN에 배포되지 않았습니다.

``` r
devtools::install_github("sorrychoe/knewsr")
```

본문 형태소 분석(`tokenize_ko(field = "text")`)에는 시스템 MeCab-ko,
mecab-ko-dic과 `RcppMeCab` 패키지가 필요합니다. BigKinds `키워드` 컬럼을
쓰는 기본 경로는 추가 설치가 필요 없습니다. JSON 파일은 `jsonlite`,
네이버 수집은 `httr2`, RSS 수집은 `xml2`가 필요합니다. 네이버 API 키는
`NAVER_CLIENT_ID`, `NAVER_CLIENT_SECRET` 환경변수로 설정합니다.

## 사용법

``` r
library(knewsr)

news <- as_news(president_lee_2026_08) |> clean_news()
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`,
#> title <- `제목`, keyword <- `키워드`
# 또는 read_news("folder/"), collect_naver("검색어"), collect_rss("https://.../rss")
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

| 단계 | 함수 |
|----|----|
| 입력 | `read_news()`, `read_bigkinds()`, `as_news()` |
| 수집 | `collect_naver()`, `collect_rss()` |
| 전처리 | `clean_news()`, `tokenize_ko()`, `ngrams_ko()`, `stopwords_ko()` |
| 분석 | `count_terms()`, `tf_idf()`, `as_dtm()`, `as_tdm()`, `cooccurrence()`, `keyness()`, `term_trend()`, `summarise_corpus()` |
| 시각화 | `plot_terms()`, `plot_keyness()`, `plot_trend()`, `plot_wordcloud()`, `plot_network()` |

자세한 흐름은 `vignette("getting-started", package = "knewsr")`를
참고하세요.

## 라이선스

[MIT](https://choosealicense.com/licenses/mit/)

## 문의

사용 중 문제 발생 시 [GitHub
이슈](https://github.com/sorrychoe/knewsr/issues)에 등록해주세요.
