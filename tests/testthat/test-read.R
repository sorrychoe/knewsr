test_that("read_news reads a BigKinds export", {
  news <- read_bigkinds(system.file("extdata", "bigkinds_sample.xlsx", package = "knewsr"))
  expect_named(news, c("doc_id", "date", "source", "title", "text", "keyword"))
  expect_s3_class(news$date, "Date")
  expect_equal(range(news$date), as.Date(c("2020-01-01", "2020-01-31")))
})

test_that("read_news combines csv (UTF-8 and CP949), json and jsonl files", {
  d <- new_tempdir()
  write.csv(data.frame(headline = "제목1", body = "본문1", pubDate = "2024.01.02"),
            file.path(d, "a.csv"), row.names = FALSE, fileEncoding = "CP949")
  write.csv(data.frame(headline = "제목2", body = "본문2", pubDate = "20240103", n = 1),
            file.path(d, "b.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  skip_if_not_installed("jsonlite")
  jsonlite::write_json(
    list(items = data.frame(title = "제목3", content = "본문3", published = "2024-01-04",
                            keywords = I(list(c("가", "나"))))),
    file.path(d, "c.json")
  )
  jsonlite::stream_out(data.frame(title = "제목1", text = "본문1", date = "2024-01-02"),
                       file(file.path(d, "d.jsonl")), verbose = FALSE)
  news <- quiet_missing(suppressMessages(read_news(d)))
  expect_equal(news$title, c("제목1", "제목2", "제목3", "제목1"))
  expect_equal(news$text[1], "본문1")
  expect_equal(news$date, as.Date(c("2024-01-02", "2024-01-03", "2024-01-04", "2024-01-02")))
  expect_equal(news$keyword[3], "가,나")
  expect_equal(news$doc_id[1], "a.csv:1")
  expect_equal(nrow(quiet_missing(suppressMessages(read_news(d, dedup = TRUE)))), 3)
})

test_that("read_news validates input", {
  expect_error(read_news("nope.xlsx"), "not found")
  d <- new_tempdir()
  expect_error(read_news(d), "No supported")
  f <- file.path(d, "x.txt")
  writeLines("a", f)
  expect_error(read_news(f), "Unsupported")
})

test_that("as_news detects common column names and reports them", {
  df <- data.frame(Headline = "h", Body = "b", pubDate = "2024-01-02", press = "P", extra = 1)
  expect_message(news <- as_news(df), "title <- `Headline`")
  expect_equal(news$title, "h")
  expect_equal(news$text, "b")
  expect_equal(news$source, "P")
  expect_equal(news$extra, 1)
  expect_equal(news$doc_id, "1")
  expect_silent(as_news(df, quiet = TRUE))
})

test_that("as_news honours explicit and skipped columns", {
  df <- data.frame(title = "t", body = "b", desc = "d")
  news <- partial_news(df, text = "desc", title = NA, quiet = TRUE)
  expect_equal(news$text, "d")
  expect_true(is.na(news$title))
  expect_equal(news$body, "b")
})

test_that("as_news is idempotent and reads the bundled data", {
  news <- sample_news()
  expect_equal(nrow(news), 300)
  expect_identical(as_news(news), news)
})

test_that("as_news normalizes keywords and removes duplicates", {
  df <- data.frame(title = c("a", "a", "b"), keyword = c("x;y", "x;y", "z"), date = "20240101")
  news <- partial_news(df, keyword_sep = ";", dedup = TRUE)
  expect_equal(news$keyword, c("x,y", "z"))
  expect_error(partial_news(data.frame(text = c("a", "b"), id = c(1, 1))), "dedup")
  expect_equal(nrow(partial_news(data.frame(text = c("a", "b"), id = c(1, 1)), dedup = TRUE)), 1)
})

test_that("as_news parses many date formats and warns on failures", {
  x <- c("2024-01-02", "2024/01/02", "2024.1.2.", "20240102", "202401021305",
         "2024-01-02T13:05:00+09:00", "2024년 1월 2일", "Tue, 02 Jan 2024 09:30:00 +0900")
  news <- partial_news(data.frame(text = "t", date = x), quiet = TRUE)
  expect_equal(news$date, rep(as.Date("2024-01-02"), length(x)))
  expect_warning(news <- partial_news(data.frame(text = "t", date = c("bad", "2024-01-02")), quiet = TRUE),
                 "could not be parsed")
  expect_equal(news$date, as.Date(c(NA, "2024-01-02")))
})

test_that("as_news validates input", {
  expect_error(as_news(1:3), "data frame")
  expect_error(as_news(data.frame(body = "a"), text = "nope"), "not found")
  expect_error(as_news(data.frame(other = "a")), "text or a keyword")
  expect_error(partial_news(data.frame(text = "a"), text = c("a", "b")), "one column")
})

test_that("read_news applies a named column only to files that have it", {
  d <- new_tempdir()
  write.csv(data.frame(기사제목 = "가", 내용 = "본문"), file.path(d, "a.csv"), row.names = FALSE)
  write.csv(data.frame(title = "나", body = "본문"), file.path(d, "b.csv"), row.names = FALSE)
  news <- quiet_missing(suppressMessages(read_news(d, title = "기사제목")))
  expect_equal(news$title, c("가", "나"))
  expect_error(suppressMessages(read_news(d, title = "없음")), "any file")
})

test_that("as_news warns when title, date or source cannot be detected", {
  expect_warning(knewsr::as_news(data.frame(text = "a", press = "P"), quiet = TRUE),
                 "`title`, `date`", class = "knewsr_missing_columns")
  expect_no_warning(knewsr::as_news(data.frame(text = "a"), title = NA, date = NA, source = NA))
})

test_that("read_news names the file in the missing-column warning", {
  d <- new_tempdir()
  write.csv(data.frame(title = "t", text = "a", date = "2024-01-02"), file.path(d, "a.csv"), row.names = FALSE)
  write.csv(data.frame(title = "t", text = "b", press = "P"), file.path(d, "b.csv"), row.names = FALSE)
  w <- testthat::capture_warnings(suppressMessages(read_news(d)))
  expect_equal(length(w), 2)
  expect_match(w[1], "^a\\.csv: .*`source`")
  expect_match(w[2], "^b\\.csv: .*`date`")
  expect_warning(suppressMessages(read_news(file.path(d, "a.csv"))), "^a\\.csv: ",
                 class = "knewsr_missing_columns")
})
