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
for(n in 1:nrow(EstDiagnosisDates)){
        if(EstDiagnosisDates$timepoint[n] == 'V2'){
                EstDiagnosisDates$EstDisDurYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$EstDiagDate[n-1]) / 365
        }
}

## Calculate time to follow-up ##
EstDiagnosisDates <- EstDiagnosisDates %>%
        mutate(TimeToFUYears = 0)
for(n in 1:nrow(EstDiagnosisDates)){
        if(EstDiagnosisDates$timepoint[n] == 'V2'){
                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-1]) / 365
        }
}

# Add disease duration to main data frame
dataframe <- bind_cols(dataframe, tibble(EstDisDurYears = EstDiagnosisDates$EstDisDurYears, TimeToFUYears = EstDiagnosisDates$TimeToFUYears))

#####

##### Check for negative values for TimeToFUYears #####
BelowZeroFU <- dataframe %>%
        filter(TimeToFUYears < 0)
msg <- paste(nrow(BelowZeroFU), ' participants have negative time to follow-up, check so that visit 1 data is available.
             Otherwise a data entry mistake may have been made. Setting TimeToFUYears to NA for: ', sep = '')
print(msg)
print(BelowZeroFU$pseudonym)
dataframe$TimeToFUYears[dataframe$TimeToFUYears < 0] <- NA
#####

##### Check for negative values for EstDisDurYears #####
BelowZeroDisDur <- dataframe %>%
        filter(EstDisDurYears < 0)
msg <- paste(nrow(BelowZeroDisDur), ' participants have negative disease durations, check so that visit 1 data is available.
             Otherwise a data entry mistake may have been made. Setting EstDisDurYears to NA for: ', sep = '')
print(msg)
print(BelowZeroDisDur$pseudonym)
dataframe$EstDisDurYears[dataframe$EstDisDurYears < 0] <- NA
#####

##### Select variables + Calculate total score and bradykinesia/tremor subscore #####

# Variable selection
# Definition of bradykinesia subscore
dataframe <- dataframe %>%
        select(pseudonym, 
               Up3OfSpeech,
               Up3OfFacial,
               Up3OfRigNec, Up3OfRigRue, Up3OfRigLue, Up3OfRigRle, Up3OfRigLle,
               Up3OfFiTaYesDev, Up3OfFiTaNonDev,
               Up3OfHaMoYesDev, Up3OfHaMoNonDev,
               Up3OfProSYesDev, Up3OfProSNonDev,
               Up3OfToTaYesDev, Up3OfToTaNonDev,
               Up3OfLAgiYesDev, Up3OfLAgiNonDev,
               Up3OfArise,
               Up3OfGait,
               Up3OfFreez,
               Up3OfStaPos,
               Up3OfPostur,
               Up3OfSpont,
               Up3OfPosTYesDev, Up3OfPosTNonDev,
               Up3OfKinTreYesDev, Up3OfKinTreNonDev,
               Up3OfRAmpArmYesDev, Up3OfRAmpArmNonDev, Up3OfRAmpLegYesDev, Up3OfRAmpLegNonDev, Up3OfRAmpJaw,
               Up3OfConstan,
               Up3OfPresDysKin,
               Up3OfDysKinInt,
               Up3OfHoeYah,
               Up3OfSumOfTotalWithinRange,
               Up3OnSpeech,
               Up3OnFacial,
               Up3OnRigNec, Up3OnRigRue, Up3OnRigLue, Up3OnRigRle, Up3OnRigLle,
               Up3OnFiTaYesDev, Up3OnFiTaNonDev,
               Up3OnHaMoYesDev, Up3OnHaMoNonDev,
               Up3OnProSYesDev, Up3OnProSNonDev,
               Up3OnToTaYesDev, Up3OnToTaNonDev,
               Up3OnLAgiYesDev, Up3OnLAgiNonDev,
               Up3OnArise,
               Up3OnGait,
               Up3OnFreez,
               Up3OnStaPos,
               Up3OnPostur,
               Up3OnSpont,
               Up3OnPosTYesDev, Up3OnPosTNonDev,
               Up3OnKinTreYesDev, Up3OnKinTreNonDev,
               Up3OnRAmpArmYesDev, Up3OnRAmpArmNonDev, Up3OnRAmpLegYesDev, Up3OnRAmpLegNonDev, Up3OnRAmpJaw,
               Up3OnConstan,
               Up3OnPresDysKin,
               Up3OnDysKinInt,
               Up3OnHoeYah,
               Up3OnSumOfTotalWithinRange,
               EstDisDurYears,
               MriNeuroPsychTask,
               DiagParkCertain,
               MostAffSide,
               PrefHand,
               Age,
               Gender,
               ParkinMedUser,
               SmokeCurrent,
               timepoint,
               TimeToFUYears,
               starts_with('Up1a'),
               starts_with('Nps'),
               starts_with('RemSbdq')) %>%
        mutate(across(2:75, as.numeric)) %>%
        mutate(Up3OfBradySum = rowSums(.[5:16])) %>%
        mutate(Up3OfRestTremAmpSum = rowSums(.[29:33])) %>%
        mutate(Up3OfTotal = rowSums(.[2:34])) %>%
        mutate(Up3OnTotal = rowSums(.[39:71])) %>%
        mutate(Up3OnBradySum = rowSums(.[42:53])) %>%
        mutate(Up3OnRestTremAmpSum = rowSums(.[66:70]))

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
dataframe$SmokeCurrent <- as.factor(dataframe$SmokeCurrent)                   # Smoking
levels(dataframe$SmokeCurrent) <- c('Yes','No')
dataframe$NpsEducYears <- as.numeric(dataframe$NpsEducYears)                  # Education years
dataframe$timepoint <- as.factor(dataframe$timepoint)                         # Timepoint

#####

##### Calculate disease progression and indicate which participants have FU data #####

dataframe <- dataframe %>%
        mutate(Up3OfSumOfTotalWithinRange.1YearProg = NA,
               Up3OnSumOfTotalWithinRange.1YearProg = NA,
               Up3OfBradySum.1YearProg = NA,
               Up3OnBradySum.1YearProg = NA,
               Up3OfRestTremAmpSum.1YearProg = NA,
               Up3OnRestTremAmpSum.1YearProg = NA,
               Up3OfTotal.1YearProg = NA,
               Up3OnTotal.1YearProg = NA,
               MultipleSessions = 0)

for(n in 1:nrow(dataframe)){
        if(dataframe$timepoint[n] == 'V2'){
                dataframe$Up3OfSumOfTotalWithinRange.1YearProg[n] <- dataframe$Up3OfSumOfTotalWithinRange[n] - dataframe$Up3OfSumOfTotalWithinRange[n-1]
                dataframe$Up3OnSumOfTotalWithinRange.1YearProg[n] <- dataframe$Up3OnSumOfTotalWithinRange[n] - dataframe$Up3OnSumOfTotalWithinRange[n-1]
                dataframe$Up3OfBradySum.1YearProg[n] <- dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]
                dataframe$Up3OnBradySum.1YearProg[n] <- dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]
                dataframe$Up3OfRestTremAmpSum.1YearProg[n] <- dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]
                dataframe$Up3OnRestTremAmpSum.1YearProg[n] <- dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]
                dataframe$Up3OfTotal.1YearProg[n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]
                dataframe$Up3OnTotal.1YearProg[n] <- dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]
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

##### Report on missing values of data frame #####
x <- apply(dataframe, 2, is.na) %>% colSums
msg <- c('Reporting missing values per variable...')
print(msg)
print(x)
#####

# Output final dataframe
dataframe

}