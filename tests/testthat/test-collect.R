naver_page <- function(start, display) {
  ids <- seq(start, length.out = display)
  list(items = lapply(ids, function(i) list(
    title = paste0("<b>예산</b> 기사 ", i, " &quot;속보&quot;"),
    originallink = if (i == 1) "" else paste0("https://www.news", i %% 3, ".co.kr/a/", i),
    link = paste0("https://n.news.naver.com/", i),
    description = "정부가 <b>예산안</b>을 발표했다 &amp; 국회",
    pubDate = "Tue, 02 Jan 2024 09:30:00 +0900"
  )))
}

test_that("collect_naver pages through the API and maps results", {
  skip_if_not_installed("httr2")
  seen <- list()
  httr2::local_mocked_responses(function(req) {
    q <- httr2::url_parse(req$url)$query
    seen[[length(seen) + 1]] <<- q
    expect_equal(httr2::req_get_headers(req, "reveal")$`X-Naver-Client-Id`, "id")
    total <- 150
    start <- as.integer(q$start)
    display <- min(as.integer(q$display), total - start + 1)
    httr2::response_json(body = naver_page(start, display))
  })
  news <- collect_naver("예산", n = 150, client_id = "id", client_secret = "secret")
  expect_equal(nrow(news), 150)
  expect_equal(vapply(seen, `[[`, "", "start"), c("1", "101"))
  expect_equal(seen[[2]]$display, "50")
  expect_equal(news$title[1], "예산 기사 1 \"속보\"")
  expect_equal(news$text[1], "정부가 예산안 을 발표했다 & 국회")
  expect_equal(news$date[1], as.Date("2024-01-02"))
  expect_equal(news$doc_id[1], "https://n.news.naver.com/1")
  expect_equal(news$source[2], "news2.co.kr")
  expect_equal(news$query[1], "예산")
})

test_that("collect_naver stops when results run out", {
  skip_if_not_installed("httr2")
  httr2::local_mocked_responses(function(req) httr2::response_json(body = naver_page(1, 5)))
  expect_equal(nrow(collect_naver("x", n = 500, client_id = "id", client_secret = "s")), 5)
  httr2::local_mocked_responses(function(req) httr2::response_json(body = list(items = list())))
  expect_error(collect_naver("x", client_id = "id", client_secret = "s"), "No Naver")
})

test_that("collect_naver validates input", {
  skip_if_not_installed("httr2")
  expect_error(collect_naver("x", client_id = "", client_secret = ""), "credentials")
  expect_error(collect_naver("", client_id = "id", client_secret = "s"))
  expect_error(collect_naver("x", sort = "bogus", client_id = "id", client_secret = "s"))
})

test_that("collect_rss reads a real RSS 2.0 feed", {
  skip_if_not_installed("xml2")
  news <- collect_rss(system.file("extdata", "sample_rss.xml", package = "knewsr"))
  expect_equal(nrow(news), 5)
  expect_equal(unique(news$source), "연합뉴스 최신기사")
  expect_equal(unique(news$date), as.Date("2026-11-14"))
  expect_match(news$doc_id, "^https://www\\.yna\\.co\\.kr/view/")
  expect_equal(news$title[4], "이탈리아, 메타에 1조 과징금…\"이용자 사진에 무단 접근\"")
  expect_true(all(is.na(news$text)))
})

test_that("collect_rss prefers content:encoded and decodes HTML", {
  skip_if_not_installed("xml2")
  rss <- tempfile(fileext = ".xml")
  writeLines(c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<rss version="2.0" xmlns:content="http://purl.org/rss/1.0/modules/content/"><channel>',
    '<title>테스트 피드</title>',
    '<item><title>[속보] 제목1</title><link>https://t.kr/1</link>',
    '<pubDate>Tue, 02 Jan 2024 09:30:00 +0900</pubDate>',
    '<description><![CDATA[<p>요약</p>]]></description>',
    '<content:encoded><![CDATA[<p>전체 <b>본문</b>입니다.</p>]]></content:encoded></item>',
    '<item><title>제목2</title><link>https://t.kr/2</link>',
    '<description>심사 &amp;quot;신속 처리&amp;quot;</description></item>',
    '</channel></rss>'
  ), rss)
  news <- collect_rss(rss)
  expect_equal(news$text, c("전체 본문 입니다.", "심사 \"신속 처리\""))
  expect_equal(news$doc_id, c("https://t.kr/1", "https://t.kr/2"))
  expect_equal(news$date, as.Date(c("2024-01-02", NA)))
})

test_that("collect_rss reads Atom feeds and drops repeated items", {
  skip_if_not_installed("xml2")
  atom <- tempfile(fileext = ".xml")
  writeLines(c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<feed xmlns="http://www.w3.org/2005/Atom"><title>아톰 뉴스</title>',
    '<entry><title>제목</title><link href="https://a.kr/1"/><id>tag:a,1</id>',
    '<updated>2024-02-01T10:00:00Z</updated><summary>요약 &lt;b&gt;강조&lt;/b&gt;</summary></entry>',
    '</feed>'
  ), atom)
  news <- collect_rss(c(atom, atom))
  expect_equal(nrow(news), 1)
  expect_equal(news$source, "아톰 뉴스")
  expect_equal(news$link, "https://a.kr/1")
  expect_equal(news$doc_id, "tag:a,1")
  expect_equal(news$text, "요약 강조")
  expect_equal(news$date, as.Date("2024-02-01"))
})

test_that("collect_rss validates input", {
  skip_if_not_installed("xml2")
  empty <- tempfile(fileext = ".xml")
  writeLines("<rss><channel><title>t</title></channel></rss>", empty)
  expect_error(collect_rss(empty), "no items")
  expect_error(collect_rss(1))
})
