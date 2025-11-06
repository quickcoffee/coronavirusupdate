#' Extract last change date from episode HTML
#'
#' Extracts and parses the last modification date of a podcast episode transcript
#' from the HTML content. The date is parsed from German date format.
#'
#' @param .episode_html An xml_document object containing the episode HTML,
#'   typically obtained via \code{xml2::read_html()}
#'
#' @return A POSIXct datetime object representing when the transcript was last
#'   modified, or NA if the date cannot be extracted or parsed
#'
#' @keywords internal
extract_last_change <- function(.episode_html) {
  tryCatch({
    if (is.null(.episode_html)) {
      warning("Episode HTML is NULL, returning NA for last change date")
      return(lubridate::as_datetime(NA))
    }

    result <- .episode_html %>%
      rvest::html_node(css = ".lastchanged") %>%
      rvest::html_text() %>%
      stringr::str_remove(pattern = "[:alpha:]+[:punct:]") %>%
      stringr::str_remove(pattern = "Uhr") %>%
      stringr::str_squish() %>%
      lubridate::dmy_hm()

    if (is.na(result)) {
      warning("Could not parse last change date from HTML")
    }

    return(result)
  }, error = function(e) {
    warning(paste("Error extracting last change date:", e$message))
    return(lubridate::as_datetime(NA))
  })
}
