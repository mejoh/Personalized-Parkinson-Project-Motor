merge_csv_to_file <- function(fps, outputname){
  
  df <- read_csv(fps[1]) %>%
    mutate(across(everything(), as.character))
  names(df) <- gsub("\\_[1-2]", "", names(df))    # PIT subjects have _[1-2] at the end of colnames. Can safely be removed
  for(n in fps){
    tmp <- read_csv(n) %>%
      mutate(across(everything(), as.character))
    names(tmp) <- gsub("\\_[1-2]", "", names(tmp))
    df <- full_join(df,tmp)
  }

  write_csv(df, outputname)
  
}