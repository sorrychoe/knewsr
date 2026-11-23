# Collect news from the Naver News Search API

Searches Naver News through the official Open API and returns the
results in the standard news schema. The API returns headlines, a short
summary (`text`), the publication time and links, but not full article
bodies. `source` is the domain of the original article link.

## Usage

``` r
collect_naver(
  query,
  n = 100,
  sort = c("date", "sim"),
  client_id = Sys.getenv("NAVER_CLIENT_ID"),
  client_secret = Sys.getenv("NAVER_CLIENT_SECRET")
)
```

## Arguments

- query:

  Search query.

- n:

  Number of articles to collect (at most 1,000).

- sort:

  `"date"` for newest first, `"sim"` for relevance.

- client_id, client_secret:

  Naver Open API credentials.

## Value

A tibble in the standard news schema with the extra columns `query`,
`originallink` and `link`.

## Details

Register an application at <https://developers.naver.com/main/> to get a
client id and secret, and store them as the environment variables
`NAVER_CLIENT_ID` and `NAVER_CLIENT_SECRET` (e.g. in `.Renviron`) rather
than in scripts. The API returns at most 1,000 results per query and
allows 25,000 calls per day.

## Examples

``` r
if (FALSE) { # \dontrun{
news <- collect_naver("\uae30\uc900\uae08\ub9ac", n = 300)
tokenize_ko(news, field = "text")
} # }
```
