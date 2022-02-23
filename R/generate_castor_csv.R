generate_castor_csv <- function(bidsdir, outputdir=paste(bidsdir,'derivatives',sep='/'), force=FALSE, intermediate_output=TRUE){

        library(tidyverse)
        library(tidyjson)
        library(lubridate)
        
        # bidsdir <- 'P:/3022026.01/pep/ClinVars4'
        
        ##### Set up intermediate output directory
        tmpdir <- paste(bidsdir, 'derivatives', 'tmp', sep='/')
        dir.create(tmpdir, showWarnings = FALSE, recursive = TRUE)
        files <- dir(tmpdir, '.*', full.names = TRUE)
        if(force){
                sapply(files, file.remove)
        }
        #####
        
        ##### JSON-to-CSV conversion #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/convert_json_to_csv.R')
        subjects <- dir(bidsdir, 'sub-.*')
        # set.seed(1234)
        # sample.int(length(subjects), 10)
        # subjects <- subjects[c(374, 180, 118, 481, 233, 403, 377, 271, 248, 218)]
        for(n in subjects){
                visits <- dir(paste(bidsdir,n,sep='/'), 'ses-.*Visit.*')
                for(v in visits){
                        outputname <- paste(n, v, 'json2csv.csv',sep='_')
                        outputname <- paste(tmpdir, outputname, sep='/')
                        convert_json_to_csv(bidsdir, n, v, outputname)
                }
        }
        #####
        
        ##### Variable documentation #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/write_colnames_list.R')
        write_colnames_list(tmpdir)
        #####
        
        ##### Read converted CSV files to data frame and write to file #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/merge_csv_to_file.R')
        fps <- dir(paste(tmpdir,sep='/'), 'sub.*.json2csv', full.names = TRUE)
        merged_csv_file <- paste(outputdir, '/merged_', today(), '.csv', sep='')
        merge_csv_to_file(fps, merged_csv_file)
        #####
        
        ##### Clean up intermediate output #####
        if(!intermediate_output){
                unlink(tmpdir, recursive = TRUE)
        }
        #####
        
        ##### Manipulate castor csv file #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/manipulate_castor_csv.R')
        manipulate_castor_csv(merged_csv_file)
        #####
        

}




