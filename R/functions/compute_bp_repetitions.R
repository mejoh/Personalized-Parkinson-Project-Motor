compute_bp_repetitions <- function(df){
    
    df1 <- df %>%
        separate(button_expected, c('Expected_1','Expected_2','Expected_3'), sep = c(1, 2), convert = TRUE)
    
    repetition_counter <- 0
    non_repetition_counter <- 0
    for(v in 1:nrow(df1)){
        if((str_detect(df1$trial_type[v],'NChoice2') | str_detect(df1$trial_type[v],'NChoice3'))  & df1$correct_response[v] != 'Miss' & v != 1){
            preceding <- df1$button_pressed[v-1]
            expected <- c(df1$Expected_1[v],df1$Expected_2[v],df1$Expected_3[v])
            expected <- expected[!is.na(expected)]
            pressed <- df1$button_pressed[v]
            if(!is.na(preceding) & !is.na(pressed)){
                if(sum(preceding==expected)>0 & pressed == preceding){
                    repetition_counter <- repetition_counter + 1
                }else if(sum(preceding==expected)>0 & pressed != preceding){
                    non_repetition_counter <- non_repetition_counter + 1
                }
            }
        }
    }
    
    repetition_ratio <- repetition_counter / (repetition_counter + non_repetition_counter)
    
    df <- df %>%
        mutate(Button.Press.Repetitions = repetition_counter,
               Button.Press.NonRepetitions = non_repetition_counter,
               Button.Press.RepetitionRatio = repetition_ratio)
    
    df
    
}
