# This script gathers all data frame manipulations
# These manipulations are intended to be independent of each other
# so it should be possible to carry them out in any order.

manipulate_castor_csv <- function(datafile){

        library(tidyverse)
        library(jsonlite)
        library(lubridate)
        
        ##### Read joined file ####
        # datafile <- dir('P:/3022026.01/pep/ClinVars2/derivatives/', 'merged_[2].*', full.names = TRUE)
        df <- read_csv(datafile)
        #####
        
        ##### Replace numeric values with meaningful labels #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/relabel_categorical_vals.R')
        df <- relabel_categorical_vals(df)
        #####
        
        ##### Repair impossible values #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/turn_negative_to_positive.R')
        varlist <- c('MonthSinceDiag', 'WeeksSinceVisit1', 'WeeksSinceVisit2', 'Age')
        for(var in varlist){
                turn_negative_to_positive(df, var)
        }
        #####
        
        ##### Determine task #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/determine_mri_task.R')
        df <- determine_mri_task(df, 'P:/3022026.01/pep/bids')
        #####
        
        ##### Repair BDI and reverse STAI scores #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/repair_bdiII_values.R')
        df <- repair_bdiII_values(df)
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/reverse_STAI_values.R')
        df <- reverse_STAI_values(df)
        #####
        
        ##### Compute summary scores #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_summaryscores.R')
        df <- compute_summaryscores(df)
        #####
        
        ##### Compute progression (deltas and ROCs; Dependency: Compute summary scores) #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/elble_change.R')
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_progression.R')
        varlist <- c('Up3OfTotal', 'Up3OnTotal', 'Up3OfBradySum', 'Up3OnBradySum', 'Up3OfRigiditySum', 'Up3OnRigiditySum',
                     'Up3OfAppendicularSum', 'Up3OnAppendicularSum', 'Up3OfPIGDSum', 'Up3OnPIGDSum', 'Up3OfAxialSum', 'Up3OfAxialSum',
                     'Up3OfRestTremAmpSum', 'Up3OnRestTremAmpSum', 'Up3OfActionTremorSum', 'Up3OnActionTremorSum',
                     'Up3OfCompositeTremorSum', 'Up3OnCompositeTremorSum', 'STAIStateSum', 'STAITraitSum', 'QUIPicdSum', 'QUIPrsSum', 
                     'AES12Sum', 'ApatSum', 'BDI2Sum', 'PDQ39_SingleIndex', 'TalkProbSum', 'VisualProb23Sum', 'VisualProb17Sum')
        # nritems <- c()
        for(var in varlist){
                df <- compute_progression(df, var, nritems)      
        }
        #####
        
        ##### Detect patients who participated in both PIT and POM
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/detect_xstudy_participation.R')
        df <- detect_xstudy_participation(df)
        #####
        
        ##### Classify PD patients from POM into subtypes (Feresh et al., 2017) #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/classify_subtypes.R')
        df <- classify_subtypes(df)
        #####
        
        ##### Extend variables #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/extend_variables.R')
        varlist <- c('Gender', 'Age', 'MostAffSide', 'MonthSinceDiag', 'WeeksSinceVisit1', 'WeeksSinceVisit2', 'MriNeuroPsychTask', 'MriRespHand')
        df <- extend_variables(df, varlist)
        #####
        
        ##### Calculate time to follow-up (Dependency: Extend variables) #####
        source('M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_weekstofollowup.R')
        df <- compute_weekstofollowup(df)
        #####
        
        ##### Write to file #####
        outputname <- paste(dirname(datafile), '/merged_manipulated_', today(), '.csv', sep = '')
        write_csv(df, outputname)
        #####

}

# ##### Check missing timepoint values #####
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit1') %>%
#   select(pseudonym, MonthSinceDiag)
# length(dat$MonthSinceDiag)
# sum(is.na(dat$MonthSinceDiag))
# 
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit2') %>%
#   select(pseudonym, WeeksSinceVisit1)
# length(dat$WeeksSinceVisit1)
# sum(is.na(dat$WeeksSinceVisit1))
# 
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit3') %>%
#   select(pseudonym, WeeksSinceVisit2)
# length(dat$WeeksSinceVisit2)
# sum(is.na(dat$WeeksSinceVisit2))
# #####
# 
# ##### Check handedness #####
# dat <- df %>%
#   filter(MriNeuroPsychTask == 'Motor') %>%
#   select(pseudonym, Timepoint, MriRespHand, MostAffSide)
# #####