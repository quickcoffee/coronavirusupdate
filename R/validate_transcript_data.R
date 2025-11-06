#' Validate transcript data structure and content
#'
#' Performs validation checks on scraped transcript data to ensure data quality
#' and integrity. Checks for required columns, proper data types, valid content,
#' and logical consistency.
#'
#' @param data A tibble containing transcript data to validate
#' @param strict Logical indicating whether to stop on validation failures (TRUE)
#'   or just warn (FALSE). Default: FALSE
#'
#' @return The input data (invisibly) if validation passes, or stops/warns if
#'   validation fails depending on strict parameter
#'
#' @keywords internal
validate_transcript_data <- function(data, strict = FALSE) {
  validation_errors <- character()

  # Check that data is a data frame/tibble
  if (!is.data.frame(data)) {
    validation_errors <- c(validation_errors, "Data must be a data frame or tibble")
  }

  # Check for required columns
  required_cols <- c("title", "link", "episode_no", "speaker", "text",
                     "paragraph_no", "last_change", "duration_episode")

  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0) {
    validation_errors <- c(
      validation_errors,
      paste("Missing required columns:", paste(missing_cols, collapse = ", "))
    )
  }

  # If we have validation errors at this point, return early
  if (length(validation_errors) > 0) {
    msg <- paste("Data validation failed:", paste(validation_errors, collapse = "; "))
    if (strict) {
      stop(msg)
    } else {
      warning(msg)
      return(invisible(data))
    }
  }

  # Check data types
  if (!is.integer(data$episode_no) && !is.numeric(data$episode_no)) {
    validation_errors <- c(validation_errors, "episode_no must be integer or numeric")
  }

  if (!is.integer(data$paragraph_no) && !is.numeric(data$paragraph_no)) {
    validation_errors <- c(validation_errors, "paragraph_no must be integer or numeric")
  }

  if (!is.character(data$title)) {
    validation_errors <- c(validation_errors, "title must be character")
  }

  if (!is.character(data$link)) {
    validation_errors <- c(validation_errors, "link must be character")
  }

  if (!is.character(data$speaker)) {
    validation_errors <- c(validation_errors, "speaker must be character")
  }

  if (!is.character(data$text)) {
    validation_errors <- c(validation_errors, "text must be character")
  }

  # Check for empty data
  if (nrow(data) == 0) {
    validation_errors <- c(validation_errors, "Data contains no rows")
  }

  # Check for valid episode numbers (should be positive)
  if (any(data$episode_no <= 0, na.rm = TRUE)) {
    validation_errors <- c(validation_errors, "episode_no contains non-positive values")
  }

  # Check for empty text content
  empty_text <- sum(nchar(trimws(data$text)) == 0, na.rm = TRUE)
  if (empty_text > 0) {
    validation_errors <- c(
      validation_errors,
      paste0(empty_text, " rows have empty text content")
    )
  }

  # Check for valid URLs
  invalid_urls <- sum(!grepl("^https?://", data$link), na.rm = TRUE)
  if (invalid_urls > 0) {
    validation_errors <- c(
      validation_errors,
      paste0(invalid_urls, " rows have invalid URLs")
    )
  }

  # Check for duplicate episode_no + paragraph_no combinations
  dup_check <- data %>%
    dplyr::count(episode_no, paragraph_no) %>%
    dplyr::filter(n > 1)

  if (nrow(dup_check) > 0) {
    validation_errors <- c(
      validation_errors,
      paste0(nrow(dup_check), " duplicate episode_no + paragraph_no combinations found")
    )
  }

  # Report validation results
  if (length(validation_errors) > 0) {
    msg <- paste("Data validation failed:", paste(validation_errors, collapse = "; "))
    if (strict) {
      stop(msg)
    } else {
      warning(msg)
    }
  } else {
    message(paste0(
      "Data validation passed: ",
      nrow(data), " rows, ",
      length(unique(data$episode_no)), " episodes"
    ))
  }

  invisible(data)
}
