# Collect news from RSS or Atom feeds

Reads RSS 2.0 or Atom feeds, from URLs or local files, and returns their
items in the standard news schema. `text` is the full content
(`content:encoded`) when the feed provides it, otherwise the summary.
`source` is the feed title. HTML tags are removed.

## Usage

``` r
collect_rss(url)
```

## Arguments

- url:

  One or more feed URLs or file paths.

## Value

A tibble in the standard news schema with the extra columns `feed` (the
feed URL) and `link`. Items that appear in several feeds are kept once.

## Examples

``` r
# a trimmed Yonhap News feed (titles and links only)
feed <- system.file("extdata", "sample_rss.xml", package = "knewsr")
collect_rss(feed)
#> # A tibble: 5 × 8
#>   doc_id                       date       source title text  keyword feed  link 
#>   <chr>                        <date>     <chr>  <chr> <chr> <chr>   <chr> <chr>
#> 1 https://www.yna.co.kr/view/… 2026-11-14 연합뉴스 … "메타엠… NA    NA      /hom… http…
#> 2 https://www.yna.co.kr/view/… 2026-11-14 연합뉴스 … "美교통… NA    NA      /hom… http…
#> 3 https://www.yna.co.kr/view/… 2026-11-14 연합뉴스 … "모레노… NA    NA      /hom… http…
#> 4 https://www.yna.co.kr/view/… 2026-11-14 연합뉴스 … "이탈리… NA    NA      /hom… http…
#> 5 https://www.yna.co.kr/view/… 2026-11-14 연합뉴스 … "한국 … NA    NA      /hom… http…
```
