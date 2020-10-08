ClinicalVarsPreprocessing <- function(dataframe){

library(tidyverse)        
library(lubridate)
        
##### Calculate disease onset (time of diagnosis) and estimated disease duration #####

# Convert time of assessment to 'date' format, removing hm information
dataframe <- dataframe %>%
        mutate(Up3OfAssesTime = sub(';.*', '', Up3OfAssesTime)) %>%
        mutate(Up3OfAssesTime = dmy(Up3OfAssesTime))

## Calculate time of diagnosis for visit1 ##
# Visit 1 is the only one with diagnosis date information!
# Year, month, and day are not available for all participants
# Make an estimation for those with missing data
# Missing data comes in three forms: Missing day only, missing both month and day, or missing all (>Visit1)
# We therefore define 4 data frames, one for full data and 3 for the three forms of missing data
YearOnly <- dataframe %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(is.na(DiagParkMonth))
YearOnly$DiagParkYear <- as.numeric(YearOnly$DiagParkYear)
YearOnly$DiagParkMonth <- c(6)
YearOnly$DiagParkDay <- c(15)  # < Time of diagnosis set to middle of the year

YearMonthOnly <- dataframe %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(!is.na(DiagParkMonth)) %>%
        filter(is.na(DiagParkDay))
YearMonthOnly$DiagParkYear <- as.numeric(YearMonthOnly$DiagParkYear)
YearMonthOnly$DiagParkMonth <- as.numeric(YearMonthOnly$DiagParkMonth)
YearMonthOnly$DiagParkDay <- c(15)     # < Time of diagnosis set to middle of the month

YearMonthDay <- dataframe %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(!is.na(DiagParkMonth)) %>%
        filter(!is.na(DiagParkDay))
YearMonthDay$DiagParkYear <- as.numeric(YearMonthDay$DiagParkYear)
YearMonthDay$DiagParkMonth <- as.numeric(YearMonthDay$DiagParkMonth)
YearMonthDay$DiagParkDay <- as.numeric(YearMonthDay$DiagParkDay)

YearMissing <- dataframe %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(is.na(DiagParkYear))
YearMissing$DiagParkYear <- as.numeric(YearMissing$DiagParkYear)
YearMissing$DiagParkMonth <- as.numeric(YearMissing$DiagParkMonth)
YearMissing$DiagParkDay <- as.numeric(YearMissing$DiagParkDay)

# Bind together the tibbles defined above
# Sort by pseudonym and timepoint, just like original data frame (very important!)
EstDiagnosisDates <- bind_rows(YearOnly, YearMonthOnly, YearMonthDay, YearMissing) %>%
        arrange(pseudonym, timepoint)

## Calculate disease durations ##
# Calculate an exact or estimated disease duration in years for visit 1
EstDiagnosisDates <- EstDiagnosisDates %>% 
        mutate(EstDiagDate = ymd(paste(DiagParkYear,DiagParkMonth,DiagParkDay))) %>%
        mutate(EstDisDurYears = as.numeric(Up3OfAssesTime - EstDiagDate) / 365)

# Calculate an exact or estimated disease duration in years for visit 2
#for(n in 1:nrow(EstDiagnosisDates)){
#        if(EstDiagnosisDates$timepoint[n] == 'V2'){
#                EstDiagnosisDates$EstDisDurYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$EstDiagDate[n-1]) / 365
#        }
#}

## Calculate time to follow-up and set baseline disease duration ##
EstDiagnosisDates <- EstDiagnosisDates %>%
        mutate(TimeToFUYears = 0)
for(n in 1:nrow(EstDiagnosisDates)){
        if(EstDiagnosisDates$timepoint[n] == 'V2' && EstDiagnosisDates$timepoint[n-1] == 'V1' && EstDiagnosisDates$pseudonym[n] == EstDiagnosisDates$pseudonym[n-1]){
                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-1]) / 365
                EstDiagnosisDates$EstDisDurYears[n] <- EstDiagnosisDates$EstDisDurYears[n-1]
        }
}

# Add disease duration to main data frame
dataframe <- bind_cols(dataframe, tibble(EstDisDurYears = EstDiagnosisDates$EstDisDurYears, TimeToFUYears = EstDiagnosisDates$TimeToFUYears))

