# X <- MotorTaskDatabase('project')
# X is a Subjects x Variables tibble with behavioural data

MotorTaskDatabase <- function(project){
  
  library(tidyverse)
  library(tidyjson)
  
  ##### Sub-functions #####
  
  # Generate a list of subjects, store in 'subjects'
  SubjectList <- function(project){
        directory <- paste('P:/', project, '/pep/bids/', sep = '')
        directory.contents <- dir(directory)
        subjects <- directory.contents[str_detect(directory.contents, '^sub-')]
  }

  # Import data from events.tsv/json files for all subjects, store in 'events'
  # Outputs a list of information from events.tsv and events.json 
  # Outputs NA if motor task files are missing (script also finds reward task subjects)
  ImportEventsTsv <- function(project, subject, visit){
  
                  
  filepth <- paste('P:/', project, '/pep/bids/', subject, '/', visit, '/beh/', sep='')
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
          json <- tidyjson::read_json(paste(filepth, jsonfile, sep='')) %>% 
                  spread_all %>% 
                  select(Group.Value, RespondingHand.Value)   
  }else{
          events <- NA
          json <- NA
  }
  
  return(list(events, json))    # Print output of function
  
  }   
  
  #####
  
  Subjects <- SubjectList(project) # Generate subject list
  Conditions <- c('Ext', 'Int2', 'Int3')    # Set conditions
  Data <- tribble(~Subject,
                  ~Visit,
                  ~Condition,
                  ~Response.Time,
                  ~Percentage.Correct,
                  ~Button.Press.Mean,
                  ~Button.Press.Sd,
                  ~Button.Press.Repetitions,
                  ~Responding.Hand,
                  ~Group)    # Generate data frame

  # Fill data frame
  for(n in 1:length(Subjects)){
    
    dSubDir <- paste('P:/', project, '/pep/bids/', Subjects[n], sep='')
    Visits <- dir(dSubDir)
    Visits <- Visits[startsWith(Visits,'ses')]
    for(t in Visits){
          
    # Import data            
    Events <- ImportEventsTsv(project, Subjects[n], t)
    
    # Calculate button press repetitions
    if(!is.na(Events[[1]]) && !is.na(Events[[2]])){
        reps.dat <- Events[[1]] %>%
                filter(event_type=='response') %>%
                filter(trial_type!='Catch') %>%
                select(trial_type, button_pressed) %>%
                filter(button_pressed > 0)
    
        repetition_counter <- 0
        for(v in 1:length(reps.dat$trial_type)){
                if(str_detect(reps.dat$trial_type[v],'Int') && v != 1){
                        if(reps.dat$button_pressed[v] == reps.dat$button_pressed[v-1]){
                                repetition_counter <- repetition_counter + 1
                        }
                }
        }
    }
    
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
                Visit = t,
                Condition = Conditions[i],
                Response.Time = filter(Row, correct_response == 'Hit') %>% pull(var = response_time) %>% mean,
                Percentage.Correct = nrow(filter(Row, correct_response == 'Hit')) / nrow(Row),
                Button.Press.Mean = filter(Row, correct_response == 'Hit') %>% pull(var = button_pressed) %>% mean,
                Button.Press.Sd = filter(Row, correct_response == 'Hit') %>% pull(var = button_pressed) %>% sd,
                Button.Press.Repetitions = repetition_counter,
                Responding.Hand = Events[[2]]$RespondingHand.Value,
                Group = Events[[2]]$Group.Value)
      }else{
        
        # Write row to data frame. Fill with NAs if files are missing           
        Data <- add_row(Data,
                Subject = Subjects[n],
                Visit = t,
                Condition = Conditions[i],
                Response.Time = NA,
                Percentage.Correct = NA,
                Button.Press.Mean = NA,
                Button.Press.Sd = NA,
                Button.Press.Repetitions = NA,
                Responding.Hand = NA,
                Group = NA)
      }
    }
    }
  }
  
  Data$Visit <- as.factor(Data$Visit)
  Data$Condition <- as.factor(Data$Condition)               # Convert relevant variables into factors
  Data$Responding.Hand <- as.factor(Data$Responding.Hand)
  Data$Group <- as.factor(Data$Group)
  
  Data    # Print the final data frame
  
}