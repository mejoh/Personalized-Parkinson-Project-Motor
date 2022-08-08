# 'dat' is a 2-column data frame in long format
# Column 1 reflects rater, or classification strategy
# Column 2 reflects decision, or subtype

compare_count <- function(dat, mosaic=TRUE, simulate.p = FALSE){
        
    library(vcd)    
    library(chisq.posthoc.test)
        
    cat('\n<<<Comparison of counts (Chi^2)>>>\n')
    
    tab <- t(table(dat))
    
    chi2 <- chisq.test(tab, simulate.p.value = simulate.p, B = 5000)
    cat('\n<<<Observed>>>\n')
    print(chi2$observed)
    cat('\n<<<Expected>>> \n')
    print(chi2$expected)
    cat('\n<<<Statistics>>> \n')
    print(chi2)
    cat('\n<<<Post hoc>>> \n')
    print(chisq.posthoc.test(tab))
    
    if(mosaic) mosaic(tab)
    
}