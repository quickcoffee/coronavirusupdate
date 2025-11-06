#' Scrape NDR Coronavirus-Update podcast transcripts
#'
#' Main function to scrape all available transcripts from the NDR Coronavirus-Update
#' podcast website. Supports incremental scraping (only fetches new episodes) and
#' saves data in multiple formats (RDS, RDA, Parquet). Includes automatic speaker
#' name normalization to handle typos and variants.
#'
#' @param .all_episodes_url Character string containing the URL of the page listing
#'   all podcast episodes. Default is the NDR podcast overview page.
#' @param .target_path_rds Character string specifying the file path for saving
#'   the RDS format. Default: "data/coronavirusupdate_transcripts.rds"
#' @param .target_path_rda Character string specifying the file path for saving
#'   the RDA format. Default: "data/coronavirusupdate_transcripts.rda"
#' @param .return_tibble Logical indicating whether to return the scraped data as
#'   a tibble. Default: FALSE (data is only saved to files)
#' @param .force_complete_scrape Logical indicating whether to scrape all episodes
#'   from scratch, ignoring existing data. Default: FALSE (incremental scraping)
#' @param .write_parquet Logical indicating whether to save data in Parquet format.
#'   Default: FALSE
#' @param .target_path_parquet Character string specifying the file path for saving
#'   the Parquet format. Default: "data/coronavirusupdate_transcripts.parquet"
#'
#' @return If .return_tibble is TRUE, returns a tibble with columns:
#'   \describe{
#'     \item{title}{Episode title}
#'     \item{link}{URL to the episode transcript page}
#'     \item{episode_no}{Episode number (integer)}
#'     \item{speaker}{Normalized speaker name}
#'     \item{text}{Transcript text paragraph}
#'     \item{paragraph_no}{Sequential paragraph number within episode}
#'     \item{last_change}{POSIXct datetime of last transcript modification}
#'     \item{duration_episode}{Episode duration as character string}
#'   }
#'   Otherwise returns NULL invisibly.
#'
#' @details The function implements several important features:
#'   \itemize{
#'     \item \strong{Incremental scraping:} By default, only scrapes episodes not
#'       present in existing data files, making updates efficient
#'     \item \strong{Speaker normalization:} Automatically corrects common typos
#'       and variant spellings in speaker names (e.g., "Hennig", "Henning" →
#'       "Korinna Hennig")
#'     \item \strong{Multiple formats:} Saves data in RDS and RDA formats by default,
#'       with optional Parquet export for non-R users
#'     \item \strong{Robust error handling:} Includes validation and error messages
#'       for common failure scenarios
#'   }
#'
#' @examples
#' \dontrun{
#' # Scrape new episodes only (incremental update)
#' scrape_coronavirusupdate(
#'   .all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html"
#' )
#'
#' # Force complete re-scrape of all episodes
#' scrape_coronavirusupdate(
#'   .all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
#'   .force_complete_scrape = TRUE,
#'   .write_parquet = TRUE
#' )
#'
#' # Scrape and return as tibble for immediate use
#' transcripts <- scrape_coronavirusupdate(
#'   .all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
#'   .return_tibble = TRUE
#' )
#' }
#'
#' @export
scrape_coronavirusupdate <- function(.all_episodes_url,
                                     .target_path_rds = "data/coronavirusupdate_transcripts.rds",
                                     .target_path_rda = "data/coronavirusupdate_transcripts.rda",
                                     .return_tibble = FALSE,
                                     .force_complete_scrape = FALSE,
                                     .write_parquet = FALSE,
                                     .target_path_parquet = "data/coronavirusupdate_transcripts.parquet") {
  # Validate inputs
  if (missing(.all_episodes_url) || is.null(.all_episodes_url) || !is.character(.all_episodes_url)) {
    stop("Invalid episodes URL: must be a character string")
  }

  tryCatch({
    # read html of podcast homepage
    corona_update_html <- xml2::read_html(.all_episodes_url)

    if (is.null(corona_update_html)) {
      stop(paste("Failed to read HTML from URL:", .all_episodes_url))
    }
  }, error = function(e) {
    stop(paste("Error fetching podcast homepage:", e$message))
  })
  # get list of episodes including urls to transcript
  coronavirusupdate_transcripts <- corona_update_html %>%
    rvest::html_nodes(css = ".std h2") %>%
    purrr::map_df(~ {
      title <- .x %>%
        rvest::html_nodes("a") %>%
        rvest::html_text() %>%
        stringr::str_trim()
      link <- .x %>%
        rvest::html_nodes("a") %>%
        rvest::html_attr("href")
      tibble::tibble(title, link)
    }) %>%
    dplyr::mutate(
      link = paste0("https://", urltools::domain(.all_episodes_url), link),
      episode_no = stringr::str_extract(string = title, pattern = "(?<=\\()[:digit:]+(?=\\))"),
      episode_no = as.integer(episode_no),
      # clean title
      title = trimws(stringr::str_remove(string = title, pattern = "\\(.+\\)[:blank:]") %>%
        stringr::str_remove("Coronavirus-Update\\: "))
    )

  # import rds if available
  if (file.exists(.target_path_rds) & .force_complete_scrape == FALSE) {
    coronavirusupdate_existing_transcripts <- readRDS(file = .target_path_rds)
    # get episode number from both tibbles
    coronavirusupdate_existing_episode_no <- coronavirusupdate_existing_transcripts %>%
      dplyr::distinct(episode_no) %>%
      dplyr::select(episode_no)

    coronavirusupdate_episode_no <- coronavirusupdate_transcripts %>%
      dplyr::distinct(episode_no) %>%
      dplyr::select(episode_no)


    # Compare between existing and newly scraped episodes list
    episodes_to_be_scraped <- dplyr::anti_join(coronavirusupdate_episode_no, coronavirusupdate_existing_episode_no) %>%
      tidyr::drop_na() %>%
      dplyr::pull()

    # filter newly scraped episodes list
    coronavirusupdate_transcripts <- coronavirusupdate_transcripts %>%
      dplyr::filter(episode_no %in% episodes_to_be_scraped)
  }

  if (nrow(coronavirusupdate_transcripts) > 0) {
    tryCatch({
      coronavirusupdate_transcripts <- coronavirusupdate_transcripts %>%
        # get transcript data and unnest the results to get a big data frame
        dplyr::mutate(result_text = purrr::map(.x = link, .f = extract_transcript)) %>%
        tidyr::unnest(result_text) %>%
        tidyr::unnest(c(paragraph_no, speaker, text))
    }, error = function(e) {
      stop(paste("Error processing transcripts:", e$message))
    })
  }

  # combine new transcripts with existing data
  if (file.exists(.target_path_rds) & .force_complete_scrape == FALSE) {
    coronavirusupdate_transcripts <- dplyr::bind_rows(
      coronavirusupdate_transcripts,
      coronavirusupdate_existing_transcripts
    )
  }

  #manually clean the speaker names from typos and different variants
  coronavirusupdate_transcripts <- coronavirusupdate_transcripts %>%
    dplyr::mutate(speaker = dplyr::case_when(
      speaker %in% c("Hennig",
                     "Hennig",
                     "Henning",
                     "Korinna Hennig") ~ "Korinna Hennig",
      speaker %in% c("Drosten") ~ "Christian Drosten",
      speaker %in% c("Schulmann") ~ "Beke Schulmann",
      speaker %in% c("Ciesek",
                     "Cisek",
                     "Sandra Cisek") ~ "Sandra Ciesek",
      speaker %in% c("Martini") ~ "Anja Martini",
      speaker %in% c("Rohde") ~ "Gernot Rohde",
      speaker %in% c("Kluge") ~ "Stefan Kluge",
      speaker %in% c("Kriegel") ~ "Martin Kriegel",
      speaker %in% c("Wieler") ~ "Lothar Wieler",
      speaker %in% c("Addo") ~ "Marylyn Addo",
      speaker %in% c("Muntau") ~ "Ania Muntau",
      speaker %in% c("Buyx") ~ "Alena Buyx",
      speaker %in% c("Greiner",
                     "Wolfang Greiner") ~ "Wolfgang Greiner",
      speaker %in% c("Prof. Dr. Hans-Georg Eichler",
                     "Eichler") ~ "Hans-Georg Eichler",
      TRUE ~ speaker
    )
    )

  # Validate data before saving
  validate_transcript_data(coronavirusupdate_transcripts, strict = FALSE)

  # Save data with error handling
  tryCatch({
    #save rds file to target path
    saveRDS(coronavirusupdate_transcripts, file = .target_path_rds)
    message(paste("Successfully saved RDS file to", .target_path_rds))

    #save rda file to target path
    save(coronavirusupdate_transcripts, file = .target_path_rda)
    message(paste("Successfully saved RDA file to", .target_path_rda))

    #if needed also save as parquet
    if (.write_parquet == TRUE) {
      arrow::write_parquet(x = coronavirusupdate_transcripts,
                           sink = .target_path_parquet,
                           allow_truncated_timestamps = TRUE)
      message(paste("Successfully saved Parquet file to", .target_path_parquet))
    }
  }, error = function(e) {
    stop(paste("Error saving files:", e$message))
  })

  if (.return_tibble == TRUE){
    return(coronavirusupdate_transcripts)
  }
}
