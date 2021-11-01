#Converts column types of one df to fit another
#Useful when attempting to join dfs
#Note: Does not deal well <time> variables
#https://stackoverflow.com/questions/49215193/r-error-cant-join-on-because-of-incompatible-types

matchColClasses <- function(df1, df2) {
  
  sharedColNames <- names(df1)[names(df1) %in% names(df2)]
  sharedColTypes <- sapply(df1[,sharedColNames], class)
  
  for (n in sharedColNames) {
    class(df2[, n]) <- sharedColTypes[n]
  }
  
  return(df2)
}