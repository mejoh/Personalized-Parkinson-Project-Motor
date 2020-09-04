library(tidyverse)

# Define input and output directories
dPEP <- 'P:/3022026.01/pep/pulled-data2/'
dClinVars <- 'P:/3022026.01/pep/ClinVars/'

# Define list of subjects
dContents <- dir(dPEP)
idx <- grep('^[A-Z0-9]', dContents)
Subjects <- dContents[idx]
for(Sub in Subjects){
        
        # Find pseudonym
        dSub <- paste(dPEP, Sub, sep='')
        dSubContents <- dir(paste(dPEP, Sub, sep=''))
        dFunc <- dSubContents[str_which(dSubContents, 'Visit1.MRI.Func')]
        dFuncCont <- dir(paste(dSub, '/', dFunc, sep = ''))
        pseudonym <- dFuncCont[str_which(dFuncCont, 'sub-')]
        
        # Copy files
        subset <- c('HomeQuestionnaires1', 'Visit1', 'Visit2')
        for(s in subset){
                
                files_to_copy <- list.files(dSub, paste('Castor.', s, '.*', sep=''), full.names = TRUE)
                if(is_empty(files_to_copy)) next
                
                output_folder <- paste(dClinVars, pseudonym, '/ses-', s, sep = '')
                if(!dir.exists(output_folder)) dir.create(output_folder, recursive = TRUE)
                file.copy(files_to_copy, output_folder)
        
                # Add .json extension
                old.names <- list.files(output_folder, paste('Castor.', s, '*', sep=''), full.names = TRUE)
                file.rename(old.names, paste(old.names, '.json', sep=''))
        }
        
}
