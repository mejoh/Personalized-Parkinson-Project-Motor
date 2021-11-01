initialize_df <- function(outputdir){
  
  ColNames <- dir(outputdir,'UniqueColumnNames.txt', full.names = TRUE) %>% read_lines()
  nrsubjects <- dir(paste(outputdir,sep='/'), 'sub.*') %>% length()
  df <- tibble('var' = rep('', nrsubjects))
  for(i in 1:(length(ColNames) - 1)){
    df <- bind_cols(df, tibble(var = rep('', nrsubjects)))
  }
  
  df
  
}