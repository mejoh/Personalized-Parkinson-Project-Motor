# 'dat' is a 2-column data frame in wide format
# Column 1 reflects decision of classification #1
# Column 2 reflects decision of classification #2

compare_agreement <- function(dat){
        
        library(vcd)    
        
        cat('\n<<<Agreement (Cohen\'s kappa)>>>\n')
        
        dat1 <- dat
        
        tab <- table(dat1)
        cat('\n<<<Observed>>>\n')
        print(tab)
        
        k <- Kappa(tab)
        cat('\n<<<Statistics>>>\n')
        print(k, CI = TRUE)
        
        SubtypeMatch <- dat1[,1] == dat1[,2]
        colnames(SubtypeMatch) <- c('Match')
        SubtypeMatch <- SubtypeMatch %>%
                as_tibble() %>%
                summarise(n=n(), Match=sum(SubtypeMatch), notMatch=n-Match, Agreement=Match/n)
        cat('\n<<<Matches>>>\n')
        print(SubtypeMatch)
        
        agreementplot(tab, reverse_y = TRUE)
    
}