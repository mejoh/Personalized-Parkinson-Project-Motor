# X <- MotorTaskDatabase()
# X is a Subjects x Variables tibble with behavioural data

# Test

MotorTaskDatabase <- function(){

  library(tidyverse)
  
  project <- '3024006.01'   # Set project nr
  prefix <- 'sub-PIT1MR'    # Set subject prefix
  
  SubjectList <- function(project, prefix){
  directory <- paste('P:/', project, '/bids/', sep = '')
  subjects <- dir(directory, pattern = prefix)
  }   #Generate a list of subjects, store in 'subjects'

  ImportEventsTsv <- function(project, subject){
  file <- paste('P:/', project, '/bids/', subject, '/func/', subject, '_task-motor_events.tsv', sep='')
  events <- read_tsv(file, na = 'n/a')
  }   #Import events.tsv files for all subjects, store in 'events'
  
  Subjects <- SubjectList(project, prefix)
  Conditions <- c('Ext', 'Int2', 'Int3')    # Set conditions
  Data <- tribble(~Subject, ~Condition, ~Reaction.Time, ~Percentage.Correct, ~Responding.Hand, ~Group)    # Generate data frame

  # Fill data frame
  for(n in 1:length(Subjects)){
    Events <- ImportEventsTsv(project, Subjects[n])
    
    for(i in 1:length(Conditions)){
      if(Conditions[i] == 'Ext'){
        Row <- filter(Events, event_type == 'response', trial_type == 'Ext')
      }else if(Conditions[i] == 'Int2'){
        Row <- filter(Events, event_type == 'response', trial_type == 'Int2')
      }else{
        Row <- filter(Events, event_type == 'response', trial_type == 'Int3')
      }
      Data <- add_row(Data,
                      Subject = Subjects[n],
                      Condition = Conditions[i],
                      Reaction.Time = filter(Row, correct_response == 'Hit') %>% pull(var = reaction_time) %>% mean,
                      Percentage.Correct = nrow(filter(Row, correct_response == 'Hit')) / nrow(Row),
                      Responding.Hand = Events$hand[1],
                      Group = Events$group[1])
    }
    
  }
  
  Data$Condition <- as.factor(Data$Condition)               # Turn relevant vars into factors
  Data$Responding.Hand <- as.factor(Data$Responding.Hand)
  Data$Group <- as.factor(Data$Group)
  
  Data    # Print the final data frame
  
}