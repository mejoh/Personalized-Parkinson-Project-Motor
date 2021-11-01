change_condition_labels <- function(df){
    
    df1 <- df
    df1$trial_type[df1$trial_type == 'Ext'] <- '1choice'
    df1$trial_type[df1$trial_type == 'Int2'] <- '2choice'
    df1$trial_type[df1$trial_type == 'Int3'] <- '3choice'
    
    df1 <- df1 %>%
        mutate(trial_type = factor(trial_type))
    
    df1
    
}