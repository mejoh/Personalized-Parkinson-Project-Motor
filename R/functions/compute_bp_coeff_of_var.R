compute_bp_coeff_of_var <- function(df){
        
    df %>%
                mutate(Button.Press.Cov = bp_var(button_pressed))
    
    # DEPRECATED: OLD IMPLEMENTATION
    # Button.Press.Mean = filter(df, event_type == 'response', correct_response == 'Hit') %>% pull(var = button_pressed) %>% mean
    # Button.Press.Sd = filter(df, event_type == 'response', correct_response == 'Hit') %>% pull(var = button_pressed) %>% sd
    # Button.Press.CoV = Button.Press.Sd / Button.Press.Mean
    # 
    # df <- df %>%
    #     mutate(Button.Press.Mean = Button.Press.Mean,
    #            Button.Press.Sd = Button.Press.Sd,
    #            Button.Press.CoV = Button.Press.CoV)
    
}

bp_var <- function(dat){
        
        # Summarise number of presses by button
        # Calculate the mean and sd across buttons
        # The ideal situation would be:
        # 1     2       3       4
        # 30    30      30      30
        # Mean = 30
        # SD   = 0
        # CoV  = 0
        # An example situation indicating increased reliance on button 4
        # 1     2       3       4
        # 15    30      30      45
        # Mean = 30
        # SD   = 12.2
        # CoV  = 0.41
        
        d <- na.omit(dat)
        tab <- table(d) 
        
        calc_cov <- function(tab){
                tryCatch({
                        # f <- chisq.test(tab) %>%
                        #     effectsize() %>%
                        #     as_tibble() %>%
                        #     select(Fei) %>%
                        #     as.numeric()
                        f <- sd(tab)/mean(tab)
                        return(f)
                },
                error = function(e){
                        return(NA)
                },
                warning = function(w){
                        return(NA)
                })
        }
        
        calc_cov(tab)
        
}
