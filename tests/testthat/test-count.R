test_that("count_terms counts tokens and documents", {
  tk <- toy_tokens()
  expect_equal(count_terms(tk)$n, c(3, 2, 1))
  expect_equal(count_terms(tk, by_doc = TRUE)$n[1:2], c(2, 2))
  by_src <- count_terms(tk, by = "source")
  expect_equal(by_src$n[by_src$source == "A" & by_src$token == "x"], 2)
})

test_that("count_terms validates input", {
  expect_error(count_terms(data.frame(a = 1)), "tokenize_ko")
  expect_error(count_terms(toy_tokens(), by = "nope"), "not found")
})

test_that("tf_idf matches the textbook definition", {
  res <- tf_idf(toy_tokens())
  row <- res[res$doc_id == "1" & res$token == "x", ]
  expect_equal(row$tf, 2 / 3)
  expect_equal(row$idf, log(3 / 2))
  expect_equal(row$tf_idf, 2 / 3 * log(3 / 2))
  expect_equal(nrow(tf_idf(toy_tokens(), by = "source")), 4)
  expect_error(tf_idf(toy_tokens(), by = "nope"))
})

test_that("summarise_corpus counts articles and dates", {
  news <- sample_news()
  all <- summarise_corpus(news)
  expect_equal(all$n, 300)
  expect_equal(all$first_date, as.Date("2026-08-01"))
  by_src <- summarise_corpus(news, by = "source")
  expect_equal(sum(by_src$n), 300)
  expect_true(is.na(summarise_corpus(partial_news(data.frame(text = "a")))$first_date))
  expect_error(summarise_corpus(news, by = "nope"), "not found")
})
