write_colnames_list <- function(filepath){
  
  json2csvfiles <- dir(filepath, 'sub-.*json2csv.csv')
  
  ColNames <- c()
  for(n in json2csvfiles){
    df <- read_csv(paste(filepath,n,sep='/'), col_types = cols())
    c <- colnames(df)
    ColNames <- c(ColNames, c)
  }
  ColNames <- unique(ColNames)
  write_lines(ColNames, paste(filepath, 'UniqueColumnNames.txt', sep='/'))
  
}
