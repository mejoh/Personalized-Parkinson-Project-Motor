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
      
      # Find values that are not NA. Skip if there are more than 1 unique values
      non.na.val <- unique(vals[val.idx,])
      if(nrow(non.na.val)>1) next
      
      # Replace NAs with real values
      vals[na.idx,] <- non.na.val
      
      #Find column and row index in data frame where values should be replaced
      col.idx <- colnames(df) == var
      row.idx <- df$pseudonym == id
      
      # Perform replacement
      df[row.idx, col.idx] <- vals
      
    }
  }
  
  return(df)
  
}