#####

##### CHECK: negative values for TimeToFUYears #####
BelowZeroFU <- dataframe %>%
        filter(TimeToFUYears < 0)
cat(nrow(BelowZeroFU), ' participants have negative time to follow-up, check so that visit 1 data is available.', '\n',
             'Data entry mistake may have been made. Setting TimeToFUYears to NA for: ', '\n', sep = '')
print(BelowZeroFU$pseudonym)
dataframe$TimeToFUYears[dataframe$TimeToFUYears < 0] <- NA
#####

##### CHECK: negative values for EstDisDurYears #####
BelowZeroDisDur <- dataframe %>%
        filter(EstDisDurYears < 0)
cat(nrow(BelowZeroDisDur), ' participants have negative disease durations, check so that visit 1 data is available.', '\n',
             'Data entry mistake may have been made. Setting EstDisDurYears to NA for: ', '\n', sep = '')
print(BelowZeroDisDur$pseudonym)
dataframe$EstDisDurYears[dataframe$EstDisDurYears < 0] <- NA
#####

##### Select and construct variables #####

# Lists of subscores
list.TotalOff <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                   'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                   'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                   'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont', 'Up3OfPosTYesDev',
                   'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev',
                   'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan')
list.TotalOn <- str_replace(list.TotalOff, 'Of','On')
list.BradykinesiaOff <- c('Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                          'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                          'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfSpont')
list.BradykinesiaOn <- str_replace(list.BradykinesiaOff, 'Of', 'On')
list.RestTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfConstan')
list.RestTremorOn <- str_replace(list.RestTremorOff, 'Of', 'On')
list.RigidityOff <- c('Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle')
list.RigidityOn <- str_replace(list.RigidityOff, 'Of','On')

# Variable selection
# Definition of bradykinesia subscore
dataframe <- dataframe %>%
        select(pseudonym,
               Age,
               Gender, 
               EstDisDurYears,
               timepoint,
               TimeToFUYears,
               MriNeuroPsychTask,
               DiagParkCertain,
               MostAffSide,
               PrefHand,
               ParkinMedUser,
               starts_with('Up3Of'),
               starts_with('Up3On'),
               starts_with('Up1a'),
               starts_with('Updrs2'),
               starts_with('Nps'),
               starts_with('ScopaAut'),
               starts_with('Ess'),
               starts_with('ScopaSlp'),
               starts_with('RemSbdq')) %>%
        mutate(across(-c('pseudonym', 'Updrs2Cag', 'ScopaAut31b', 'ScopaAut32b', 'NpsMocBonus', 'timepoint', 'ScopaAutCag',
                         'ScopaAut29b', 'EssCag', 'ScopaSlpCag', 'RemSbdqCag'), as.numeric)) %>% 
        mutate(Up3OfTotal = rowSums(.[list.TotalOff]),
               Up3OnTotal = rowSums(.[list.TotalOn])) %>%
        mutate(Up3OfBradySum = rowSums(.[list.BradykinesiaOff]),
               Up3OnBradySum = rowSums(.[list.BradykinesiaOn])) %>%
        mutate(Up3OfRestTremAmpSum = rowSums(.[list.RestTremorOff]),
               Up3OnRestTremAmpSum = rowSums(.[list.RestTremorOn])) %>%
        mutate(Up3OfRigiditySum = rowSums(.[list.RigidityOff]),
               Up3OnRigiditySum = rowSums(.[list.RigidityOn])) %>%
        mutate(Up3TotalOnOffDelta = Up3OfTotal - Up3OnTotal,
               Up3BradySumOnOffDelta = Up3OfBradySum - Up3OnBradySum,
               Up3RestTremAmpSumOnOffDelta = Up3OfRestTremAmpSum - Up3OnRestTremAmpSum) %>%
        mutate(TremorDominant.cutoff1 = Up3OfRestTremAmpSum >= 1,
               TremorDominant.cutoff2 = Up3OfRestTremAmpSum >= 2)

#####

##### Class transformations #####

