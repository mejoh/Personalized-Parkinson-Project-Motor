convert_motor_tsv_to_csv <- function(tsvfile, outputname){
    
    events <- read_tsv(tsvfile, na = 'n/a')
    run <- str_extract(tsvfile, 'run-[0-9]')
    searchpattern <- paste('.*task-motor.*', run, '_events.json', sep='')
    json <- dir(dirname(tsvfile), searchpattern, full.names = TRUE)
    if(length(json)>0){
            json <- jsonlite::read_json(json)
            resphand <- json$RespondingHand$Value
            group <- json$Group$Value
    }else{
            resphand <- NA
            group <- NA
    }
    
    # Extract relevant rows of tsv file
    Ext <- filter(events, event_type == 'response', trial_type == 'Ext')
    Int2 <- filter(events, event_type == 'response', trial_type == 'Int2')
    Int3 <- filter(events, event_type == 'response', trial_type == 'Int3')
    Catch <- filter(events, event_type == 'cue', trial_type == 'Catch')
    Misses <- filter(events, event_type == 'cue', correct_response == 'Miss')
    
    # Initialize data frame
    base <- basename(tsvfile)
    sub <- str_match(base, 'sub-(.*)_ses')[2]
    ses <- str_match(base, '_ses-(.*)_task')[2]
    df <- dplyr::bind_rows(Ext, Int2, Int3, Catch, Misses) %>%
        mutate(pseudonym = paste('sub-', sub, sep=''),
               Timepoint = paste('ses-', ses, sep=''),
               RespondingHand = resphand,
               Group = group) %>%
        relocate(pseudonym, Timepoint, trial_type, response_time, trial_number) %>%
        arrange(trial_number)
    
    # Compute variables
    if(!str_detect(tsvfile, 'practice')){
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_percentage_correct.R')
            df <- compute_percentage_correct(df)
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_switches.R')
            df <- compute_bp_switches(df)
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_coeff_of_var.R')
            df <- compute_bp_coeff_of_var(df)
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_repetitions.R')
            df <- compute_bp_repetitions(df)
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_adjacency.R')
            df <- compute_bp_adjacency(df) 
            
    }
    
    write_csv(df, outputname)

}
