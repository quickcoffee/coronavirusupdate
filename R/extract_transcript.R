#' Extract full transcript from an episode URL
#'
#' Main function that orchestrates the extraction of podcast transcript data from
#' a single episode URL. Extracts speaker names, paragraph text, metadata including
#' last change date and episode duration. Includes polite scraping with random delays.
#'
#' @param .episode_url Character string containing the full URL of a podcast episode
#'   page on the NDR website
#'
#' @return A nested tibble with one row containing:
#'   \describe{
#'     \item{speaker}{Character vector of speaker names}
#'     \item{text}{Character vector of transcript text paragraphs}
#'     \item{paragraph_no}{Integer vector of paragraph numbers}
#'     \item{last_change}{POSIXct datetime when the transcript was last modified}
#'     \item{duration_episode}{Character string of episode duration}
#'   }
#'   Returns an empty tibble with the same structure if no transcript is found.
#'
#' @details The function implements polite scraping with random delays (0.5-2 seconds)
#'   between requests to avoid overloading the server. It extracts all transcript
#'   components and combines them into a tidy data structure.
#'
#' @examples
#' \dontrun{
#' extract_transcript("https://www.ndr.de/nachrichten/info/76-Coronavirus-Update-AstraZeneca-Impfstoff-besser-als-sein-Ruf,podcastcoronavirus288.html")
#' }
#'
#' @keywords internal
extract_transcript <- function(.episode_url) {
  # Validate input
  if (missing(.episode_url) || is.null(.episode_url) || !is.character(.episode_url)) {
    stop("Invalid episode URL: must be a character string")
  }

  tryCatch({
    # sleep to be polite
    Sys.sleep(stats::runif(1, min = 0.5, max = 2))

    # get html for episode_url
    episode_html <- xml2::read_html(.episode_url)

    if (is.null(episode_html)) {
      stop(paste("Failed to read HTML from URL:", .episode_url))
    }

    # extract all information via functions
    episode_last_change <- extract_last_change(episode_html)
    episode_length <- extract_episode_length(episode_html)

    transcript_nodes <- extract_transcript_nodes(episode_html)

    if (length(transcript_nodes) == 0) {
      warning(paste("No transcript nodes found for URL:", .episode_url))
      return(tibble::tibble(
        speaker = character(0),
        text = character(0),
        paragraph_no = integer(0),
        last_change = lubridate::as_datetime(NA),
        duration_episode = character(0)
      ))
    }

    speaker_names <- extract_speaker_name(transcript_nodes)
    speaker_text <- rvest::html_text(transcript_nodes, trim = TRUE)

    # put it all together and some clean up on the speaker column
    tibble::tibble(
      speaker = speaker_names,
      text = speaker_text
    ) %>%
      tidyr::fill(speaker, .direction = "down") %>%
      tidyr::drop_na() %>%
      dplyr::mutate(
        text = stringr::str_remove(text, pattern = speaker) %>%
          stringr::str_remove(pattern = "^\\:") %>%
          stringr::str_squish(),
        paragraph_no = dplyr::row_number()
      ) %>%
      tidyr::nest(speaker = speaker, text = text, paragraph_no = paragraph_no) %>%
      dplyr::mutate(
        last_change = episode_last_change,
        duration_episode = episode_length
      )
  }, error = function(e) {
    stop(paste("Error extracting transcript from", .episode_url, ":", e$message))
  })
}
