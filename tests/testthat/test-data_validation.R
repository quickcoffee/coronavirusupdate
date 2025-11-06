# Tests for data validation and structure

test_that("coronavirusupdate_transcripts data has correct structure", {
  # Load the package data
  data("coronavirusupdate_transcripts", package = "coronavirusupdate")

  # Check that the required columns exist
  required_cols <- c("title", "link", "episode_no", "speaker", "text",
                     "paragraph_no", "last_change", "duration_episode")

  expect_true(all(required_cols %in% names(coronavirusupdate_transcripts)))

  # Check column types
  expect_type(coronavirusupdate_transcripts$title, "character")
  expect_type(coronavirusupdate_transcripts$link, "character")
  expect_type(coronavirusupdate_transcripts$episode_no, "integer")
  expect_type(coronavirusupdate_transcripts$speaker, "character")
  expect_type(coronavirusupdate_transcripts$text, "character")
  expect_type(coronavirusupdate_transcripts$paragraph_no, "integer")
  expect_s3_class(coronavirusupdate_transcripts$last_change, "POSIXct")
  expect_type(coronavirusupdate_transcripts$duration_episode, "character")
})

test_that("episode numbers are valid", {
  data("coronavirusupdate_transcripts", package = "coronavirusupdate")

  # Episode numbers should be positive integers
  expect_true(all(coronavirusupdate_transcripts$episode_no > 0))

  # No duplicate episode_no + paragraph_no combinations
  dup_check <- coronavirusupdate_transcripts %>%
    dplyr::count(episode_no, paragraph_no) %>%
    dplyr::filter(n > 1)

  expect_equal(nrow(dup_check), 0)
})

test_that("text content is non-empty", {
  data("coronavirusupdate_transcripts", package = "coronavirusupdate")

  # Text should not be empty or just whitespace
  expect_true(all(nchar(trimws(coronavirusupdate_transcripts$text)) > 0))
})

test_that("URLs are well-formed", {
  data("coronavirusupdate_transcripts", package = "coronavirusupdate")

  # Links should start with https://
  expect_true(all(grepl("^https://", coronavirusupdate_transcripts$link)))

  # Links should be to ndr.de domain
  expect_true(all(grepl("ndr\\.de", coronavirusupdate_transcripts$link)))
})
