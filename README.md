
<!-- README.md is generated from README.Rmd. Please edit that file -->

# coronavirusupdate

<!-- badges: start -->
<!-- badges: end -->

When the [NDR
Coronavirus-Update](https://www.ndr.de/nachrichten/info/podcast4684.html)
announced that they would make transcripts of all episodes publicly
available I firstly tried to scrape the PDF files, which [kind of
worked](https://quickcoffee.netlify.app/post/topic-modelling-on-one-of-germany-s-most-popular-corona-podcast/)
but was not very reliable. So I went back and now used the transcripts
directly from the [podcast’s
homepage](https://www.ndr.de/nachrichten/info/Coronavirus-Update-Die-Podcast-Folgen-als-Skript,podcastcoronavirus102.html).  
Consequently I decided to create a R package to make it easy for anyone
to scrape and access the data.

## Installation

You can install this package from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("quickcoffee/coronavirusupdate")
```

## Example

This is a basic example how to load the transcript data:

``` r
library(coronavirusupdate)
## load data
data("coronavirusupdate_transcripts")
```

This will load a tidy dataframe called `coronavirus_update` with one row
per paragraph and the following structure:

``` r
library(dplyr)
glimpse(coronavirusupdate_transcripts)
#> Rows: 5,528
#> Columns: 8
#> $ title            <chr> "Mutante, Schnelltests, Medikamente", "Mutante, Schn…
#> $ link             <chr> "https://www.ndr.de/nachrichten/info/77-Coronavirus-…
#> $ episode_no       <int> 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, 77, …
#> $ speaker          <chr> "Korinna Hennig", "Sandra Ciesek", "Sandra Ciesek", …
#> $ text             <chr> "Aus Israel erfahren wir viel Aufschlussreiches aus …
#> $ paragraph_no     <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 1…
#> $ last_change      <dttm> 2021-02-24 17:00:00, 2021-02-24 17:00:00, 2021-02-2…
#> $ duration_episode <chr> "85 Min", "85 Min", "85 Min", "85 Min", "85 Min", "8…
```

With this dataset one could for example inspect the share per speaker
and episode:

``` r
library(ggplot2)

coronavirusupdate_transcripts %>%
  mutate(paragraph_length = nchar(text)) %>% 
  group_by(episode_no, speaker) %>% 
  summarise(speaker_length = sum(paragraph_length)) %>% 
  group_by(episode_no) %>% 
  mutate(speaker_share = speaker_length/sum(speaker_length)) %>% 
  ggplot(aes(x=episode_no, y=speaker_share, fill = speaker))+
  geom_bar(position="stack", stat="identity")+
  theme_minimal()+
  theme(legend.position="bottom")+
  labs(title = "Share of speaker per episode",
       y = "Share",
       x = "Episode No",
       fill = element_blank())
```

<img src="man/figures/README-pressure-1.png" width="100%" />
