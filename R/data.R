#' BigKinds sample: news mentioning President Lee (August 2026)
#'
#' A random sample of 300 articles from a BigKinds export, in the BigKinds
#' column layout. Only metadata, headlines and the BigKinds keyword lists are
#' included; article bodies, bylines and URLs were removed. Convert it to the
#' standard schema with [as_news()].
#'
#' @format A tibble with 300 rows and 5 columns:
#' \describe{
#'   \item{\code{뉴스 식별자}}{BigKinds article id.}
#'   \item{\code{일자}}{Publication date (\code{YYYYMMDD}).}
#'   \item{\code{언론사}}{News outlet.}
#'   \item{\code{제목}}{Article headline.}
#'   \item{\code{키워드}}{Comma-separated keywords extracted by BigKinds.}
#' }
#' @source BigKinds, Korea Press Foundation. \url{https://www.bigkinds.or.kr/}
#' @keywords datasets
"president_lee_2026_08"
