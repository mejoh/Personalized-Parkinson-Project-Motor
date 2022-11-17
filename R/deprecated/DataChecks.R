# Checks data points for each subject in the defined BIDS folder
# ID | events.tsv 1/3 | clinvars 1/2/3 | ...
library(tidyverse)
dRoot <- 'P:/3022026.01/pep'
dBIDS <- paste(dRoot, '/bids/', sep='')
dClinVars <- paste(dRoot, '/ClinVars/', sep='')
dFMRIPREP <- paste(dBIDS, 'derivatives/fmriprep/', sep='')
dAnalyses <- 'P:/3022026.01/analyses/'
dEMG <- paste(dAnalyses, 'EMG/motor/processing/', sep='')
dFirstLevel <- paste(dAnalyses, 'motor/DurAvg_ReAROMA_PMOD_TimeDer/', sep='')
cBIDS <- dir(dBIDS)
subjects <- na.omit(str_extract(cBIDS, 'sub-POMU.*'))
visits <- c('ses-Visit1', 'ses-Visit2', 'ses-Visit3')

# Function for checking wheter file exists or not
TestForPresence <- function(file){
        if(length(file) != 0 && file.exists(file)){
                return(TRUE)
        }else{
                return(FALSE)
        }
}

# Exclude subjects without motor task
Sel <- rep(TRUE, length(subjects))
for(n in 1:length(subjects)){
        Sub <- subjects[n]
        File.beh <- list.files(paste('P:/3022026.01/pep/bids/', Sub, '/', 'ses-Visit1', '/beh/', sep=''), pattern = paste(Sub, '_', 'ses-Visit1', '_task-motor_acq-MB6_run-._events.tsv', sep=''), full.names = TRUE)
        File.fmri <- list.files(paste('P:/3022026.01/pep/bids/', Sub, '/', 'ses-Visit1', '/func/', sep=''), pattern = paste(Sub, '_', 'ses-Visit1', '_task-motor_acq-MB6_run-._bold.nii.gz', sep=''), full.names = TRUE)
        if(length(File.beh)==0 || length(File.fmri)==0){
              Sel[n] <- FALSE  
        }
}
subjects <- subjects[Sel]

