#' helper function that extracts the transcripts from a episode url including the speaker, paragraph no and the last chnage and episode lenth.
#'
#' @param .episode full url of an episode
#' @return tibble with transcripts of episode provided
#' @examples
#' \dontrun{}
#' extract_transcript("https://www.ndr.de/nachrichten/info/76-Coronavirus-Update-AstraZeneca-Impfstoff-besser-als-sein-Ruf,podcastcoronavirus288.html")
extract_transcript <- function(.episode_url) {
  # sleep to be polite
  Sys.sleep(stats::runif(1, min = 0.5, max = 2))

  # get html for episode_url
  episode_html <- xml2::read_html(.episode_url)

  # extract all information via functions
  episode_last_change <- extract_last_change(episode_html)
  episode_length <- extract_episode_length(episode_html)

  transcript_nodes <- extract_transcript_nodes(episode_html)
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
}
