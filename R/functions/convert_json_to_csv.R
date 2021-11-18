convert_json_to_csv <- function(bidsdir, subject, visit, outputname){
  
  library(tidyverse)
  library(jsonlite)

  # Find subject's files and subset by pattern
  # Visits and home questionnaires are collapsed (i.e. treated as one time point)
  dSub <- paste(bidsdir, subject, sep='/')
  fAllFiles <- dir(dSub, full.names = TRUE, recursive = TRUE)
  fSubsetFiles <- fAllFiles[grep(visit, fAllFiles)]
  if(visit=='ses-POMVisit1'){
    fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires1', fAllFiles)])
  }else if(visit=='ses-POMVisit2'){
    fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires2', fAllFiles)])
  }else if(visit=='ses-POMVisit3'){
    fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires3', fAllFiles)])
  }else if(visit=='ses-PITVisit1'){
          fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-PITHomeQuestionnaires1', fAllFiles)])
  }else if(visit=='ses-PITVisit2'){
          fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-PITHomeQuestionnaires2', fAllFiles)])
  }
  
  # FIX: Removal of duplication and naming errors
  ExcludedFiles <- c('Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_1',
                     'Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_2',
                     'Castor.Visit3.Demografische_vragenlijsten.Pesticiden.json')
  for(e in ExcludedFiles){
    fSubsetFiles <- fSubsetFiles[!str_detect(fSubsetFiles, e)]
  }
  
  # Initialize data frame, insert pseudonym
  Data <- tibble(pseudonym = basename(dSub))
  
  # Parse subsetted json files and bind to data frame
  for(i in 1:length(fSubsetFiles)){
    json <- jsonlite::read_json(fSubsetFiles[i])
    # FIX: Rename vars where Of and On labels have been accidentally reversed
    if(str_detect(fSubsetFiles[i], 'Motorische_taken_ON') && str_detect(names(json$crf), 'Up3Of')){
      print(dSub)
      msg <- 'Up3Of variable found in On assessment, replacing with Up3On...'
      print(msg)
      names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
    }else if(str_detect(fSubsetFiles[i], 'Motorische_taken_OFF') && str_detect(names(json$crf), 'Up3On')){
      print(dSub)
      msg <- 'Up3On variable found in Off assessment, replacing with Up3Of...'
      print(msg)
      names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
    }
    crf <- unlist(json$crf) %>% as_tibble_row # 'Unpacks' lists and turns each list value into its own column
    Data <- bind_cols(Data[1,], crf)
    #DEPRECATED: Data <- bind_cols(Data[1,], as_tibble(json$crf)[1,])    # < Indexing to remove rows, gets rid of list answers!!!
  }
  
  # DEPRECATED SOLUTION, fixed above: Some variables are stored as lists, which prevents them from being written properly
  #Data <- Data %>%
  #  mutate_if(is.list, unlist)
  
  # Turn uninformative characters to NA
  Data[Data=='NA'] <- NA    # Not filled in?
  Data[Data=='?'] <- NA     # Not available for certain subjects (castor dependencies?)
  Data[Data==''] <- NA      # Not filled in?
  Data[Data=='##USER_MISSING_95##'] <- NA
  Data[Data=='##USER_MISSING_96##'] <- NA
  Data[Data=='##USER_MISSING_97##'] <- NA
  Data[Data=='##USER_MISSING_98##'] <- NA
  Data[Data=='##USER_MISSING_99##'] <- NA
  
  # Add timepoint as a variable
  Data <- Data %>%
    mutate(Timepoint = visit)
  Data <- Data %>%
          mutate(TimepointNr = NA)
  Data$TimepointNr[str_detect(Data$Timepoint,'Visit1')] <- 0
  Data$TimepointNr[str_detect(Data$Timepoint,'Visit2')] <- 1
  Data$TimepointNr[str_detect(Data$Timepoint,'Visit3')] <- 2
  
  # Return subject's data frame
  write_csv(Data, outputname)
}
