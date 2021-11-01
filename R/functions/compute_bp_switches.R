compute_bp_switches <- function(df){
    
    df1 <- df %>%
        separate(button_expected, c('Expected_1','Expected_2','Expected_3'), sep = c(1, 2), convert = TRUE)
    
    switch_counter <- 0
    non_switch_counter <- 0
    for(v in 1:nrow(df1)){
        if(str_detect(df1$trial_type[v],'Int') & df1$correct_response[v] != 'Miss' & v != 1){
            preceding <- df1$button_pressed[v-1]
            expected <- c(df1$Expected_1[v],df1$Expected_2[v],df1$Expected_3[v])
            expected <- expected[!is.na(expected)]
            pressed <- df1$button_pressed[v]
            if(!is.na(preceding) & !is.na(pressed)){
                if(sum(preceding==expected)>0 & preceding != pressed){
                    switch_counter <- switch_counter+1
                }else if(sum(preceding==expected)>0 & preceding == pressed){
                    non_switch_counter <- non_switch_counter+1
                }
            }
        }
    }
    switch_ratio <- switch_counter / (non_switch_counter + switch_counter)
    
    df <- df %>%
        mutate(Button.Press.Switch = switch_counter,
               Button.Press.NonSwitch = non_switch_counter,
               Button.Press.SwitchRatio = switch_ratio)
    
    df
    
}