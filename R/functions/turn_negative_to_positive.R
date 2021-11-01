turn_negative_to_positive <- function(df, var){
  
  df1 <- df
  
  r <- range(df1[var], na.rm = TRUE)
  if(min(r) < 0){
    df1[var] <- abs(df1[var])
  }
  
}