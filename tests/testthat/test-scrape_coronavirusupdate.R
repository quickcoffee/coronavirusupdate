# Tests for main scraping function

test_that("scrape_coronavirusupdate validates input URL", {
  expect_error(
    scrape_coronavirusupdate(NULL),
    "Invalid episodes URL"
  )

  expect_error(
    scrape_coronavirusupdate(123),
    "Invalid episodes URL"
  )

  expect_error(
    scrape_coronavirusupdate(),
    "Invalid episodes URL"
  )
})

test_that("scrape_coronavirusupdate handles invalid URL gracefully", {
  expect_error(
    scrape_coronavirusupdate(
      .all_episodes_url = "https://invalid-url-12345.com",
      .target_path_rds = tempfile(fileext = ".rds"),
      .target_path_rda = tempfile(fileext = ".rda")
    ),
    "Error fetching podcast homepage"
  )
})

test_that("scrape_coronavirusupdate creates output files", {
  skip("Skipping live scraping test - requires network and may be slow")

  # This test would be run manually or in a separate integration test suite
  temp_rds <- tempfile(fileext = ".rds")
  temp_rda <- tempfile(fileext = ".rda")

  scrape_coronavirusupdate(
    .all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
    .target_path_rds = temp_rds,
    .target_path_rda = temp_rda,
    .force_complete_scrape = FALSE
  )

  expect_true(file.exists(temp_rds))
  expect_true(file.exists(temp_rda))

  # Cleanup
  unlink(temp_rds)
  unlink(temp_rda)
})

test_that("speaker name normalization works correctly", {
  # Test that the case_when logic in scrape_coronavirusupdate normalizes names
  # This would ideally be extracted into a separate testable function

  test_names <- c("Hennig", "Drosten", "Ciesek", "Schulmann")
  expected_names <- c("Korinna Hennig", "Christian Drosten", "Sandra Ciesek", "Beke Schulmann")

  # Note: This test documents expected behavior but cannot directly test
  # the internal case_when logic without refactoring
  # Consider extracting speaker normalization into a separate function
})