dataframe$Up3OfHoeYah <- as.factor(dataframe$Up3OfHoeYah)                     # Hoen & Yahr stage
dataframe$Up3OnHoeYah <- as.factor(dataframe$Up3OnHoeYah)
dataframe$MriNeuroPsychTask <- as.factor(dataframe$MriNeuroPsychTask)         # Which task was done?
levels(dataframe$MriNeuroPsychTask) <- c('Motor', 'Reward')
dataframe$DiagParkCertain <- as.factor(dataframe$DiagParkCertain)             # Certainty of diagnosis
levels(dataframe$DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
dataframe$MostAffSide <- as.factor(dataframe$MostAffSide)                     # Most affected side
levels(dataframe$MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
dataframe$PrefHand <- as.factor(dataframe$PrefHand)                           # Dominant hand
levels(dataframe$PrefHand) <- c('Right', 'Left', 'NoPref')
dataframe$Gender <- as.factor(dataframe$Gender)                               # Gender
levels(dataframe$Gender) <- c('Male', 'Female')
dataframe$Age <- as.numeric(dataframe$Age)                                    # Age
dataframe$ParkinMedUser <- as.factor(dataframe$ParkinMedUser)                 # Parkinson's medication use
levels(dataframe$ParkinMedUser) <- c('No','Yes')
dataframe$NpsEducYears <- as.numeric(dataframe$NpsEducYears)                  # Education years
dataframe$timepoint <- as.factor(dataframe$timepoint)                         # Timepoint
dataframe$TremorDominant.cutoff1 <- as.factor(dataframe$TremorDominant.cutoff1)   # Tremor dominance
dataframe$TremorDominant.cutoff2 <- as.factor(dataframe$TremorDominant.cutoff2)

#####

##### Calculate disease progression and indicate which participants have FU data #####

dataframe <- dataframe %>%
        mutate(Up3OfTotal.1YearDelta = NA,
               Up3OnTotal.1YearDelta = NA,
               Up3OfTotal.1YearROC = NA,
               Up3OnTotal.1YearROC = NA,
               
               Up3OfBradySum.1YearDelta = NA,
               Up3OnBradySum.1YearDelta = NA,
               Up3OfBradySum.1YearROC = NA,
               Up3OnBradySum.1YearROC = NA,
               
               Up3OfRestTremAmpSum.1YearDelta = NA,
               Up3OnRestTremAmpSum.1YearDelta = NA,
               Up3OfRestTremAmpSum.1YearROC = NA,
               Up3OnRestTremAmpSum.1YearROC = NA,
               
               Up3OfRigiditySum.1YearDelta = NA,
               Up3OnRigiditySum.1YearDelta = NA,
               Up3OfRigiditySum.1YearROC = NA,
               Up3OnRigiditySum.1YearROC = NA,

               MultipleSessions = 0)

alpha <- 0.5
elble.change <- function(T1, T2, subscore.length, alpha=0.5, percent=TRUE){
        if(!is.na(T1) & !is.na(T2)){
                
                T1 <- T1/subscore.length
                T2 <- T2/subscore.length
                diff <- T2-T1
        
                FC <- 10 ^ (alpha * diff) - 1
                PC <- 100 * FC
        
                if(percent==TRUE){
                        return(PC)
                }else if(percent==FALSE){
                        return(FC)
                }
        }else{
                return(NA)
        }
}
for(n in 1:nrow(dataframe)){
        if(dataframe$timepoint[n] == 'V2' && dataframe$timepoint[n-1] == 'V1'){

                dataframe$Up3OfTotal.1YearDelta[(n-1):n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]
                dataframe$Up3OnTotal.1YearDelta[(n-1):n] <- dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]
                #dataframe$Up3OfTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]) / dataframe$Up3OfTotal[n-1]) * 100
                #dataframe$Up3OnTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]) / dataframe$Up3OnTotal[n-1]) * 100
                dataframe$Up3OfTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfTotal[n-1], dataframe$Up3OfTotal[n], length(list.TotalOff))
                dataframe$Up3OnTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnTotal[n-1], dataframe$Up3OnTotal[n], length(list.TotalOn))

                dataframe$Up3OfBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]
                dataframe$Up3OnBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]
                #dataframe$Up3OfBradySum.1YearROC[(n-1):n] <- ((dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]) / dataframe$Up3OfBradySum[n-1]) * 100
                #dataframe$Up3OnBradySum.1YearROC[(n-1):n] <- ((dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]) / dataframe$Up3OnBradySum[n-1]) * 100
                dataframe$Up3OfBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfBradySum[n-1], dataframe$Up3OfBradySum[n], length(list.BradykinesiaOff))
                dataframe$Up3OnBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnBradySum[n-1], dataframe$Up3OnBradySum[n], length(list.BradykinesiaOn))
                
                dataframe$Up3OfRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]
                dataframe$Up3OnRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]
                #dataframe$Up3OfRestTremAmpSum.1YearROC[(n-1):n] <- ((dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]) / dataframe$Up3OfRestTremAmpSum[n-1]) * 100
                #dataframe$Up3OnRestTremAmpSum.1YearROC[(n-1):n] <- ((dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]) / dataframe$Up3OnRestTremAmpSum[n-1]) * 100
                dataframe$Up3OfRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRestTremAmpSum[n-1], dataframe$Up3OfRestTremAmpSum[n], length(list.RestTremorOff))
                dataframe$Up3OnRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRestTremAmpSum[n-1], dataframe$Up3OnRestTremAmpSum[n], length(list.RestTremorOn))
                
                dataframe$Up3OfRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-1]
                dataframe$Up3OnRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-1]
                #dataframe$Up3OfRigiditySum.1YearROC[(n-1):n] <- ((dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-1]) / dataframe$Up3OfRigiditySum[n-1]) * 100
                #dataframe$Up3OnRigiditySum.1YearROC[(n-1):n] <- ((dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-1]) / dataframe$Up3OnRigiditySum[n-1]) * 100
                dataframe$Up3OfRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRigiditySum[n-1], dataframe$Up3OfRigiditySum[n], length(list.RigidityOff))
                dataframe$Up3OnRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRigiditySum[n-1], dataframe$Up3OnRigiditySum[n], length(list.RigidityOn))
                
                dataframe$MultipleSessions[(n-1):n] = 1
        }
}
dataframe$MultipleSessions <- as.factor(dataframe$MultipleSessions)
levels(dataframe$MultipleSessions) <- c('No','Yes')

