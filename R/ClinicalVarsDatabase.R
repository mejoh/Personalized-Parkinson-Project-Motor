ClinicalVarsDatabase <- function(pattern){

library(tidyverse)
library(jsonlite)
library(readtext)
library(assertthat)
library(stringr)
library(lubridate)

# Function to import a certain set of data matching with pattern
# Finds subject's Castor json files
# Subsets by pattern
# Removes faulty files (defined manually)
# Parses json files
# Creates data frame
# Outputs data frame
ImportSubData <- function(dSub, pattern){
        
        # Find subject's files and subset by pattern
        fAllFiles <- dir(dSub, full.names = TRUE)
        fSubsetFiles <- fAllFiles[grep(pattern, fAllFiles)]
        
        # Removal of duplication and naming errors
        if(pattern=='Castor.Visit1' || pattern=='Castor.Visit2'){
                ExcludedFiles <- c('Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_1',
                                   'Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_2',
                                   'Castor.Visit1.Motorische_taken_ON.Updrs3_deel_3')
                for(i in 1:length(ExcludedFiles)){
                        idx <- grep(ExcludedFiles[i], fSubsetFiles)
                        if(not_empty(idx)){
                        fSubsetFiles <- fSubsetFiles[-c(idx)]
                        }
                }
        }
        
        # Initialize data frame, insert pseudonym
        Data <- tibble(pseudonym = '')
        Data[1] <- basename(dSub)
        
        # Parse subsetted json files and bind to data frame
        for(i in 1:length(fSubsetFiles)){
                json <- readtext(fSubsetFiles[i], text_field = 'texts')
                json <- parse_json(json$text)
                Data <- bind_cols(Data[1,], as_tibble(json$crf)[1,])    # < Indexing to remove rows, gets rid of list answers!!!
        }
        
        # Return subject's data frame
        Data
}

# Create a list of subject directories in the pulled-data folder
dPulledData <- 'P:/3022026.01/pep/pulled-data'
# START OF PATTERN LOOP
dSubs <- list.dirs(dPulledData, recursive = FALSE)
#dSubs <- dSubs[1:30] # For testing
dSubs <- dSubs[-c(grep('.pepData', dSubs))]
nSubs <- length(dSubs)

# Define patterns used to search for Castor.<pattern> files
#pattern <- c('Castor.HomeQuestionnaires1')
#pattern <- c('Castor.Visit1')
#pattern <- c('Castor.Visit2')

# Exclude subjects that do not have files matching pattern
Sel <- rep(TRUE, nSubs)
for(n in 1:nSubs){
        filelist <- grep(pattern, dir(dSubs[n]))
        if(length(filelist) == 0){
                Sel[n] <- FALSE
                msg <- paste('Excluding', basename(dSubs[n]), ': no files matching pattern')
                print(msg)
        }
}
msg <- paste(sum(Sel), 'subjects remaining')
print(msg)

# Perform exclusion
dSubs <- dSubs[Sel]
nSubs <- length(dSubs)

# Number of vars differs per subject
# Create one array containing all unique var names
VarNames <- c()
for(n in 1:nSubs){
        dat <- ImportSubData(dSubs[n], pattern)
        nam <- names(dat)
        VarNames <- c(VarNames, nam)    # < Optimization possible, very large array
}
UniqueVarNames <- unique(VarNames)
rm(VarNames)

# Initialize the final data frame and name variables
df <- tibble('1' = rep('NA', nSubs))            # < NAs need to be chars for now so that the code below can work
# Add a bunch of NAs for other vars
for(i in 1:(length(UniqueVarNames) - 1)){
        df <- bind_cols(df, tibble(varname = rep('NA', nSubs)))
}
colnames(df) <- UniqueVarNames

# Import subject data variable by variable
for(n in 1:nSubs){
        dat <- ImportSubData(dSubs[n], pattern)
        SubVarNames <- colnames(dat)
        for(i in 1:length(SubVarNames)){
                colidx <- str_which(UniqueVarNames, SubVarNames[i])
                df[n,colidx] <- unlist(dat[i])  # < Some variables are lists, like dat[77], these will be incorrectly imported!!! 
        }
}

# Add column defining timepoint
if(grepl('Castor.HomeQuestionnaires1', pattern, fixed = TRUE)){
        timepoint <- 'HQ1'
}else if(grepl('Castor.Visit1', pattern, fixed = TRUE)){
        timepoint <- 'V1'
}else if(grepl('Castor.Visit2', pattern, fixed = TRUE)){
        timepoint <- 'V2'
}
df <- bind_cols(df, tibble('timepoint' = rep(timepoint,nSubs)))

# Turn uninformative characters to NA
df[df=='NA'] <- NA    #
df[df=='?'] <- NA     # Not available for certain subjects (castor dependencies)
df[df==''] <- NA      # Not filled in
df[df=='##USER_MISSING_95##'] <- NA
df[df=='##USER_MISSING_96##'] <- NA
df[df=='##USER_MISSING_97##'] <- NA
df[df=='##USER_MISSING_98##'] <- NA
df[df=='##USER_MISSING_99##'] <- NA

# Return data frame
df

}