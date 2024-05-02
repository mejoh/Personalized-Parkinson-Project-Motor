retrieve_resphand <- function(filename='P:/3022026.01/pep/bids/derivatives/manipulated_merged_motor_task_mri_2023-09-15.csv'){
    
    df <- read_csv(filename, 
                   col_select = c('pseudonym', 'Timepoint','Group','RespondingHand')) %>%
        group_by(pseudonym, Group, Timepoint) %>%
        summarise(across(everything(), ~first(.x))) %>%
        ungroup()
    
    df
    
}