ClinicalVarsPreprocessing <- function(dataframe){
        
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
        mutate(TimeToFUYears = NA)
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
msg <- paste(nrow(BelowZeroDisDur), ' participants have negative time to follow-up, check so that visit 1 data is available.
             Otherwise a data entry mistake may have been made. Setting EstDisDurYears to NA for: ', sep = '')
print(msg)
print(BelowZeroDisDur$pseudonym)
dataframe$EstDisDurYears[dataframe$EstDisDurYears < 0] <- NA
#####

##### Select variables + Calculate bradykinesia/tremor subscore #####

# Variable selection
# Definition of bradykinesia subscore
dataframe <- dataframe %>%
        select(pseudonym, 
               Up3OfRigRue, Up3OfRigRle, Up3OfRigLue, Up3OfRigLle,
               Up3OfFiTaYesDev, Up3OfFiTaNonDev,
               Up3OfHaMoYesDev, Up3OfHaMoNonDev,
               Up3OfProSYesDev, Up3OfProSNonDev,
               Up3OfToTaYesDev, Up3OfToTaNonDev,
               Up3OfLAgiYesDev, Up3OfLAgiNonDev,
               Up3OfRAmpArmYesDev, Up3OfRAmpArmNonDev,
               Up3OfRAmpLegYesDev, Up3OfRAmpLegNonDev,
               Up3OfRAmpJaw,
               EstDisDurYears,
               Up3OfHoeYah,
               MriNeuroPsychTask,
               DiagParkCertain,
               MostAffSide,
               PrefHand,
               Age,
               Gender,
               ParkinMedUser,
               SmokeCurrent,
               timepoint,
               TimeToFUYears) %>%
        mutate(across(2:20, as.numeric)) %>%
        mutate(BradySum = rowSums(.[2:15])) %>%
        mutate(RestTremAmpSum = rowSums(.[16:20]))

# Transformations
dataframe$Up3OfHoeYah <- as.factor(dataframe$Up3OfHoeYah)                     # Hoen & Yahr stage
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
dataframe$timepoint <- as.factor(dataframe$timepoint)                         # Timepoint

#####

##### Subsetting by task #####
#dataframe <- dataframe %>%
#        filter(MriNeuroPsychTask == 'Motor')
# Subset by noticable tremor
#dataframe <- dataframe %>%
#        filter(RestTremAmpSum >= 1)
#####

##### Calculate disease progression and indicate which participants have FU data #####

dataframe <- dataframe %>%
        mutate(BradySum.1YearProg = NA,
               RestTremAmpSum.1YearProg = NA,
               MultipleSessions = 0)

for(n in 1:nrow(dataframe)){
        if(dataframe$timepoint[n] == 'V2'){
                dataframe$BradySum.1YearProg[n] <- dataframe$BradySum[n] - dataframe$BradySum[n-1]
                dataframe$RestTremAmpSum.1YearProg[n] <- dataframe$BradySum[n] - dataframe$BradySum[n-1]
                dataframe$MultipleSessions[(n-1):n] = 1
        }
}
dataframe$MultipleSessions <- as.factor(dataframe$MultipleSessions)
levels(dataframe$MultipleSessions) <- c('No','Yes')
#####

dataframe

}