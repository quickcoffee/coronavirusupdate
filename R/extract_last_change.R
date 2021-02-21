extract_last_change <- function(.episode_html) {
  .episode_html %>%
    rvest::html_node(css = ".lastchanged") %>%
    rvest::html_text() %>%
    stringr::str_remove(pattern = "[:alpha:]+[:punct:]") %>%
    stringr::str_remove(pattern = "Uhr") %>%
    stringr::str_squish() %>%
    lubridate::dmy_hm()
}
