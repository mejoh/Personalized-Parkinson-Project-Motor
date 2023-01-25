merge_csv_to_file <- function(fps, outputname){
  
        df <- read_csv(fps[1], show_col_types = FALSE) %>%
                mutate(across(everything(), as.character))
        for(n in fps){
                msg <- paste('Writing', n, '\n')
                cat(msg)
                tmp <- read_csv(n, show_col_types = FALSE) %>%
                        mutate(across(everything(), as.character))
                if(str_detect(n, 'ses-PITVisit')){
                        names(tmp) <- gsub("\\_[1-2]", "", names(tmp)) # PIT subjects have _[1-2] at the end of colnames. Can safely be removed
                }
                df <- full_join(df, tmp, show_col_types = FALSE)
        }
        
        msg <- paste('Writing', outputname, '\n')
        cat(msg)
        write_csv(df, outputname)
  
}