#' Extract episode length from episode HTML
#'
#' Extracts the duration of a podcast episode from the HTML content.
#' The duration is typically found in parentheses in the h2 element.
#'
#' @param .episode_html An xml_document object containing the episode HTML,
#'   typically obtained via \code{xml2::read_html()}
#'
#' @return A character string containing the episode duration, or NA_character_
#'   if the duration cannot be extracted
#'
#' @note TODO: Consider getting episode length from iframe player rather than html_node
#'   for more reliable extraction
#'
#' @keywords internal
extract_episode_length <- function(.episode_html) {
  tryCatch({
    if (is.null(.episode_html)) {
      warning("Episode HTML is NULL, returning NA for episode length")
      return(NA_character_)
    }

    result <- .episode_html %>%
      rvest::html_node(css = ".textcontent h2") %>%
      rvest::html_text() %>%
      stringr::str_extract(pattern = "(?<=\\().{2,20}(?=\\)$)")

    if (is.na(result) || length(result) == 0) {
      warning("Could not extract episode length from HTML")
      return(NA_character_)
    }

    return(result)
  }, error = function(e) {
    warning(paste("Error extracting episode length:", e$message))
    return(NA_character_)
  })
}
