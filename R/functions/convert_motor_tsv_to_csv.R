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
    NChoice1 <- filter(events, event_type == 'response', trial_type == 'NChoice1')
    NChoice2 <- filter(events, event_type == 'response', trial_type == 'NChoice2')
    NChoice3 <- filter(events, event_type == 'response', trial_type == 'NChoice3')
    Catch <- filter(events, event_type == 'cue', trial_type == 'Catch')
    Misses <- filter(events, event_type == 'cue', correct_response == 'Miss')
    
    # Initialize data frame
    base <- basename(tsvfile)
    sub <- str_match(base, 'sub-(.*)_ses')[2]
    ses <- str_match(base, '_ses-(.*)_task')[2]
    df <- dplyr::bind_rows(NChoice1, NChoice2, NChoice3, Catch, Misses) %>%
        mutate(pseudonym = paste('sub-', sub, sep=''),
               Timepoint = paste('ses-', ses, sep=''),
               RespondingHand = resphand,
               Group = group) %>%
        relocate(pseudonym, Timepoint, trial_type, response_time, trial_number) %>%
        arrange(trial_number)
    
    # Compute variables
    if(!str_detect(tsvfile, 'practice')){
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_percentage_correct.R')
            df <- compute_percentage_correct(df)
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_switches.R')
            df <- compute_bp_switches(df)
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_coeff_of_var.R')
            bp_cov <- df %>%
                    filter(event_type=='response',
                           correct_response == 'Hit') %>%
                    group_by(pseudonym,Group,Timepoint) %>%
                    mutate(Button.Press.CoV=bp_var(button_pressed)) %>%
                    summarise(across(everything(), ~first(.x))) %>%
                    ungroup() %>%
                    select(pseudonym,Group,Timepoint,Button.Press.CoV)
            df <- df %>%
                    left_join(., bp_cov, by=c('pseudonym','Group','Timepoint'))
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_repetitions.R')
            df <- compute_bp_repetitions(df)
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_bp_adjacency.R')
            df <- compute_bp_adjacency(df) 
            
    }
    
    write_csv(df, outputname)

}
