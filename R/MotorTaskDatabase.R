# X <- MotorTaskDatabase()
# X is a Subjects x Variables tibble with behavioural data

MotorTaskDatabase <- function(project){

        #project <- '3022026.01' / '3024006.01'  # Set project nr
        #prefix <- 'sub-POM1FM' / 'sub-PIT1MR'  # Set subject prefix      
        
  library(tidyverse)
  library(tidyjson)
        
  if(project == '3022026.01'){
          prefix <- 'sub-POM1FM'
  }else{
          prefix <- 'sub-PIT1MR'   
  }
  
  ##### Sub-functions #####
  
  # Generate a list of subjects, store in 'subjects'
  SubjectList <- function(project, prefix){
  directory <- paste('P:/', project, '/bids/', sep = '')
  subjects <- dir(directory, pattern = prefix)
  }

  # Import data from events.tsv/json files for all subjects, store in 'events'
  # Outputs a list of information from events.tsv and events.json 
  # Outputs NA if motor task files are missing (script also finds reward task subjects)
  ImportEventsTsv <- function(project, subject){
  filepth <- paste('P:/', project, '/bids/', subject, '/beh/', sep='')
  for(i in 3:1){
          ptn <- paste('_task-motor_acq-MB6_run-', i, sep='')
          checkfile <- paste(filepth, dir(filepth, ptn)[1], sep = '')
          if(file.exists(checkfile)){
                tsvfile <- dir(filepth, paste(ptn, '_events.tsv', sep=''))
                jsonfile <- dir(filepth, paste(ptn, '_events.json', sep=''))
                break
          }else{
                tsvfile <- NA
                jsonfile <- NA
                next  
          }
  } # Search for the last run
  
  if(!is.na(tsvfile) && !is.na(jsonfile)){
          events <- read_tsv(paste(filepth, tsvfile, sep=''), na = 'n/a')
          json <- read_json(paste(filepth, jsonfile, sep='')) %>% 
                  spread_all %>% 
                  select(Group.Value, RespondingHand.Value)   
  }else{
          events <- NA
          json <- NA
  }
  
  return(list(events, json))    # Print output of function
  
  }   
  
  #####
  
  Subjects <- SubjectList(project, prefix) # Generate subject list
  Conditions <- c('Ext', 'Int2', 'Int3')    # Set conditions
  Data <- tribble(~Subject,
                  ~Condition,
                  ~Response.Time,
                  ~Percentage.Correct,
                  ~Responding.Hand,
                  ~Group)    # Generate data frame

  # Fill data frame
  for(n in 1:length(Subjects)){
    
    # Import data            
    Events <- ImportEventsTsv(project, Subjects[n])
    
    # Write one observation (row) per condition to data frame
    for(i in 1:length(Conditions)){
      
      # Check that files exist
      if(!is.na(Events[[1]]) && !is.na(Events[[2]])){
        
        # Filter events by condition            
        if(Conditions[i] == 'Ext'){
          Row <- filter(Events[[1]], event_type == 'response', trial_type == 'Ext')
        }else if(Conditions[i] == 'Int2'){
          Row <- filter(Events[[1]], event_type == 'response', trial_type == 'Int2')
        }else{
          Row <- filter(Events[[1]], event_type == 'response', trial_type == 'Int3')
        }
        
        # Write row to data frame            
        Data <- add_row(Data,
                Subject = Subjects[n],
                Condition = Conditions[i],
                Response.Time = filter(Row, correct_response == 'Hit') %>% pull(var = response_time) %>% mean,
                Percentage.Correct = nrow(filter(Row, correct_response == 'Hit')) / nrow(Row),
                Responding.Hand = Events[[2]]$RespondingHand.Value,
                Group = Events[[2]]$Group.Value)
      }else{
        
        # Write row to data frame. Fill with NAs if files are missing           
        Data <- add_row(Data,
                Subject = Subjects[n],
                Condition = Conditions[i],
                Response.Time = NA,
                Percentage.Correct = NA,
                Responding.Hand = NA,
                Group = NA)
      }
    }
  }
  
  Data$Condition <- as.factor(Data$Condition)               # Convert relevant variables into factors
  Data$Responding.Hand <- as.factor(Data$Responding.Hand)
  Data$Group <- as.factor(Data$Group)
  
  Data    # Print the final data frame
  
}