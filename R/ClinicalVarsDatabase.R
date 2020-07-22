# List paths to subjects
dPulledData <- 'P:/3022026.01/pep/pulled-data'
t <- list.dirs(dPulledData, recursive = FALSE)
t <- t[-c(grep('.pepData', t))]

library(tidyjson)
library(jsonlite)
library(readtext)

for(n in 1:length(t)){
        pData <- dir(t[i], full.names = TRUE)
        json <- readtext(pData[1], text_field = 'texts')
        json <- parse_json(json$text)
}