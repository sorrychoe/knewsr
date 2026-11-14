test_that("tokenize_ko splits keywords and filters tokens", {
  news <- partial_news(data.frame(keyword = c("정부,기자,a,국회, 정부", NA), source = c("S", "T")))
  tk <- tokenize_ko(news, keep = "source")
  expect_named(tk, c("doc_id", "source", "token"))
  expect_equal(tk$token, c("정부", "국회", "정부"))
  expect_equal(tk$source, rep("S", 3))
})

test_that("tokenize_ko validates input", {
  expect_error(tokenize_ko(data.frame(x = 1)), "as_news")
  expect_error(tokenize_ko(sample_news(), keep = "nope"), "Unknown")
  expect_error(tokenize_ko(sample_news(), field = "bogus"))
})

test_that("tokenize_ko analyses text with MeCab-ko", {
  dic <- mecab_ko_dic()
  news <- partial_news(data.frame(text = c("대통령이 국회에서 연설했다", "", NA)))
  tk <- tokenize_ko(news, field = "text", dic = dic)
  expect_equal(tk$token, c("대통령", "국회", "연설"))
  expect_equal(unique(tk$doc_id), "1")
})

test_that("ngrams_ko joins consecutive tokens within documents", {
  news <- partial_news(data.frame(keyword = c("가가,나나,다다", "라라,마마")))
  ng <- ngrams_ko(news, n = 2)
  expect_equal(ng$token, c("가가 나나", "나나 다다", "라라 마마"))
  expect_equal(ng$doc_id, c("1", "1", "2"))
  expect_equal(nrow(ngrams_ko(news, n = 3)), 1)
  expect_error(ngrams_ko(news, n = 0))
})
