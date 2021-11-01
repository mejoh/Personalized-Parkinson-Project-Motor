manipulate_motor_task_csv <- function(datafile, collapse=FALSE){
    
    df <- read_csv(datafile)
    
    ##### Change c(Ext,Int2,Int3) to c(1choice, 2choice, 3choice) #####
    source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/change_condition_labels.R')
    df <- change_condition_labels(df)
    #####
    
    ##### Collapse condition #####
    if(collapse){
            source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/collapse_by_condition.R')
            df <- df %>% filter(correct_response == 'Hit')
            df <- collapse_by_condition(df, summaryfun = 'median')
            outputname <- paste(dirname(datafile), '/manipulated_collapsed_', basename(datafile), sep = '')
    }else{
            outputname <- paste(dirname(datafile), '/manipulated_', basename(datafile), sep = '')
    }
    #####
    
    ##### Write to file #####
    write_csv(df, outputname)
    #####
    
}