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
  # 'DD_InflammationMarkers' variables need specific processing because their files only contain a single number/date
  for(i in 1:length(fSubsetFiles)){
          if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers')){
                  if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers_Blood_Olink96.Visit[0-9].json')){
                          json <- read_delim(fSubsetFiles[i], show_col_types = FALSE)
                          colnames(json) <- paste('DD_InflammationMarkers_Olink96_',colnames(json),sep='')
                  }else if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers_CSF_RewardTask.json')){
                          json <- read_delim(fSubsetFiles[i], show_col_types = FALSE)
                          colnames(json) <- paste('DD_InflammationMarkers_CSF-RewardTask_',colnames(json),sep='')
                  }else if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers_Blood_.*CRP.Visit[0-9].json')){
                          json <- read.table(fSubsetFiles[i])
                          cn <- basename(fSubsetFiles[i]) %>% str_replace(., '\\..*','')
                          colnames(json) <- cn
                          json <- as_tibble(json)
                  }else if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers_Blood_.*NFL.Visit[0-9].json')){
                          json <- read.table(fSubsetFiles[i])
                          cn <- basename(fSubsetFiles[i]) %>% str_replace(., '\\..*','')
                          colnames(json) <- cn
                          json <- as_tibble(json)
                  }else{
                          json <- read_csv(fSubsetFiles[i], col_names = FALSE, show_col_types = FALSE)
                          varname <- unlist(str_extract_all(fSubsetFiles[i],"(?<=POMVisit[0-9]/).+(?=.Visit)"))
                          colnames(json) <- varname
                  }
          }else if(str_detect(fSubsetFiles[i],'DD_Johansson2023')){
                  json <- read.table(fSubsetFiles[i])
                  cn <- basename(fSubsetFiles[i]) %>% str_replace(., '\\..*','')
                  colnames(json) <- cn
                  json <- as_tibble(json)
          }else{
                  json <- jsonlite::read_json(fSubsetFiles[i])
          }
    # FIX: Rename vars where Of and On labels have been accidentally reversed
    if(str_detect(fSubsetFiles[i], 'Motorische_taken_ON') && any(str_detect(names(json$crf), 'Up3Of'))){
      print(dSub)
      msg <- 'Up3Of variable found in On assessment, replacing with Up3On...'
      print(msg)
      names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
    }else if(str_detect(fSubsetFiles[i], 'Motorische_taken_OFF') && any(str_detect(names(json$crf), 'Up3On'))){
      print(dSub)
      msg <- 'Up3On variable found in Off assessment, replacing with Up3Of...'
      print(msg)
      names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
    }
    if(str_detect(fSubsetFiles[i],'DD_InflammationMarkers')){
            crf <- json
    }else if(str_detect(fSubsetFiles[i],'DD_Johansson2023')){
            crf <- json
    }else{
            crf <- unlist(json$crf) %>% as_tibble_row # 'Unpacks' lists and turns each list value into its own column     
    }
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
  msg <- paste('Writing', Data$pseudonym, Data$Timepoint, '\n')
  cat(msg)
  write_csv(Data, outputname)
}
