#' BigKinds sample: news mentioning President Lee (August 2026)
#'
#' A random sample of 300 articles from a BigKinds export, in the BigKinds
#' column layout. Only metadata, headlines and the BigKinds keyword lists are
#' included; article bodies, bylines and URLs were removed. Convert it to the
#' standard schema with [as_news()].
#'
#' @format A tibble with 300 rows and 5 columns:
#' \describe{
#'   \item{\ifelse{latex}{news id}{뉴스 식별자}}{BigKinds article id.}
#'   \item{\ifelse{latex}{date}{일자}}{Publication date (\code{YYYYMMDD}).}
#'   \item{\ifelse{latex}{outlet}{언론사}}{News outlet.}
#'   \item{\ifelse{latex}{title}{제목}}{Article headline.}
#'   \item{\ifelse{latex}{keywords}{키워드}}{Comma-separated keywords extracted by BigKinds.}
#' }
#' @source BigKinds, Korea Press Foundation. \url{https://www.bigkinds.or.kr/}
#' @keywords datasets
"president_lee_2026_08"
