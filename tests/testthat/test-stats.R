test_that("keyness matches chi-square and G2 by hand", {
  tk <- toy_tokens()
  k <- keyness(tk, group = "source", target = "A")
  # x: target 2/3, reference 1/3
  o <- c(2, 1, 1, 2)
  e <- c(1.5, 1.5, 1.5, 1.5)
  expect_equal(k$keyness[k$token == "x"], 2 * sum(o * log(o / e)))
  chi <- keyness(tk, "source", "A", measure = "chi2")
  expect_equal(chi$keyness[chi$token == "x"], sum((o - e)^2 / e))
  expect_lt(k$keyness[k$token == "z"], 0)
})

test_that("keyness validates input", {
  tk <- toy_tokens()
  expect_error(keyness(tk, "source", "C"), "target")
  expect_error(keyness(tk, "nope", "A"), "not found")
  expect_error(keyness(tk, "source", "A", reference = "A"), "reference")
})

test_that("term_trend counts terms per period with zeros", {
  news <- partial_news(data.frame(
    keyword = c("x,y", "x", "y"),
    date = c("20240101", "20240102", "20240215")
  ))
  tk <- tokenize_ko(news, min_nchar = 1)
  tr <- term_trend(tk, news, terms = "x", unit = "month")
  expect_equal(tr$date, as.Date(c("2024-01-01", "2024-02-01")))
  expect_equal(tr$n, c(2, 0))
  wk <- term_trend(tk, news, terms = c("x", "y"), unit = "week")
  expect_equal(unique(wk$date)[1], as.Date("2024-01-01"))
  expect_error(term_trend(tk, news, terms = 1))
})
