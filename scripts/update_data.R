#load packages
library(magrittr)
library(tibble)
library(dplyr)
library(lubridate)
library(purrr)
library(rvest)
library(stringr)
library(tidyr)
library(urltools)
library(xml2)
library(arrow)

#source functions in R
source("R/scrape_coronavirusupdate.R")
source("R/extract_episode_length.R")
source("R/extract_last_change.R")
source("R/extract_speaker_names.R")
source("R/extract_transcript.R")
source("R/extract_transcript_nodes.R")

scrape_coronavirusupdate(.all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
                         .write_parquet = TRUE)
