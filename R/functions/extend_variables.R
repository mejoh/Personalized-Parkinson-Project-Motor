extend_variables <- function(df, varlist){
  
  # Iterate over variables in the input list
  for(var in varlist){    
    
    # Iterate over pseudonyms
    for(id in unique(df$pseudonym)){
      
      # Subset data based on current pseudonym and current variable
      vals <- df %>%
        filter(pseudonym == id) %>%
        select(!!ensym(var))
      
      # Perform the same subsetting as above and look for NAs
      na.idx <- df %>%
        filter(pseudonym == id) %>%
        select(!!ensym(var)) %>%
        is.na %>%
        as.vector
      
      # Skip ids with no real values
      if(length(na.idx) == sum(na.idx)) next
      
      # Define index for non-NA values
      val.idx <- !na.idx
      
      # Find values that are not NA
      non.na.val <- unique(vals[val.idx,])
      # If there is only one unique value, replace all NAs with it.
      # If there are more than one unique value, replace all values with the
      # first value (baseline).
      if(nrow(non.na.val)==1){
              # Replace NAs with real values
              vals[na.idx,] <- non.na.val
      }else{
              # Define baseline value
              ba_val <- vals[1,1]
              # Replace all values with baseline value
              vals[1:nrow(vals),] <- ba_val
      }
      
      #Find column and row index in data frame where values should be replaced
      col.idx <- colnames(df) == var
      row.idx <- df$pseudonym == id
      
      # Perform replacement
      df[row.idx, col.idx] <- vals
      
    }
  }
  
  return(df)
  
}