# TODO get episode length from iframe player rather than html_node
extract_episode_length <- function(.episode_html) {
  .episode_html %>%
    rvest::html_node(css = ".textcontent h2") %>%
    rvest::html_text() %>%
    stringr::str_extract(pattern = "(?<=\\().{2,20}(?=\\)$)")
}
