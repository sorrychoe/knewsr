# knewsr 0.1.0

First release.

## Input and collection

* `read_news()` reads Excel, CSV/TSV (UTF-8 or CP949), JSON and JSONL news
  files, or a whole directory of them; `read_bigkinds()` is an alias for
  BigKinds exports.
* `as_news()` converts any news data frame to one standard schema
  (`doc_id`, `date`, `source`, `title`, `text`, `keyword`). It detects common
  column names (BigKinds headers, `headline`, `body`, `content`, `pubDate`,
  `press`, ...), parses many date formats element by element and warns about
  values it cannot parse, normalizes keyword separators and list columns, and
  can drop repeated articles (`dedup = TRUE`). It warns when no `title`,
  `date` or `source` column is found, naming the file when called from
  `read_news()`; pass `NA` for a field to leave it empty without a warning.
* `collect_naver()` collects articles from the Naver News Search API.
* `collect_rss()` collects articles from RSS 2.0 and Atom feeds.

## Preprocessing

* `clean_news()` removes bracketed headers, bylines and datelines, e-mail
  addresses, URLs and special characters.
* `stopwords_ko()` returns a default Korean news stopword list.
* `tokenize_ko()` builds a token table from keyword lists or, with
  RcppMeCab and MeCab-ko, from text; `ngrams_ko()` builds n-grams.

## Analysis

* `count_terms()`, `tf_idf()` and `summarise_corpus()`.
* `as_dtm()` and `as_tdm()` return sparse `Matrix` objects.
* `cooccurrence()` counts co-occurrence within documents or token windows.
* `keyness()` compares groups with the log-likelihood ratio (G2, default)
  or chi-square.
* `term_trend()` counts terms per day, week or month.

## Visualization

* `plot_terms()`, `plot_keyness()`, `plot_trend()`, `plot_wordcloud()` and
  `plot_network()` return ggplot objects.
