library(tidyverse)

# Define input and output directories
# dPEP_HomeQuest <- 'P:/3022026.01/pep/download2/'
# dPEP_Visit <- 'P:/3022026.01/pep/download2/'
# dPEP_COVID <- 'P:/3022026.01/pep/download2/'
dPEP <- 'P:/3022026.01/pep/download3_castor/'
dClinVars <- 'P:/3022026.01/pep/ClinVars3'

# Clean out output directory
if(dir.exists(dClinVars)){
        unlink(dClinVars, recursive = TRUE)
        dir.create(paste(dClinVars,'derivatives','tmp',sep='/'), recursive = TRUE)
}else{
        dir.create(paste(dClinVars,'derivatives','tmp',sep='/'), recursive = TRUE)
}

# dContents_HomeQuest <- dir(dPEP_HomeQuest)
# idx_HomeQuest <- grep('^[A-Z0-9]', dContents_HomeQuest)
# Subjects_HomeQuest <- dContents_HomeQuest[idx_HomeQuest]
# 
# dContents_Visit <- dir(dPEP_Visit)
# idx_Visit <- grep('^[A-Z0-9]', dContents_Visit)
# Subjects_Visit <- dContents_Visit[idx_Visit]
# 
# dContents_COVID <- dir(dPEP_COVID)
# idx_COVID <- grep('^[A-Z0-9]', dContents_COVID)
# Subjects_COVID <- dContents_Visit[idx_COVID]

dContents <- dir(dPEP)
idx <- grep('^[A-Z0-9]', dContents)
Subjects <- dContents[idx]

# Subjects = unique(c(Subjects_HomeQuest, Subjects_Visit, Subjects_COVID))
count=length(Subjects)
for(Sub in Subjects){
        
        # # Find pseudonym
        # dSub <- paste(dPEP_HomeQuest, Sub, sep='')
        # pseudonym <- paste('sub-POMU', substr(Sub,1,16), sep='')
        # 
        # # Collect all files that need to be copied to ClinVars
        # download_HomeQuest_files <- list.files(paste(dPEP_HomeQuest, Sub, sep = ''), full.names = TRUE)
        # download_HomeQuest_files <- download_HomeQuest_files[str_detect(download_HomeQuest_files, 'Castor.')]
        # download_files  <- list.files(paste(dPEP_Visit, Sub, sep = ''), full.names = TRUE)
        # download_files <- download_files[str_detect(download_files, 'Castor.')]
        # download_COVID_files  <- list.files(paste(dPEP_COVID, Sub, sep = ''), full.names = TRUE)
        # download_COVID_files <- download_COVID_files[str_detect(download_COVID_files, 'Castor.')]
        # all_files <- unique(c(download_HomeQuest_files, download_files, download_COVID_files))
        
        # Find pseudonym
        dSub <- paste(dPEP, Sub, sep='')
        pseudonym <- paste('sub-POMU', substr(Sub,1,16), sep='')
        
        # Collect all files that need to be copied to ClinVars
        download_files  <- list.files(paste(dPEP, Sub, sep = ''), full.names = TRUE)
        download_files <- download_files[str_detect(download_files, 'Castor.')]
        all_files <- unique(download_files)
        
        for(f in all_files){
                fname <- basename(f)
                # Determine which folder to put a file in based on its name
                if(str_detect(fname, 'HomeQuestionnaires1') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMHomeQuestionnaires1'
                }else if(str_detect(fname, 'HomeQuestionnaires2') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMHomeQuestionnaires2'
                }else if(str_detect(fname, 'HomeQuestionnaires3') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMHomeQuestionnaires3'
                }else if(str_detect(fname, 'HomeQuestionnaires.Visit1') & str_detect(fname, 'PIT')){
                        subfolder <- 'PITHomeQuestionnaires1'
                }else if(str_detect(fname, 'HomeQuestionnaires.Visit2') & str_detect(fname, 'PIT')){
                        subfolder <- 'PITHomeQuestionnaires2'
                }else if(str_detect(fname, 'Visit1') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMVisit1'
                }else if(str_detect(fname, 'Visit2') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMVisit2'
                }else if(str_detect(fname, 'Visit3') & !str_detect(fname, 'PIT')){
                        subfolder <- 'POMVisit3'
                }else if(str_detect(fname, 'Visit_1') & str_detect(fname, 'PIT')){
                        subfolder <- 'PITVisit1'
                }else if(str_detect(fname, 'Visit_2') & str_detect(fname, 'PIT')){
                        subfolder <- 'PITVisit2'
                }else if(str_detect(fname, 'COVID') & str_detect(fname, 'PackBasic')){
                        subfolder <- 'COVIDbasic'
                }else if(str_detect(fname, 'COVID') & str_detect(fname, 'PackFinal')){
                        subfolder <- 'COVIDfinal'
                }else if(str_detect(fname, 'COVID') & str_detect(fname, 'PackWeek1')){
                        subfolder <- 'COVIDweek1'
                }else if(str_detect(fname, 'COVID') & str_detect(fname, 'PackWeek2')){
                        subfolder <- 'COVIDweek2'
                }else if(str_detect(fname, 'COVID') & str_detect(fname, 'CovPackDaily')){
                        subfolder <- 'COVIDdaily'
                }
                
                destination <- paste(dClinVars, '/', pseudonym, '/ses-', subfolder, sep = '')
                if(!dir.exists(destination)) dir.create(destination, recursive = TRUE)
                new_file <- paste(destination, '/', fname, '.json', sep='')
                file.copy(f, new_file)
                
        }
        
        count <- count-1
        cat('Number of subjects remaining:', count, '\n')
        
#        # DEPRECATED : Copy files
#        subset <- c('HomeQuestionnaires1', 'HomeQuestionnaires2', 'HomeQuestionnaires3', 'Visit1', 'Visit2', 'Visit3')
#        for(s in subset){
#                
#                files_to_copy <- list.files(dSub, paste('Castor.', s, '.*', sep=''), full.names = TRUE)
#                if(is_empty(files_to_copy)) next
#                
#                output_folder <- paste(dClinVars, pseudonym, '/ses-', s, sep = '')
#                if(!dir.exists(output_folder)) dir.create(output_folder, recursive = TRUE)
#                file.copy(files_to_copy, output_folder)
#        
#                # Add .json extension
#                old.names <- list.files(output_folder, paste('Castor.', s, '*', sep=''), full.names = TRUE)
#                file.rename(old.names, paste(old.names, '.json', sep=''))
#        }
        
}

