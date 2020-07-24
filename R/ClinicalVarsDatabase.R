library(tidyverse)
library(tidyjson)
library(jsonlite)
library(readtext)

# Create a list of subject directories in the pulled-data folder
dPulledData <- 'P:/3022026.01/pep/pulled-data'
dSubs <- list.dirs(dPulledData, recursive = FALSE)
dSubs <- dSubs[-c(grep('.pepData', dSubs))]

# Function to import a certain set of data matching with pattern
ImportSubData <- function(dSub, pattern){
        
        fAllFiles <- dir(dSub, full.names = TRUE)
        fSubsetFiles <- fAllFiles[grep(pattern, fAllFiles)]
        
        Data <- tibble(id = '')
        Data[1] <- basename(dSub)
        
        for(i in 1:length(fSubsetFiles)){
                json <- readtext(fSubsetFiles[i], text_field = 'texts')
                json <- parse_json(json$text)
                Data <- bind_cols(Data, as_tibble(json$crf))
        }
        Data[1,] # 7 rows are returned. Why??? Are they all identical?
}

pattern <- c('Castor.HomeQuestionnaires1', 'Castor.Visit1', 'Castor.Visit2')

# Number of vars differs per subject
# Create one array containing all unique var names
# Use this to name vars in the final data frame
# NAs should be written when a subject does not have a certain variable
VarNames <- c()
for(n in 1:4){
        dat <- ImportSubData(dSubs[n], pattern[1])
        nam <- names(dat)
        VarNames <- c(VarNames, nam)
}
UniqueVarNames <- unique(VarNames)

doot <- tibble()
for(i in 1:length(UniqueVarNames)){
        for(i in 1:length(UniqueVarNames)){
                dat <- ImportSubData(dSubs[i], pattern[1])
                
        }
}
