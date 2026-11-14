sample_news <- function() as_news(president_lee_2026_08, quiet = TRUE)

toy_tokens <- function() {
  tibble::tibble(
    doc_id = c("1", "1", "1", "2", "2", "3"),
    source = c("A", "A", "A", "B", "B", "B"),
    token  = c("x", "y", "x", "x", "z", "z")
  )
}

mecab_ko_dic <- function() {
  dic <- "/usr/lib/x86_64-linux-gnu/mecab/dic/mecab-ko-dic"
  testthat::skip_if_not_installed("RcppMeCab")
  testthat::skip_if_not(dir.exists(dic), "mecab-ko-dic not found")
  dic
}

# Fresh empty directory; tempdir() is removed at the end of the session.
new_tempdir <- function() {
  d <- tempfile()
  dir.create(d)
  d
}

# Fixtures that deliberately lack title/date/source columns.
quiet_missing <- function(expr) suppressWarnings(expr, classes = "knewsr_missing_columns")
partial_news <- function(...) quiet_missing(as_news(...))
