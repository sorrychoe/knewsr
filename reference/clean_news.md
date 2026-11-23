# Clean news text

Removes common noise from the `title` and `text` columns of a news
tibble: bracketed headers such as `[Breaking]`, reporter bylines and
datelines, e-mail addresses, URLs and special characters. Whitespace is
squished afterwards. The `keyword` column is left untouched.

## Usage

``` r
clean_news(news, remove = c("header", "byline", "email", "url", "special"))
```

## Arguments

- news:

  A tibble from
  [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md)
  or
  [`read_bigkinds()`](https://sorrychoe.github.io/knewsr/reference/read_news.md).

- remove:

  Which kinds of noise to remove. Any subset of `"header"`, `"byline"`,
  `"email"`, `"url"` and `"special"`.

## Value

`news` with cleaned `title` and `text` columns.

## Details

The byline rule removes a 2-4 syllable Hangul name followed by
"reporter" or "correspondent", so it can also hit phrases that merely
look like a byline.

## Examples

``` r
news <- as_news(data.frame(
  title = "[\uc18d\ubcf4] \uc815\ubd80, \uc608\uc0b0\uc548 \ubc1c\ud45c",
  text = paste("(\uc11c\uc6b8=\uc5f0\ud569\ub274\uc2a4) \ud64d\uae38\ub3d9 \uae30\uc790 =",
               "\uc815\ubd80\uac00 \ubc1c\ud45c\ud588\ub2e4. hong@example.com"),
  date = "2024-01-02", source = "\uc5f0\ud569\ub274\uc2a4"
))
clean_news(news)[, c("title", "text")]
#> # A tibble: 1 × 2
#>   title             text            
#>   <chr>             <chr>           
#> 1 정부, 예산안 발표 정부가 발표했다.
```
