compute_percentage_correct <- function(df, cutoff=.33){
        
        # Calculate percentage correct per condition
        Ext <- filter(df, event_type == 'response', trial_type == 'Ext')
        Int2 <- filter(df, event_type == 'response', trial_type == 'Int2')
        Int3 <- filter(df, event_type == 'response', trial_type == 'Int3')
        Catch <- filter(df, event_type == 'cue', trial_type == 'Catch')
        
        percentage_correct <- tibble(trial_type = c('Ext','Ext','Ext','Int2','Int2','Int2','Int3','Int3','Int3','Catch','Catch','Catch'),
                                     block = c(1,2,3,1,2,3,1,2,3,1,2,3),
                                     Percentage.Correct = c(nrow(filter(df, trial_type == 'Ext', block == 1, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Ext', block == 1)),
                                                            nrow(filter(df, trial_type == 'Ext', block == 2, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Ext', block == 2)),
                                                            nrow(filter(df, trial_type == 'Ext', block == 3, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Ext', block == 3)),
                                                            
                                                            nrow(filter(df, trial_type == 'Int2', block == 1, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int2', block == 1)),
                                                            nrow(filter(df, trial_type == 'Int2', block == 2, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int2', block == 2)),
                                                            nrow(filter(df, trial_type == 'Int2', block == 3, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int2', block == 3)),
                                                            
                                                            nrow(filter(df, trial_type == 'Int3', block == 1, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int3', block == 1)),
                                                            nrow(filter(df, trial_type == 'Int3', block == 2, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int3', block == 2)),
                                                            nrow(filter(df, trial_type == 'Int3', block == 3, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Int3', block == 3)),
                                                            
                                                            nrow(filter(df, trial_type == 'Catch', block == 1, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Catch', block == 1)),
                                                            nrow(filter(df, trial_type == 'Catch', block == 2, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Catch', block == 2)),
                                                            nrow(filter(df, trial_type == 'Catch', block == 3, correct_response == 'Hit')) / nrow(filter(df, trial_type == 'Catch', block == 3)))) %>%
                na.omit()
        
        # Determine whether performance is above cutoff
        BelowCutoff <- percentage_correct %>%
                filter(trial_type == 'Ext') %>%
                select(Percentage.Correct) %>%
                colSums()/3 %>%
                as.numeric < cutoff
        
        percentage_correct <- percentage_correct %>%
                mutate(Percentage.Correct.BelowCutoff = BelowCutoff)
        
        df1 <- full_join(df, percentage_correct, by = c('trial_type','block'))
        
        df1
    
}