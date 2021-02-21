scrape_coronavirusupdate <- function(.all_episodes_url,
                                     .target_path_rds = "data/coronavirusupdate_transcripts.rds",
                                     .force_complete_scrape = FALSE) {
  # read html of podcast homepage
  corona_update_html <- xml2::read_html(.all_episodes_url)
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

  coronavirusupdate_transcripts <- coronavirusupdate_transcripts %>%
    # get transcript data and unnest the results to get a big data frame
    dplyr::mutate(result_text = purrr::map(.x = link, .f = extract_transcript)) %>%
    tidyr::unnest(result_text) %>%
    tidyr::unnest(c(paragraph_no, speaker, text))

  # combine new transcripts with existing data
  if (file.exists(.target_path_rds) & .force_complete_scrape == FALSE) {
    coronavirusupdate_transcripts <- dplyr::bind_rows(
      coronavirusupdate_transcripts,
      coronavirusupdate_existing_transcripts
    )
  }

  #manually clean the speaker names from typos and different variants
  coronavirusupdate_transcripts <- coronavirusupdate_transcripts %>%
    mutate(speaker = dplyr::case_when(
      speaker %in% c("Hennig",
                     "Hennig",
                     "Henning",
                     "Korinna Hennig") ~ "Korinna Hennig",
      speaker %in% c("Drosten") ~ "Christian Drosten",
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

  saveRDS(coronavirusupdate_transcripts, file = .target_path_rds)
  return(coronavirusupdate_transcripts)
}
