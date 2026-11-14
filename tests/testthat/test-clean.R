test_that("clean_news strips headers, bylines, emails, urls and symbols", {
  news <- partial_news(data.frame(
    title = "[속보] 정부, 예산안 발표",
    text = "(서울=연합뉴스) 홍길동 기자 = 정부가 발표했다. hong@example.com https://a.kr/x ★"
  ))
  out <- clean_news(news)
  expect_equal(out$title, "정부, 예산안 발표")
  expect_equal(out$text, "정부가 발표했다.")
})

test_that("clean_news only removes what is asked", {
  news <- partial_news(data.frame(title = "[사설] 제목", text = "본문 a@b.com"))
  out <- clean_news(news, remove = "email")
  expect_equal(out$title, "[사설] 제목")
  expect_equal(out$text, "본문")
})

test_that("clean_news validates input", {
  expect_error(clean_news(data.frame(x = 1)), "as_news")
  expect_error(clean_news(sample_news(), remove = "bogus"))
})

test_that("stopwords_ko returns Korean words", {
  sw <- stopwords_ko()
  expect_type(sw, "character")
  expect_true("기자" %in% sw)
})
