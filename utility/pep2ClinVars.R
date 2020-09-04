dPEP <- 'P:/3022026.01/pep/pulled-data2/'
dClinVars <- 'P:/3022026.01/pep/ClinVars/'
dContents <- dir(dPEP)
idx <- grep('^[A-Z0-9]', dContents)
Subjects <- dContents[idx]
for(Sub in Subjects){
        
        dSub <- paste(dPEP, Sub, sep='')
        dSubContents <- dir(paste(dPEP, Sub, sep=''))
        dFunc <- dSubContents[str_which(dSubContents, 'Visit1.MRI.Func')]
        dFuncCont <- dir(paste(dSub, '/', dFunc, sep = ''))
        pseudonym <- dFuncCont[str_which(dFuncCont, 'sub-')]
        
        files_to_copy <- list.files(dSub, 'Castor*', full.names = TRUE)
        output_folder <- paste(dClinVars, pseudonym, sep = '')
        if(!dir.exists(output_folder)) dir.create(output_folder)
        file.copy(files_to_copy, output_folder)
        
}
