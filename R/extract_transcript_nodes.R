#' Extract transcript paragraph nodes from episode HTML
#'
#' Extracts all paragraph nodes containing the transcript text from an episode's
#' HTML. Uses XPath to find paragraph elements that follow the table of contents.
#'
#' @param .episode_html An xml_document object containing the episode HTML,
#'   typically obtained via \code{xml2::read_html()}
#'
#' @return An xml_nodeset containing all paragraph nodes with transcript content,
#'   or an empty xml_nodeset if no nodes are found or an error occurs
#'
#' @details The function looks for all paragraph siblings that come after the last
#'   anchor element with an href starting with "#" (table of contents markers)
#'
#' @keywords internal
extract_transcript_nodes <- function(.episode_html) {
  tryCatch({
    if (is.null(.episode_html)) {
      warning("Episode HTML is NULL, returning empty node list")
      return(xml2::xml_nodeset())
    }

    nodes <- .episode_html %>%
      # get all siblings of node p after the last node a that starts with # for the href attribute
      rvest::html_nodes(xpath = '//p[a[starts-with(@href, "#")]][last()]/following-sibling::p')

    if (length(nodes) == 0) {
      warning("No transcript nodes found with the specified XPath")
    }

    return(nodes)
  }, error = function(e) {
    warning(paste("Error extracting transcript nodes:", e$message))
    return(xml2::xml_nodeset())
  })
}
