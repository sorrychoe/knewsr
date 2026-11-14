## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
* Possibly misspelled words in DESCRIPTION: 'TF' and 'IDF' are parts of the
  standard abbreviation TF-IDF (term frequency-inverse document frequency),
  and 'keyness' is a standard term in corpus linguistics.

## Test environments

* local: Ubuntu 26.04 (WSL2), R 4.6.1
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release, oldrel-1)
* win-builder: R-devel

## Notes for reviewers

* Two examples use `\dontrun{}` because they cannot run unattended:
  `collect_naver()` needs personal Naver Open API credentials, and the
  `tokenize_ko(field = "title")` example needs the MeCab-ko system library
  and dictionary (used through the suggested package 'RcppMeCab').
  Tests that need them are skipped when they are unavailable; the API tests
  use mocked responses and never access the network.
* The bundled dataset `president_lee_2026_08` holds only metadata, headlines
  and keyword lists for 300 articles; article bodies, bylines and URLs were
  removed.
