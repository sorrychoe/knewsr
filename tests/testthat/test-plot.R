test_that("plot helpers return ggplot objects", {
  skip_if_not_installed("ggplot2")
  tk <- toy_tokens()
  expect_s3_class(plot_terms(count_terms(tk)), "ggplot")
  expect_s3_class(plot_keyness(keyness(tk, "source", "A")), "ggplot")
  news <- partial_news(data.frame(keyword = c("xx", "yy"), date = c("20240101", "20240102")))
  expect_s3_class(plot_trend(term_trend(tokenize_ko(news), news, "xx")), "ggplot")
})

test_that("optional plot helpers return ggplot objects", {
  skip_if_not_installed("ggwordcloud")
  skip_if_not_installed("ggraph")
  skip_if_not_installed("igraph")
  tk <- toy_tokens()
  expect_s3_class(plot_wordcloud(count_terms(tk)), "ggplot")
  expect_s3_class(plot_network(cooccurrence(tk)), "ggplot")
})

test_that("plot helpers validate input", {
  skip_if_not_installed("ggplot2")
  expect_error(plot_terms(data.frame(a = 1)), "not found")
  expect_error(plot_keyness(data.frame(token = "a")), "not found")
})
