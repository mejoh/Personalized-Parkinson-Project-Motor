compute_bp_adjacency <- function(df){
    
    df1 <- df %>%
        separate(button_expected, c('Expected_1','Expected_2','Expected_3'), sep = c(1, 2), convert = TRUE)
    
    adjacency_counter <- 0
    non_adjacency_counter <- 0
    for(v in 1:nrow(df1)){
        if(str_detect(df1$trial_type[v],'Int') & v != 1 & df1$correct_response[v] != 'Miss' & v != 1){
            preceding <- df1$button_pressed[v-1]
            expected <- c(df1$Expected_1[v],df1$Expected_2[v],df1$Expected_3[v])
            expected <- expected[!is.na(expected)]
            pressed <- df1$button_pressed[v]
            exp_pre_diff <- expected - preceding
            if(!is.na(preceding) & !is.na(pressed)){
                if((preceding-1 %in% expected | preceding+1 %in% expected) & max(exp_pre_diff) > 1){
                    if(pressed != preceding-1 & pressed != preceding+1){
                        non_adjacency_counter <- non_adjacency_counter+1
                    }else if(pressed == preceding-1 | pressed == preceding+1){
                        adjacency_counter <- adjacency_counter+1
                    }
                }
            }
        }
    }
    adjacency_ratio <- adjacency_counter / (adjacency_counter + non_adjacency_counter)
    
    df <- df %>%
        mutate(Button.Press.Adjacent = adjacency_counter,
               Button.Press.NonAdjacent = non_adjacency_counter,
               Button.Press.AdjacentRatio = adjacency_ratio)
    
    df
    
    
}