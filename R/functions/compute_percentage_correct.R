compute_percentage_correct <- function(df, cutoff=.33){
        
        # Calculate percentage correct per condition
        Ext <- filter(df, event_type == 'response', trial_type == 'Ext')
        Int2 <- filter(df, event_type == 'response', trial_type == 'Int2')
        Int3 <- filter(df, event_type == 'response', trial_type == 'Int3')
        Catch <- filter(df, event_type == 'cue', trial_type == 'Catch')
        
        percentage_correct <- tibble(trial_type = c('Ext','Int2','Int3','Catch'),
                                     Percentage.Correct = c(nrow(filter(df, trial_type == 'Ext', correct_response == 'Hit')) / nrow(Ext),
                                                            nrow(filter(df, trial_type == 'Int2', correct_response == 'Hit')) / nrow(Int2),
                                                            nrow(filter(df, trial_type == 'Int3', correct_response == 'Hit')) / nrow(Int3),
                                                            nrow(filter(df, trial_type == 'Catch', correct_response == 'Hit')) / nrow(Catch))) %>%
                na.omit()
        
        # Determine whether performance is above cutoff
        BelowCutoff <- percentage_correct %>%
                filter(trial_type == 'Ext') %>%
                select(Percentage.Correct) %>%
                as.numeric < cutoff
        
        percentage_correct <- percentage_correct %>%
                mutate(Percentage.Correct.BelowCutoff = BelowCutoff)
        
        df1 <- full_join(df, percentage_correct, by = 'trial_type')
        
        df1
    
}