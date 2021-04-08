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
        
        Subjects <- basename(list.dirs(bidsdir, recursive = FALSE)) # Define a list of subjects with motor task data
        Subjects <- Subjects[str_starts(Subjects, 'sub-')]
        Sel <- rep(TRUE, length(Subjects))
        for(n in 1:length(Subjects)){
                filepth1 <- paste(bidsdir, Subjects[n], '/', 'ses-POMVisit1', '/beh/', sep='')
                filepth2 <- paste(bidsdir, Subjects[n], '/', 'ses-PITVisit1', '/beh/', sep='')
                contents <- c(dir(filepth1), dir(filepth2))
                tsvfile <- contents[str_detect(contents, 'task-motor_acq-MB6_run.*.tsv')]
                if(length(tsvfile) == 0){
                        Sel[n] <- FALSE
                }
        }
        Subjects <- Subjects[Sel]
        Conditions <- c('Ext', 'Int2', 'Int3', 'Catch')    # Set conditions
        Data <- tribble(~pseudonym,
                        ~Timepoint,
                        ~Condition,
                        ~Response.Time,
                        ~Percentage.Correct,
                        ~Button.Press.Mean,
                        ~Button.Press.Sd,
                        ~Button.Press.CoV,
                        ~Button.Press.Repetitions,
                        ~Button.Press.NonRepetitions,
                        ~Button.Press.RepetitionRatio,
                        ~Button.Press.Adjacent,
                        ~Button.Press.NonAdjacent,
                        ~Button.Press.AdjacencyRatio,
                        ~Button.Press.Switch,
                        ~Button.Press.non_switch,
                        ~Button.Press.SwitchRatio,
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
                        
                        # Calculate button press repetitions and adjacency
                        if(!is.na(Events[[1]]) && !is.na(Events[[2]])){
                                
                                press.dat <- Events[[1]] %>%
                                        select(trial_number, trial_type, event_type, button_pressed, button_expected, correct_response)
                                df_cue <- press.dat %>%
                                        filter(event_type == 'cue') %>%
                                        select(trial_number, trial_type, correct_response) %>%
                                        mutate(trial_number = as.numeric(trial_number))
                                df_resp <- press.dat %>%
                                        filter(event_type == 'response') %>%
                                        select(trial_number, button_pressed, button_expected) %>%
                                        mutate(trial_number = as.numeric(trial_number),
                                               button_pressed = as.numeric(button_pressed),
                                               button_expected = as.numeric(button_expected))
                                df_presses <- left_join(df_cue, df_resp, by = 'trial_number')
                                df_presses <- df_presses %>%
                                        separate(button_expected, c('Expected_1','Expected_2','Expected_3'), sep = c(1, 2), convert = TRUE)
                                
                                # Count the number of times a button press is repeated from one trial to the next
                                repetition_counter <- 0
                                non_repetition_counter <- 0
                                for(v in 1:length(df_presses$trial_type)){
                                        if(str_detect(df_presses$trial_type[v],'Int') & v != 1 & df_presses$correct_response[v] != 'Miss'){
                                                preceding <- df_presses$button_pressed[v-1]
                                                expected <- c(df_presses$Expected_1[v],df_presses$Expected_2[v],df_presses$Expected_3[v])
                                                expected <- expected[!is.na(expected)]
                                                pressed <- df_presses$button_pressed[v]
                                                if(!is.na(preceding) & !is.na(pressed)){
                                                        if(sum(preceding==expected)>0 & pressed == preceding){
                                                                repetition_counter <- repetition_counter + 1
                                                        }else if(sum(preceding==expected)>0 & pressed != preceding){
                                                                non_repetition_counter <- non_repetition_counter + 1
                                                        }
                                                }
                                        }
                                }
                                
                                # Count the number of responses that were adjacent or non-adjacent to a previous response where either of these two types of responses were possible options
                                adjacency_counter <- 0
                                non_adjacency_counter <- 0
                                for(v in 1:length(df_presses$trial_number)){
                                        if(str_detect(df_presses$trial_type[v],'Int') & v != 1 & df_presses$correct_response[v] != 'Miss'){
                                                preceding <- df_presses$button_pressed[v-1]
                                                expected <- c(df_presses$Expected_1[v],df_presses$Expected_2[v],df_presses$Expected_3[v])
                                                expected <- expected[!is.na(expected)]
                                                pressed <- df_presses$button_pressed[v]
                                                exp_pre_diff <- expected - preceding
                                                if(!is.na(preceding) & !is.na(pressed)){
                                                        if((preceding-1 %in% expected | preceding+1 %in% expected) & max(exp_pre_diff) > 1){
                                                                if(pressed != preceding-1 & pressed != preceding+1){
                                                                        non_adjacency_counter <- non_adjacency_counter+1
                                                                }else if(pressed == preceding-1 | pressed == preceding+1){
                                                                        adjacency_counter <- adjacency_counter+1
                                                                }
                                                        }
                                                }
                                        }
                                }
                                
                                # (Switch) Count the number of responses that were repetitions when adjacent/non-adjacent responses were possible
                                # For each int trial, check whether a repetition is possible. Compare the response with the preceding one. Increment
                                # the switch counter if the two do not match
                                switch_counter <- 0
                                non_switch_counter <- 0
                                for(v in 1:length(df_presses$trial_number)){
                                        if(str_detect(df_presses$trial_type[v],'Int') & v != 1 & df_presses$correct_response[v] != 'Miss'){
                                                preceding <- df_presses$button_pressed[v-1]
                                                expected <- c(df_presses$Expected_1[v],df_presses$Expected_2[v],df_presses$Expected_3[v])
                                                expected <- expected[!is.na(expected)]
                                                pressed <- df_presses$button_pressed[v]
                                                if(!is.na(preceding) & !is.na(pressed)){
                                                        if(sum(preceding==expected)>0 & preceding != pressed){
                                                                switch_counter <- switch_counter+1
                                                        }else if(sum(preceding==expected)>0 & preceding == pressed){
                                                                non_switch_counter <- non_switch_counter+1
                                                        }
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
                                        }else if(Conditions[i] == 'Int3'){
                                                Row <- filter(Events[[1]], event_type == 'response', trial_type == 'Int3')
                                        }else{
                                                Row <- filter(Events[[1]], event_type == 'cue', trial_type == 'Catch')
                                        }
                                        
                                        # Write row to data frame    
                                        if(Conditions[i] != 'Catch'){
                                                Data <- add_row(Data,
                                                                pseudonym = Subjects[n],
                                                                Timepoint = t,
                                                                Condition = Conditions[i],
                                                                Response.Time = filter(Row, correct_response == 'Hit') %>% pull(var = response_time) %>% mean,
                                                                Percentage.Correct = nrow(filter(Row, correct_response == 'Hit')) / nrow(Row),
                                                                Button.Press.Mean = filter(Row, correct_response == 'Hit') %>% pull(var = button_pressed) %>% mean,
                                                                Button.Press.Sd = filter(Row, correct_response == 'Hit') %>% pull(var = button_pressed) %>% sd,
                                                                Button.Press.CoV = Button.Press.Sd / Button.Press.Mean,
                                                                Button.Press.Repetitions = repetition_counter,
                                                                Button.Press.NonRepetitions = non_repetition_counter,
                                                                Button.Press.RepetitionRatio = repetition_counter / (repetition_counter + non_repetition_counter),
                                                                Button.Press.Adjacent = adjacency_counter,
                                                                Button.Press.NonAdjacent = non_adjacency_counter,
                                                                Button.Press.AdjacencyRatio = adjacency_counter / (adjacency_counter + non_adjacency_counter),
                                                                Button.Press.Switch = switch_counter,
                                                                Button.Press.non_switch = non_switch_counter,
                                                                Button.Press.SwitchRatio = switch_counter / (switch_counter + non_switch_counter),
                                                                Responding.Hand = Events[[2]]$RespondingHand.Value,
                                                                Group = Events[[2]]$Group.Value)
                                        }else{
                                                Data <- add_row(Data,
                                                                pseudonym = Subjects[n],
                                                                Timepoint = t,
                                                                Condition = Conditions[i],
                                                                Response.Time = NA,
                                                                Percentage.Correct = nrow(filter(Row, correct_response == 'Hit')) / nrow(Row),
                                                                Button.Press.Mean = NA,
                                                                Button.Press.Sd = NA,
                                                                Button.Press.CoV = NA,
                                                                Button.Press.Repetitions = NA,
                                                                Button.Press.NonRepetitions = NA,
                                                                Button.Press.RepetitionRatio = NA,
                                                                Button.Press.Adjacent = NA,
                                                                Button.Press.NonAdjacent = NA,
                                                                Button.Press.AdjacencyRatio = NA,
                                                                Button.Press.Switch = NA,
                                                                Button.Press.non_switch = NA,
                                                                Button.Press.SwitchRatio = NA,
                                                                Responding.Hand = Events[[2]]$RespondingHand.Value,
                                                                Group = Events[[2]]$Group.Value)
                                        }
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
                                                        Button.Press.CoV = NA,
                                                        Button.Press.Repetitions = NA,
                                                        Button.Press.NonRepetitions = NA,
                                                        Button.Press.RepetitionRatio = NA,
                                                        Button.Press.Adjacent = NA,
                                                        Button.Press.NonAdjacent = NA,
                                                        Button.Press.AdjacencyRatio = NA,
                                                        Button.Press.Switch = NA,
                                                        Button.Press.non_switch = NA,
                                                        Button.Press.SwitchRatio = NA,
                                                        Responding.Hand = NA,
                                                        Group = NA)
                                }
                        }
                }
        }
        
        # Omit rows without full data (removes all catch trials. Probably dont want this...)
        #Data <- na.omit(Data)
        
        # Write the data frame to csv
        outputfile <- paste(bidsdir, 'derivatives/database_motor_task.csv', sep = '')
        if(file.exists(outputfile)){
                file.remove(outputfile)
        }
        write_csv(Data, outputfile)
        
}