#####

##### Variables like gender and age are only reported for visit1. Below is a function that 'expands' visit1 values to other timepoints #####

# List of variables you want to 'extend'
varlist <- c('Gender', 'Age', 'MriNeuroPsychTask')
# Extract one variable for one subject and replace NAs with real values
# This is useful for variables that were only assessed at visit1, but is needed at other levels of 'timepoint'
ExtendVars <- function(dataframe, varlist){
        
        # Iterate over variables in the input list
        for(var in varlist){    
                
                # Iterate over pseudonyms
                for(id in unique(dataframe$pseudonym)){
                        
                        # Subset data based on current pseudonym and current variable
                        vals <- dataframe %>%
                                filter(pseudonym == id) %>%
                                select(matches(var))
                        
                        # Perform the same subsetting as above and look for NAs
                        na.idx <- dataframe %>%
                                filter(pseudonym == id) %>%
                                select(matches(var)) %>%
                                is.na %>%
                                as.vector
                        
                        # Skip ids with no real values
                        if(length(na.idx) == sum(na.idx)) next
                        
                        # Define index for non-NA values
                        val.idx <- !na.idx
                        
                        # Find the value that is not NA
                        non.na.val <- vals[val.idx,]
                        
                        # Replace NAs with real values
                        vals[na.idx,] <- non.na.val
                        
                        #Find column and row index in data frame where values should be replaced
                        col.idx <- colnames(dataframe) == var
                        row.idx <- dataframe$pseudonym == id
                        
                        # Perform replacement
                        dataframe[row.idx, col.idx] <- vals
                        
                }
        }
        
        return(dataframe)
        
}
dataframe <- ExtendVars(dataframe,varlist)

#####

##### CHECK: missing values of data frame #####
x <- apply(dataframe, 2, is.na) %>% colSums
msg <- c('Reporting missing values per variable...')
print(msg)
print(x)
#####

# Output final dataframe
dataframe

}