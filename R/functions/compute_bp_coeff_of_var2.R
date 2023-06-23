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