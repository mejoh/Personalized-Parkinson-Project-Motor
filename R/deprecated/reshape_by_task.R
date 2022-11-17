# Enables conversion between long and wide data frames with respect to motor task condition
# If lengthen = TRUE, lengthen data frame by condition. Applicable for wide data frames
# If lengthen = FALSE, widen data frame by condition. Applicable for long data frames

reshape_by_task <- function(df, lengthen = TRUE){
        
        if(lengthen == TRUE){
                df.long <- df %>%
                        pivot_longer(cols=starts_with('Response.Time'),
                                names_to='Condition',
                                names_pattern='Response.Time_(.*)',
                                values_to='Response.Time') %>%
                        select(-c(starts_with('Percentage.Correct')))
                Percentage.Correct <- df %>%
                        select(starts_with('Percentage.Correct')) %>%
                        pivot_longer(cols=c(1:3),
                                names_to = 'Condition',
                                names_pattern='Percentage.Correct_(.*)',
                                values_to='Percentage.Correct') %>%
                        select('Percentage.Correct')
                df.long <- bind_cols(df.long, Percentage.Correct)
                df.long$Condition <- as.factor(df.long$Condition)
                print(df.long)
        }else if(lengthen == FALSE){
                df.wide <- df %>%
                        pivot_wider(names_from = Condition,
                                    values_from = c(Response.Time, Percentage.Correct))
                print(df.wide)
        }
        
}