# Enables conversion between long and wide data frames with respect to medication
# If lengthen = TRUE, lengthen data frame by medication Applicable for wide data frames
# If lengthen = FALSE, widen data frame by medication Applicable for long data frames
# CAUTION: Not all Up3 vars are doubles, and are therefore not possible to lengthen
         # Solve by subsetting beforehand
# CAUTION: Multiple Up3Of/On* vars in the data frame will increase the levels of factor Medication.
         # Solve by subsetting beforehand, and after reshaping. 

reshape_by_medication <- function(df, lengthen = TRUE){
        if(lengthen == TRUE){
                df.long <- df %>%
                        pivot_longer(cols = starts_with('Up3'),
                                     names_to = c('Medication', 'Subscore'),
                                     names_sep = 5,
                                     names_transform = list(Medication = as.factor),
                                     values_to = 'Severity')
                print(df.long)
        }else if(lengthen == FALSE){
                df.wide <- df %>%
                        pivot_wider(names_from = c('Medication','Subscore'),
                                    names_sep = '',
                                    values_from = 'Severity')
                print(df.wide)
        }
}