# Changelog

## knewsr 0.1.0

First release.

### Input and collection

- [`read_news()`](https://sorrychoe.github.io/knewsr/reference/read_news.md)
  reads Excel, CSV/TSV (UTF-8 or CP949), JSON and JSONL news files, or a
  whole directory of them;
  [`read_bigkinds()`](https://sorrychoe.github.io/knewsr/reference/read_news.md)
  is an alias for BigKinds exports.
- [`as_news()`](https://sorrychoe.github.io/knewsr/reference/as_news.md)
  converts any news data frame to one standard schema (`doc_id`, `date`,
  `source`, `title`, `text`, `keyword`). It detects common column names
  (BigKinds headers, `headline`, `body`, `content`, `pubDate`, `press`,
  …), parses many date formats element by element and warns about values
  it cannot parse, normalizes keyword separators and list columns, and
  can drop repeated articles (`dedup = TRUE`). It warns when no `title`,
  `date` or `source` column is found, naming the file when called from
  [`read_news()`](https://sorrychoe.github.io/knewsr/reference/read_news.md);
  pass `NA` for a field to leave it empty without a warning.
- [`collect_naver()`](https://sorrychoe.github.io/knewsr/reference/collect_naver.md)
  collects articles from the Naver News Search API.
- [`collect_rss()`](https://sorrychoe.github.io/knewsr/reference/collect_rss.md)
  collects articles from RSS 2.0 and Atom feeds.

### Preprocessing

- [`clean_news()`](https://sorrychoe.github.io/knewsr/reference/clean_news.md)
  removes bracketed headers, bylines and datelines, e-mail addresses,
  URLs and special characters.
- [`stopwords_ko()`](https://sorrychoe.github.io/knewsr/reference/stopwords_ko.md)
  returns a default Korean news stopword list.
- [`tokenize_ko()`](https://sorrychoe.github.io/knewsr/reference/tokenize_ko.md)
  builds a token table from keyword lists or, with RcppMeCab and
  MeCab-ko, from text;
  [`ngrams_ko()`](https://sorrychoe.github.io/knewsr/reference/ngrams_ko.md)
  builds n-grams.

### Analysis

- [`count_terms()`](https://sorrychoe.github.io/knewsr/reference/count_terms.md),
  [`tf_idf()`](https://sorrychoe.github.io/knewsr/reference/tf_idf.md)
  and
  [`summarise_corpus()`](https://sorrychoe.github.io/knewsr/reference/summarise_corpus.md).
- [`as_dtm()`](https://sorrychoe.github.io/knewsr/reference/as_dtm.md)
  and
  [`as_tdm()`](https://sorrychoe.github.io/knewsr/reference/as_dtm.md)
  return sparse `Matrix` objects.
- [`cooccurrence()`](https://sorrychoe.github.io/knewsr/reference/cooccurrence.md)
  counts co-occurrence within documents or token windows.
- [`keyness()`](https://sorrychoe.github.io/knewsr/reference/keyness.md)
  compares groups with the log-likelihood ratio (G2, default) or
  chi-square.
- [`term_trend()`](https://sorrychoe.github.io/knewsr/reference/term_trend.md)
  counts terms per day, week or month.

### Visualization

- [`plot_terms()`](https://sorrychoe.github.io/knewsr/reference/plot_helpers.md),
  [`plot_keyness()`](https://sorrychoe.github.io/knewsr/reference/plot_helpers.md),
  [`plot_trend()`](https://sorrychoe.github.io/knewsr/reference/plot_helpers.md),
  [`plot_wordcloud()`](https://sorrychoe.github.io/knewsr/reference/plot_helpers.md)
  and
  [`plot_network()`](https://sorrychoe.github.io/knewsr/reference/plot_helpers.md)
  return ggplot objects.
