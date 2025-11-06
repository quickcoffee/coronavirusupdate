# Tests for extraction helper functions

test_that("extract_episode_length handles NULL input gracefully", {
  expect_warning(result <- extract_episode_length(NULL))
  expect_equal(result, NA_character_)
})

test_that("extract_last_change handles NULL input gracefully", {
  expect_warning(result <- extract_last_change(NULL))
  expect_true(is.na(result))
  expect_s3_class(result, "POSIXct")
})

test_that("extract_speaker_name handles NULL input gracefully", {
  expect_warning(result <- extract_speaker_name(NULL))
  expect_equal(result, character(0))
})

test_that("extract_speaker_name handles empty nodeset gracefully", {
  empty_nodeset <- xml2::xml_nodeset()
  expect_warning(result <- extract_speaker_name(empty_nodeset))
  expect_equal(result, character(0))
})

test_that("extract_transcript_nodes handles NULL input gracefully", {
  expect_warning(result <- extract_transcript_nodes(NULL))
  expect_s3_class(result, "xml_nodeset")
  expect_equal(length(result), 0)
})

test_that("extract_transcript validates input", {
  expect_error(
    extract_transcript(NULL),
    "Invalid episode URL"
  )

  expect_error(
    extract_transcript(123),
    "Invalid episode URL"
  )
})

test_that("extract_transcript handles invalid URLs gracefully", {
  expect_error(
    extract_transcript("https://invalid-url-that-does-not-exist-12345.com"),
    "Error extracting transcript"
  )
})
