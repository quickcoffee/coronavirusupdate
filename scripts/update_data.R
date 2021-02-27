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
devtools::load_all()

scrape_coronavirusupdate(.all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
                         .write_parquet = TRUE)
