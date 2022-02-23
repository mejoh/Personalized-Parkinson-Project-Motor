collapse_by_condition <- function(df, summaryfun='mean'){
        
    library(doBy)
    
    # Find variables that have a single value per subject. These will be used as 'id variables' for summaryBy
    non_id_vars <- c('pseudonym','Timepoint','trial_type','response_time','trial_number','onset',
                      'duration','event_type','button_pressed','button_expected','correct_response','block')
    c <- colnames(df)
    id_vars <- c[!c %in% non_id_vars]
    
    # Collapse response times
    if(summaryfun == 'mean'){
            f <- function(x) mean(x, na.rm=TRUE)    
    }else if(summaryfun == 'median'){
            f <- function(x) median(x, na.rm=TRUE)
    }else{
            stop('Summary function not defined')
    }
    df1 <- summaryBy(response_time ~ pseudonym + Timepoint + trial_type, id=id_vars, FUN=f, data = df, keep.names = TRUE)
    
    df1
    
}