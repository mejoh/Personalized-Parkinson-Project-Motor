elble_change <- function(T1, T2, subscore.length, alpha=0.5, percent=TRUE){
  if(!is.na(T1) & !is.na(T2)){
    
    T1 <- T1/subscore.length
    T2 <- T2/subscore.length
    diff <- T2-T1
    
    FC <- 10 ^ (alpha * diff) - 1
    PC <- 100 * FC
    
    if(percent==TRUE){
      return(PC)
    }else if(percent==FALSE){
      return(FC)
    }
  }else{
    return(NA)
  }
}