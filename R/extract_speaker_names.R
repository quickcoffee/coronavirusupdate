#' Extract speaker names from transcript nodes
#'
#' Extracts and cleans speaker names from HTML transcript nodes. Speaker names
#' are identified by strong tags and specific text patterns (capitalized text
#' ending with a colon). Includes manual fixes for known edge cases.
#'
#' @param .transcript_nodes An xml_nodeset containing the transcript paragraph
#'   nodes, typically obtained via \code{extract_transcript_nodes()}
#'
#' @return A character vector of speaker names, with NA for paragraphs without
#'   identified speakers, or an empty character vector if extraction fails
#'
#' @keywords internal
extract_speaker_name <- function(.transcript_nodes) {
  tryCatch({
    if (is.null(.transcript_nodes) || length(.transcript_nodes) == 0) {
      warning("Transcript nodes are NULL or empty, returning empty character vector")
      return(character(0))
    }

    rvest::html_node(x = .transcript_nodes, xpath = "strong") %>%
      rvest::html_text(trim = TRUE) %>%
      stringr::str_squish() %>%
      stringr::str_extract(pattern = "^[:upper:][:alpha:]+.+\\:$") %>%
      stringr::str_remove(pattern = ":") %>%
      # manual fix for episode 38
      stringr::str_replace(pattern = "Eine Bitte an unsere Hörer", replacement = "Korinna Hennig") %>%
      stringr::str_squish() %>%
      dplyr::na_if(y = "")
  }, error = function(e) {
    warning(paste("Error extracting speaker names:", e$message))
    return(character(0))
  })
}
