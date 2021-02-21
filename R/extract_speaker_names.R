extract_speaker_name <- function(.transcript_nodes) {
  rvest::html_node(x = .transcript_nodes, xpath = "strong") %>%
    rvest::html_text(trim = TRUE) %>%
    stringr::str_squish() %>%
    stringr::str_extract(pattern = "^[:upper:][:alpha:]+.+\\:$") %>%
    stringr::str_remove(pattern = ":") %>%
    # manual fix for episode 38
    stringr::str_replace(pattern = "Eine Bitte an unsere Hörer", replacement = "Korinna Hennig") %>%
    stringr::str_squish() %>%
    dplyr::na_if(y = "")
}
