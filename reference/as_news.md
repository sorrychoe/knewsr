# Convert a data frame to the standard news schema

Maps the columns of any news data frame to the standard schema used by
every other function: `doc_id` (chr), `date` (Date), `source` (chr),
`title` (chr), `text` (chr) and `keyword` (chr, comma-separated).
Columns that are not mapped are kept after the standard ones.

## Usage

``` r
as_news(
  df,
  text = NULL,
  title = NULL,
  date = NULL,
  source = NULL,
  keyword = NULL,
  id = NULL,
  keyword_sep = ",",
  dedup = FALSE,
  quiet = FALSE
)
```

## Arguments

- df:

  A data frame of news articles, one row per article.

- text, title, date, source, keyword, id:

  Column names in `df`, `NULL` to detect, or `NA` to leave empty.
  Without an id column, row numbers are used.

- keyword_sep:

  Separator used in the keyword column; it is converted to commas. A
  list column of keywords is also accepted.

- dedup:

  If `TRUE`, drop repeated articles: rows with the same id, or the same
  title, date and source (or text, when there are no titles).

- quiet:

  If `TRUE`, do not report detected columns. A warning is still raised
  when `title`, `date` or `source` cannot be detected; pass `NA` for a
  field to leave it empty on purpose.

## Value

A tibble in the standard news schema.

## Details

Columns left as `NULL` are detected by name, case-insensitively, from a
list of common names: BigKinds' Korean headers, `title`/`headline`,
`text`/`body`/`content`/`description`, `date`/`pubDate`/`published`,
`source`/`press`/`media`, `id`/`guid` and others. The chosen mapping is
reported in a message. A column you name must exist; `NA` skips a field.
At least one of `text` and `keyword` is required.

Dates are parsed element by element from `YYYY-MM-DD`, `YYYY.MM.DD`,
`YYYY/MM/DD`, `YYYYMMDD`, Korean `YYYY년 M월 D일` and RFC 822
(`Mon, 02 Jan 2024 13:05:00 +0900`, as in RSS) forms, with or without a
time; the calendar date as written is kept. Values that cannot be parsed
become `NA` with a warning.

## Examples

``` r
df <- data.frame(
  headline = c("first", "second", "second"),
  body = c("first article", "second article", "second article"),
  published = c("2024.01.01", "2024년 1월 2일", "2024년 1월 2일"),
  media = "A일보"
)
as_news(df, dedup = TRUE)
#> Detected columns: date <- `published`, source <- `media`, title <- `headline`, text <- `body`
#> # A tibble: 2 × 6
#>   doc_id date       source title  text           keyword
#>   <chr>  <date>     <chr>  <chr>  <chr>          <chr>  
#> 1 1      2024-01-01 A일보  first  first article  NA     
#> 2 2      2024-01-02 A일보  second second article NA     
as_news(df, text = "body", title = NA, quiet = TRUE)
#> # A tibble: 3 × 7
#>   doc_id date       source title text           keyword headline
#>   <chr>  <date>     <chr>  <chr> <chr>          <chr>   <chr>   
#> 1 1      2024-01-01 A일보  NA    first article  NA      first   
#> 2 2      2024-01-02 A일보  NA    second article NA      second  
#> 3 3      2024-01-02 A일보  NA    second article NA      second  

as_news(president_lee_2026_08)
#> Detected columns: doc_id <- `뉴스 식별자`, date <- `일자`, source <- `언론사`, title <- `제목`, keyword <- `키워드`
#> # A tibble: 300 × 6
#>    doc_id                     date       source   title            text  keyword
#>    <chr>                      <date>     <chr>    <chr>            <chr> <chr>  
#>  1 01101001.20260831191916001 2026-08-31 한겨레   "이토록 뜨거운데, 바뀌지 … NA    뉴스룸,이승…
#>  2 01101101.20260831163230001 2026-08-31 한국일보 "\"외부 조문 사양\"에도… NA    사양,외부,…
#>  3 01100701.20260831142845001 2026-08-31 세계일보 "오세훈 “李대통령 부동산 … NA    오세훈,대통…
#>  4 01100501.20260831111921003 2026-08-31 문화일보 "與 전은수 “국힘, 발목잡… NA    국힘,전은수…
#>  5 01100701.20260831100115001 2026-08-31 세계일보 "국토장관 후보자 \"용산공… NA    용산공원,국…
#>  6 01100501.20260831070524001 2026-08-31 문화일보 "용혜인 지명에 “꼴페미 정… NA    용혜인,지명…
#>  7 01101101.20260831001113001 2026-08-31 한국일보 "[사설] 지지율 하락 속 … NA    지지율,하락…
#>  8 01100801.20260830233831001 2026-08-30 조선일보 "[태평로] 국보법 위반해도… NA    국보법,위반…
#>  9 01100501.20260830224353001 2026-08-30 문화일보 "김승원 법무장관 후보자 “… NA    대전환,김승…
#> 10 01100101.20260830205932001 2026-08-30 경향신문 "“이용자 적어 없앤다니 취… NA    이용자,취약…
#> # ℹ 290 more rows
```
