reverse_STAI_values <- function(df){
  
  reverse_variable_values <- function(var, valrange){
    
    var <- as.numeric(var)
    opposite <- max(valrange):min(valrange)
    
    for(n in 1:length(var)){
      if(is.na(var[n])){
        next
      }
      for(v in 1:length(valrange)){
        if(sum(var[n] == valrange) > 0 & var[n] == valrange[v]){
          var[n] <- opposite[v]
          break
        }else if(sum(var[n] == valrange) == 0){
          var[n] <- NA
        }
      }
    }
    
    return(var)
    
  }
  
  valrange <- 1:4
  # FIX: STAI state variables Stai11, 12, 15, 18, 111, 115, 116, 119, 120 needs to be reversed
  df$StaiState01 <- reverse_variable_values(df$StaiState01, valrange)
  df$StaiState02 <- reverse_variable_values(df$StaiState02, valrange)
  df$StaiState05 <- reverse_variable_values(df$StaiState05, valrange)
  df$StaiState08 <- reverse_variable_values(df$StaiState08, valrange)
  df$StaiState11 <- reverse_variable_values(df$StaiState11, valrange)
  df$StaiState15 <- reverse_variable_values(df$StaiState15, valrange)
  df$StaiState16 <- reverse_variable_values(df$StaiState16, valrange)
  df$StaiState19 <- reverse_variable_values(df$StaiState19, valrange)
  df$StaiState20 <- reverse_variable_values(df$StaiState20, valrange)
  
  # FIX: STAI trait variables Stai21, 23, 26, 27, 210, 213, 214, 215, 216, 219 needs to be reversed
  df$StaiTrait01 <- reverse_variable_values(df$StaiTrait01, valrange)
  df$StaiTrait03 <- reverse_variable_values(df$StaiTrait03, valrange)
  df$StaiTrait06 <- reverse_variable_values(df$StaiTrait06, valrange)
  df$StaiTrait07 <- reverse_variable_values(df$StaiTrait07, valrange)
  df$StaiTrait10 <- reverse_variable_values(df$StaiTrait10, valrange)
  df$StaiTrait13 <- reverse_variable_values(df$StaiTrait13, valrange)
  df$StaiTrait14 <- reverse_variable_values(df$StaiTrait14, valrange)
  df$StaiTrait15 <- reverse_variable_values(df$StaiTrait15, valrange)
  df$StaiTrait16 <- reverse_variable_values(df$StaiTrait16, valrange)
  df$StaiTrait19 <- reverse_variable_values(df$StaiTrait19, valrange)
  
  df
  
}