# Write a row for each subject and each visit indicating whether data points are present or not
df <- bind_rows()
for(n in subjects){
        for(t in visits){
                # Subject details
                Sub <- n
                Visit <- t
                File.beh <- list.files(paste('P:/3022026.01/pep/bids/', Sub, '/', Visit, '/beh/', sep=''), pattern = paste(Sub, '_', Visit, '_task-motor_acq-MB6_run-._events.tsv', sep=''), full.names = TRUE)
                File.fmri <- list.files(paste('P:/3022026.01/pep/bids/', Sub, '/', Visit, '/func/', sep=''), pattern = paste(Sub, '_', Visit, '_task-motor_acq-MB6_run-._bold.nii.gz', sep=''), full.names = TRUE)
                File.anat <- list.files(paste('P:/3022026.01/pep/bids/', Sub, '/', Visit, '/anat/', sep=''), pattern = paste(Sub, '_', Visit, '_acq-MPRAGE_rec-norm_run-._T1w.nii.gz', sep=''), full.names = TRUE)
                LastRun.beh <- length(File.beh)
                LastRun.fmri <- length(File.fmri)
                LastRun.anat <- length(File.anat)
                # BIDS
                #Events <- c() #P:/3022026.01/pep/bids/sub-POMU00A53C1AA47F6936/ses-Visit1/beh/sub-POMU00A53C1AA47F6936_ses-Visit1_task-motor_acq-MB6_run-1_events.tsv
                Events <- paste(dBIDS, Sub, '/', Visit, '/beh/', Sub, '_', Visit, '_task-motor_acq-MB6_run-', LastRun.beh, '_events.tsv', sep='')
                #ClinVars <- c() #P:/3022026.01/pep/ClinVars/sub-POMU00A53C1AA47F6936/ses-Visit1/Castor.Visit1.Motorische_taken_OFF.Updrs_3_deel_1.json
                ##Exception because variable naming is stupid...
                if(Visit=='ses-Visit1'){
                        ClinVars <- list.files(paste(dClinVars, Sub, '/', Visit, '/', sep=''), pattern =  'Castor.Visit.\\.Motorische_taken_OFF.Updrs_3_deel_1.json', full.names = TRUE)   
                }else if(Visit=='ses-Visit2'){
                        ClinVars <- list.files(paste(dClinVars, Sub, '/', Visit, '/', sep=''), pattern =  'Castor.Visit.\\.Motorische_taken_OFF.Updrs3_deel_1.json', full.names = TRUE)
                }
                #RawEye <- c() #P:/3022026.01/pep/bids/sub-POMU00A53C1AA47F6936/ses-Visit1/beh/sub-POMU00A53C1AA47F6936_ses-Visit1_task-motor_acq-smi_eyetracker.tsv
                RawEye <- paste(dBIDS, Sub, '/', Visit, '/beh/', Sub, '_', Visit, '_task-motor_acq-smi_eyetracker.tsv', sep='')
                #RawEEG <- c() #P:/3022026.01/pep/bids/sub-POMU00A53C1AA47F6936/ses-Visit1/eeg/sub-POMU00A53C1AA47F6936_ses-Visit1_task-motor_eeg.eeg
                RawEEG <- paste(dBIDS, Sub, '/', Visit, '/eeg/', Sub, '_', Visit, '_task-motor_eeg.eeg', sep='')
                #RawAnat <- c() #P:/3022026.01/pep/bids/sub-POMU00A53C1AA47F6936/ses-Visit1/anat/sub-POMU00A53C1AA47F6936_ses-Visit1_acq-MPRAGE_rec-norm_run-1_T1w.nii.gz
                RawAnat <- paste(dBIDS, Sub, '/', Visit, '/anat/', Sub, '_', Visit, '_acq-MPRAGE_rec-norm_run-', LastRun.anat, '_T1w.nii.gz', sep='')
                #RawFMRI <- c() #P:/3022026.01/pep/bids/sub-POMU00A53C1AA47F6936/ses-Visit1/func/sub-POMU00A53C1AA47F6936_ses-Visit1_task-motor_acq-MB6_run-1_bold.nii.gz
                RawFMRI <- paste(dBIDS, Sub, '/', Visit, '/func/', Sub, '_', Visit, '_task-motor_acq-MB6_run-', LastRun.beh, '_bold.nii.gz', sep='')
                #FmriprepHtml <- c() #P:/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU7E7448F5C57F585A.html
                FmriprepHtml <- paste(dFMRIPREP, Sub, '.html', sep='')
                #PreFMRI <- c() #P:/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU00A6F1FC997C42C6/ses-Visit1/func/sub-POMU00A6F1FC997C42C6_ses-Visit1_task-motor_acq-MB6_run-1_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz
                PreFMRI <- paste(dFMRIPREP, Sub, '/', Visit, '/func/', Sub, '_', Visit, '_task-motor_acq-MB6_run-', LastRun.fmri, '_space-MNI152NLin6Asym_desc-preproc_bold.nii.gz', sep='')
                #PreAnat <- c() #P:/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU0C7CB0F2155DE5AB/anat/sub-POMU0C7CB0F2155DE5AB_desc-preproc_T1w.nii.gz
                PreAnat <- paste(dFMRIPREP, Sub, '/anat/', Sub, '_desc-preproc_T1w.nii.gz', sep='')
                #Confs <- c() # #P:/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU00A6F1FC997C42C6/ses-Visit1/func/sub-POMU00A6F1FC997C42C6_ses-Visit1_task-motor_acq-MB6_run-1_desc-confounds_regressors2.tsv
                Confs <- paste(dFMRIPREP, Sub, '/', Visit, '/func/', Sub, '_', Visit, '_task-motor_acq-MB6_run-', LastRun.fmri, '_desc-confounds_regressors.tsv', sep='')
                #EditedConfs <- c() #P:/3022026.01/pep/bids/derivatives/fmriprep/sub-POMU00A6F1FC997C42C6/ses-Visit1/func/sub-POMU00A6F1FC997C42C6_ses-Visit1_task-motor_acq-MB6_run-1_desc-confounds_regressors2.tsv
                EditedConfs <- paste(dFMRIPREP, Sub, '/', Visit, '/func/', Sub, '_', Visit, '_task-motor_acq-MB6_run-', LastRun.fmri, '_desc-confounds_regressors2.tsv', sep='')
                # Analyses
                #FARM <- c() #P:/3022026.01/analyses/EMG/motor/processing/FARM/sub-POMU00A53C1AA47F6936_ses-Visit1_motor_FARM.dat
                FARM <- paste(dEMG, 'FARM/', Sub, '_', Visit, '_motor_FARM.dat', sep='')
                #Prepemg <- c() #P:/3022026.01/analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED/sub-POMUF0972E8CD008365F-ses-Visit1-motor_acc_y_1Hz_regressors_log.mat
                Prepemg <- list.files(paste(dEMG, 'prepemg/Regressors/ZSCORED/', sep=''), pattern = paste(Sub,'-',Visit, '.*_log.mat$', sep=''), full.names = TRUE)
                #FirstLevel <- c() #P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/sub-POMU0AB6BCFE0591341C/ses-Visit1/1st_level/SPM.mat
                FirstLevel <- paste(dFirstLevel, Sub, '/', Visit, '/1st_level/SPM.mat', sep='')
                
                # Generate row for data file
                SubInfo <- data.frame(Pseudonym=Sub,Visit=Visit)
                Check <- list(Events=Events, ClinVars=ClinVars, RawEye=RawEye, RawEEG=RawEEG, RawAnat=RawAnat, RawFMRI=RawFMRI,
                              FmriprepHtml=FmriprepHtml, PreAnat=PreAnat, PreFMRI=PreFMRI, Confs=Confs, EditedConfs=EditedConfs,
                              FARM=FARM, Prepemg=Prepemg, FirstLevel=FirstLevel)
                DataPresence <- lapply(Check, TestForPresence) %>%
                        as.data.frame
                Row <- bind_cols(SubInfo, DataPresence)
                df <- bind_rows(df, Row)
        }
}
write_csv(df, paste('P:/3022026.01/analyses/motor/QC/DataPresence_', date(now()), '.csv', sep=''))

# Summarise the DataPresence.csv file for a better overview
Sums <- c()
for(t in visits){
        s <- df %>%
                filter(Visit == t) %>%
                select(-c(1,2)) %>%
                apply(2, as.numeric) %>%
                colSums
        Sums <- bind_rows(Sums, s)
}
Sums <- bind_cols(Visit=visits, Sums)
write_csv(Sums, paste('P:/3022026.01/analyses/motor/QC/DataPresenceSums_', date(now()), '.csv', sep=''))




