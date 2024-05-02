generate_motor_task_csv <- function(bidsdir='/project/3022026.01/pep/bids', outputdir=paste(bidsdir,'derivatives',sep='/'), force = TRUE, intermediate_output=TRUE){
    
    library(tidyverse)
    library(tidyjson)
    library(jsonlite)
    library(lubridate)
    
    # bidsdir <- 'P:/3022026.01/pep/bids'
    # subject <- 'sub-POMU0AEE0E7E9F195659'
    # visit <- 'ses-POMVisit1'
    # run <- 'run-1'
    
    ##### Set up intermediate output directory
    tmpdir <- paste(outputdir, 'tmp', sep='/')
    dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)
    files <- dir(tmpdir, '.*', full.names = TRUE)
    if(force){
        sapply(files, file.remove)
    }
    #####
    
    ##### TSV-to-CSV conversion #####
    source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/convert_motor_tsv_to_csv.R')
    searchpattern <- 'task-motor_acq-.*_run-[1-9]_events.tsv'
    subjects <- dir(bidsdir, 'sub-.*')
    for(n in subjects){
        visits <- dir(paste(bidsdir,n,sep='/'), 'ses-.*Visit.*')
        for(v in visits){
            searchdir <- paste(bidsdir, n, v, 'beh', sep='/')
            files <- dir(searchdir, searchpattern, full.names = TRUE)
            if(length(files)<1){
                next
            }
            for(f in files){
                if(str_detect(f, 'practice')){
                    environment <- 'practice'
                }else{
                    environment <- 'mri'
                }
                run <- str_extract(f, 'run-[0-9]')
                outputname <- paste(n, v, environment, run, 'tsv2csv.csv',sep='_')
                outputname <- paste(tmpdir, outputname, sep='/')
                convert_motor_tsv_to_csv(f, outputname)
            }
        }
    }
    #####
    
    ##### Merge files #####
    source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/merge_csv_to_file.R')
    environments <- c('mri', 'practice')
    for(e in environments){
        searchpattern <- paste('sub.*', e, '.*.tsv2csv', sep='')
        fps <- dir(paste(tmpdir,sep='/'), searchpattern, full.names = TRUE)
        merged_csv_file <- paste(outputdir, '/merged_motor_task_', e, '_', today(), '.csv', sep='')
        merge_csv_to_file(fps, merged_csv_file)
    }
    #####
    
    ##### Clean up intermediate output #####
    if(!intermediate_output){
            unlink(tmpdir, recursive = TRUE)
    }
    #####
    
    ##### NOT NECESSARY: Manipulate merged csv file #####
    # Collapse = TRUE will summarize RTs as the median by condition
    source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/manipulate_motor_task_csv.R')
    for(e in environments){
            merged_csv_file <- paste(outputdir, '/merged_motor_task_', e, '_', today(), '.csv', sep='')
            manipulate_motor_task_csv(merged_csv_file, collapse = FALSE)
            manipulate_motor_task_csv(merged_csv_file, collapse = TRUE)
    }
    #####
    
    
}