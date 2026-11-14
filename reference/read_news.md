# Read news files

Reads one or more news files, or every supported file in a directory,
and converts them to the standard news schema with
[`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md).

## Usage

``` r
read_news(path, ..., dedup = FALSE)

read_bigkinds(path, ...)
```

## Arguments

- path:

  File paths or a directory.

- ...:

  Column mapping and options passed on to
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md),
  applied to each file. With several files, a named column is used in
  the files that have it and the others fall back to detection.

- dedup:

  If `TRUE`, drop repeated articles across all files (see
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md)).

## Value

A tibble in the standard news schema.

## Details

Supported formats are `.xlsx`/`.xls`, `.csv`, `.tsv`, `.json` and
`.jsonl` (newline-delimited JSON). CSV/TSV files are read as UTF-8 and,
if that is not valid, as CP949 (EUC-KR), the usual encoding of Korean
Excel exports. A JSON object that wraps the articles (e.g.
`{"items": [...]}`) is unwrapped. Each file is mapped to the standard
schema on its own, so files with different layouts can be combined;
unmapped extra columns become character.

## Examples

``` r
path <- system.file("extdata", "bigkinds_sample.xlsx", package = "knewsr")
read_news(path)
#> Detected columns: date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
#> # A tibble: 31 × 6
#>    doc_id date       source   title                                text  keyword
#>    <chr>  <date>     <chr>    <chr>                                <chr> <chr>  
#>  1 1      2020-01-31 경향신문 "[사설] 한반도 긴장 높인 북한의 군사정찰위성 발사 규탄한다"… NA    한반도,긴장…
#>  2 2      2020-01-30 한겨레   "허리에 '캡사이신' 찬 경찰 민주노총, 6시간 만에 자진해산"… NA    허리,캡사이…
#>  3 3      2020-01-29 조선일보 "윤 대통령 ‘외국인 가사도우미’ 이어 돌봄 보육도 “시장화”"… NA    대통령,외국…
#>  4 4      2020-01-28 중앙일보 "윤 대통령, 스가 전 총리 만나 “한일 관계, 완전한 복원” … NA    대통령,스가…
#>  5 5      2020-01-27 동아일보 "‘직권남용죄’ 남용 유감"             NA    직권남용죄,…
#>  6 6      2020-01-26 경향신문 "‘외국인 가사도우미’ 검토하라는 대통령 희생 강요받는 노동"…… NA    외국인,가사…
#>  7 7      2020-01-25 경향신문 "“한상혁 면직 언론장악 시도” 민주 방송법 개정으로 맞대응"…… NA    한상혁,면직…
#>  8 8      2020-01-24 한겨레   "[사설] 한상혁 위원장 면직, 방송 장악 신호탄인가"…… NA    면직,한상혁…
#>  9 9      2020-01-23 한겨레   "한 총리 \"시찰단 브리핑, 방류절차 투명성 보였다 매우 만족… NA    브리핑,총리…
#> 10 10     2020-01-22 한겨레   "한국이 올인하는 인 태 전략은 안녕한가? [정의길의 세계, 그… NA    한국,올인,…
#> # ℹ 21 more rows

csv <- tempfile(fileext = ".csv")
write.csv(data.frame(headline = "제목", body = "본문입니다", pubDate = "2024.01.02",
                     press = "A일보"),
          csv, row.names = FALSE, fileEncoding = "UTF-8")
read_news(csv)
#> Detected columns: date <- `pubDate`, source <- `press`, title <- `headline`, text <- `body`
#> # A tibble: 1 × 6
#>   doc_id date       source title text       keyword
#>   <chr>  <date>     <chr>  <chr> <chr>      <chr>  
#> 1 1      2024-01-02 A일보  제목  본문입니다 NA     
```
