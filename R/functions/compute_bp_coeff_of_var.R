compute_bp_coeff_of_var <- function(df){
    
    Button.Press.Mean = filter(df, event_type == 'response', correct_response == 'Hit') %>% pull(var = button_pressed) %>% mean
    Button.Press.Sd = filter(df, event_type == 'response', correct_response == 'Hit') %>% pull(var = button_pressed) %>% sd
    Button.Press.CoV = Button.Press.Sd / Button.Press.Mean
    
    df <- df %>%
        mutate(Button.Press.Mean = Button.Press.Mean,
               Button.Press.Sd = Button.Press.Sd,
               Button.Press.CoV = Button.Press.CoV)
    
}
