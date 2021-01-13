# This script generates a single csv file that summarizes the motor
# task performance of all subjects in the specified bids-directory
# The output file is in person-period format

generate_motor_task_csv <- function(bidsdir){
        
        library(tidyverse)
        library(tidyjson)
        
        # Import a row of data for a specified subject and visit
        ImportEventsTsv <- function(subject, visit){
                
                filepth <- paste(bidsdir, subject, '/', visit, '/beh/', sep='')
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
        
        Subjects <- basename(list.dirs(bidsdir, recursive = FALSE)) # Define a list of subjects
        Subjects <- Subjects[str_starts(Subjects, 'sub-')]
        Conditions <- c('Ext', 'Int2', 'Int3')    # Set conditions
        Data <- tribble(~pseudonym,
                        ~Timepoint,
                        ~Condition,
                        ~Response.Time,
                        ~Percentage.Correct,
                        ~Button.Press.Mean,
                        ~Button.Press.Sd,
                        ~Button.Press.Repetitions,
                        ~Responding.Hand,
                        ~Group)    # Generate data frame
        
        # Write one per condition for each subject to the data frame
        for(n in 1:length(Subjects)){
                
                dSubDir <- paste(bidsdir, Subjects[n], sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses')] # Check for visits
                for(t in Visits){
                        
                        # Import data            
                        Events <- ImportEventsTsv(Subjects[n], t)
                        
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
                                                        pseudonym = Subjects[n],
                                                        Timepoint = t,
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
                                                        pseudonym = Subjects[n],
                                                        Timepoint = t,
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
        
        # Omit rows without full data
        Data <- na.omit(Data)
        
        # Write the data frame to csv
        outputfile <- paste(bidsdir, 'derivatives/database_motor_task.csv', sep = '')
        if(file.exists(outputfile)){
                file.remove(outputfile)
        }
        write_csv(Data, outputfile)
        
}
