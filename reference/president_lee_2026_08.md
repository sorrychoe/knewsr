# BigKinds sample: news mentioning President Lee (August 2026)

A random sample of 300 articles from a BigKinds export, in the BigKinds
column layout. Only metadata, headlines and the BigKinds keyword lists
are included; article bodies, bylines and URLs were removed. Convert it
to the standard schema with
[`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md).

## Usage

``` r
president_lee_2026_08
```

## Format

A tibble with 300 rows and 5 columns:

- 뉴스 식별자:

  BigKinds article id.

- 일자:

  Publication date (`YYYYMMDD`).

- 언론사:

  News outlet.

- 제목:

  Article headline.

- 키워드:

  Comma-separated keywords extracted by BigKinds.

## Source

BigKinds, Korea Press Foundation. <https://www.bigkinds.or.kr/>
