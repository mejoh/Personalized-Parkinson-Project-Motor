manipulate_motor_task_csv <- function(datafile, collapse=FALSE){
    
    df1 <- read_csv(datafile)
    
    ##### DEPRECATED: Change c(Ext,Int2,Int3) to c(1choice, 2choice, 3choice) #####
    # source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/change_condition_labels.R')
    # df <- change_condition_labels(df)
    #####
    
    ##### Collapse condition #####
    if(collapse){
            source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/collapse_by_condition.R')
            df1 <- df1 %>% filter(correct_response == 'Hit')
            df1 <- collapse_by_condition(df1, summaryfun = 'median')
            outputname <- paste(dirname(datafile), '/manipulated_collapsed_', basename(datafile), sep = '')
    }else{
            outputname <- paste(dirname(datafile), '/manipulated_', basename(datafile), sep = '')
    }
    #####
    
    ##### Write to file #####
    write_csv(df1, outputname)
    #####
    
}