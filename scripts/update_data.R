source("R/scrape_coronavirusupdate.R")
scrape_coronavirusupdate(.all_episodes_url = "https://www.ndr.de/nachrichten/info/Coronavirus-Update-Alle-Folgen,podcastcoronavirus134.html",
                         .write_parquet = TRUE)
