.hangul <- "\uac00-\ud7a3"

# Applied in this order: email/url go before `special` strips their symbols.
.clean_patterns <- list(
  header = "\\[[^]]*\\]|\u3010[^\u3011]*\u3011",
  # "(Seoul=Yonhap)" style datelines and "Hong Gildong reporter/correspondent"
  byline = paste0(
    "\\([^()]*=[^()]*\\)|[", .hangul, "]{2,4} ?(\uae30\uc790|\ud2b9\ud30c\uc6d0)( ?=)?"
  ),
  email = "[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[[:alpha:]]{2,}",
  url = "(https?://|www\\.)[^[:space:]]+",
  special = paste0("[^", .hangul, "[:alnum:][:space:].,?!%]")
)

#' Clean news text
#'
#' Removes common noise from the `title` and `text` columns of a news tibble:
#' bracketed headers such as `[Breaking]`, reporter bylines and datelines,
#' e-mail addresses, URLs and special characters. Whitespace is squished
#' afterwards. The `keyword` column is left untouched.
#'
#' The byline rule removes a 2-4 syllable Hangul name followed by
#' "reporter" or "correspondent", so it can also hit phrases that merely look
#' like a byline.
#'
#' @param news A tibble from [as_news()] or [read_bigkinds()].
#' @param remove Which kinds of noise to remove. Any subset of `"header"`,
#'   `"byline"`, `"email"`, `"url"` and `"special"`.
#'
#' @return `news` with cleaned `title` and `text` columns.
#' @examples
#' news <- as_news(data.frame(
#'   title = "[\uc18d\ubcf4] \uc815\ubd80, \uc608\uc0b0\uc548 \ubc1c\ud45c",
#'   text = paste("(\uc11c\uc6b8=\uc5f0\ud569\ub274\uc2a4) \ud64d\uae38\ub3d9 \uae30\uc790 =",
#'                "\uc815\ubd80\uac00 \ubc1c\ud45c\ud588\ub2e4. hong@example.com"),
#'   date = "2024-01-02", source = "\uc5f0\ud569\ub274\uc2a4"
#' ))
#' clean_news(news)[, c("title", "text")]
#' @export
clean_news <- function(news, remove = c("header", "byline", "email", "url", "special")) {
  check_news(news)
  remove <- rlang::arg_match(remove, names(.clean_patterns), multiple = TRUE)
  patterns <- .clean_patterns[names(.clean_patterns) %in% remove]
  clean <- function(x) {
    for (p in patterns) x <- gsub(p, " ", x, perl = TRUE)
    trimws(gsub("[[:space:]]+", " ", x))
  }
  news$title <- clean(news$title)
  news$text <- clean(news$text)
  news
}

#' Korean news stopwords
#'
#' A small default list of words that are frequent in Korean news but rarely
#' informative (bylines, wire service names, time words, connectives).
#' Extend it with `c(stopwords_ko(), "...")`.
#'
#' @return A character vector.
#' @examples
#' head(stopwords_ko())
#' @export
stopwords_ko <- function() {
  readLines(system.file("extdata", "stopwords_ko.txt", package = "knewsr"),
            encoding = "UTF-8")
}

check_news <- function(news) {
  need <- c("doc_id", "title", "text", "keyword")
  if (!is.data.frame(news) || !all(need %in% names(news))) {
    rlang::abort("`news` must be a news tibble; create one with `as_news()`.")
  }
}
