extract_transcript_nodes <- function(.episode_html) {
  .episode_html %>%
    # get all siblings of node p after the last node a that starts with # for the href attribute
    rvest::html_nodes(xpath = '//p[a[starts-with(@href, "#")]][last()]/following-sibling::p')
}
