# Generate data frame

source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsDatabase.R')
df_v1 <- ClinicalVarsDatabase('Castor.Visit1')
df_v2 <- ClinicalVarsDatabase('Castor.Visit2')

# Sort data frame
df2_v1 <- df_v1 %>%
        arrange(pseudonym)

df2_v2 <- df_v2 %>%
        arrange(pseudonym)

# Merge data frames

df2 <- full_join(df2_v1, df2_v2) %>%
        arrange(pseudonym, timepoint)

##### Calculate disease onset (time of diagnosis) and estimated disease duration #####

# Convert time of assessment to 'date' format, removing hm information
df2 <- df2 %>%
        mutate(Up3OfAssesTime = sub(';.*', '', Up3OfAssesTime)) %>%
        mutate(Up3OfAssesTime = dmy(Up3OfAssesTime))

# Calculate time of diagnosis for visit1
# Year, month, and day are not available for all participants
# Make an estimation for those with missing data
# Missing data comes in two forms: Missing day only, or missing both month and day
# We therefore define 3 data frames, one for full data and 2 for the two forms of missing data
YearOnly <- df2 %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(is.na(DiagParkMonth))
YearOnly$DiagParkYear <- as.numeric(YearOnly$DiagParkYear)
YearOnly$DiagParkMonth <- c(6)
YearOnly$DiagParkDay <- c(15)  # < Time of diagnosis set to middle of the year

YearMonthOnly <- df2 %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(!is.na(DiagParkMonth)) %>%
        filter(is.na(DiagParkDay))
YearMonthOnly$DiagParkYear <- as.numeric(YearMonthOnly$DiagParkYear)
YearMonthOnly$DiagParkMonth <- as.numeric(YearMonthOnly$DiagParkMonth)
YearMonthOnly$DiagParkDay <- c(15)     # < Time of diagnosis set to middle of the month

YearMonthDay <- df2 %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(!is.na(DiagParkYear)) %>%
        filter(!is.na(DiagParkMonth)) %>%
        filter(!is.na(DiagParkDay))
YearMonthDay$DiagParkYear <- as.numeric(YearMonthDay$DiagParkYear)
YearMonthDay$DiagParkMonth <- as.numeric(YearMonthDay$DiagParkMonth)
YearMonthDay$DiagParkDay <- as.numeric(YearMonthDay$DiagParkDay)

YearMissing <- df2 %>%
        select(pseudonym, timepoint, DiagParkYear, DiagParkMonth, DiagParkDay, Up3OfAssesTime) %>%
        filter(is.na(DiagParkYear))
YearMissing$DiagParkYear <- as.numeric(YearMissing$DiagParkYear)
YearMissing$DiagParkMonth <- as.numeric(YearMissing$DiagParkMonth)
YearMissing$DiagParkDay <- as.numeric(YearMissing$DiagParkDay)

# Bind together the three tibbles defined above
# Sort by pseudonym and timepoint, just like original data frame (very important!)
EstDiagnosisDates <- bind_rows(YearOnly, YearMonthOnly, YearMonthDay, YearMissing) %>%
        arrange(pseudonym, timepoint)

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

# Calculate time to follow-up
EstDiagnosisDates <- EstDiagnosisDates %>%
        mutate(TimeToFUYears = 0)
for(n in 1:nrow(EstDiagnosisDates)){
        if(EstDiagnosisDates$timepoint[n] == 'V2'){
                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-1]) / 365
        }
}
BelowZeroFU <- EstDiagnosisDates$TimeToFUYears[EstDiagnosisDates$TimeToFUYears < 0]
msg <- paste(length(BelowZeroFU), ' participants have negative time to follow-up, check so that visit 1 data is available. Otherwise a data entry mistake may have been made.', sep = '')
warning(msg)

# Add disease duration to main data frame
df2 <- bind_cols(df2, tibble(EstDisDurYears = EstDiagnosisDates$EstDisDurYears))

#####

##### Select variables + Calculate bradykinesia/tremor subscore #####

# Variable selection
# Definition of bradykinesia subscore
df2 <- df2 %>%
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
df2$Up3OfHoeYah <- as.factor(df2$Up3OfHoeYah)                     # Hoen & Yahr stage
df2$MriNeuroPsychTask <- as.factor(df2$MriNeuroPsychTask)         # Which task was done?
levels(df2$MriNeuroPsychTask) <- c('Motor', 'Reward')
df2$DiagParkCertain <- as.factor(df2$DiagParkCertain)             # Certainty of diagnosis
levels(df2$DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
df2$MostAffSide <- as.factor(df2$MostAffSide)                     # Most affected side
levels(df2$MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
df2$PrefHand <- as.factor(df2$PrefHand)                           # Dominant hand
levels(df2$PrefHand) <- c('Right', 'Left', 'NoPref')
df2$Gender <- as.factor(df2$Gender)                               # Gender
levels(df2$Gender) <- c('Male', 'Female')
df2$Age <- as.numeric(df2$Age)                                    # Age
df2$ParkinMedUser <- as.factor(df2$ParkinMedUser)                 # Parkinson's medication use
levels(df2$ParkinMedUser) <- c('No','Yes')
df2$SmokeCurrent <- as.factor(df2$SmokeCurrent)                   # Smoking
levels(df2$SmokeCurrent) <- c('Yes','No')
df2$timepoint <- as.factor(df2$timepoint)                         # Timepoint

# Subsetting by task
#df2 <- df2 %>%
#        filter(MriNeuroPsychTask == 'Motor')
# Subset by noticable tremor
#df2 <- df2 %>%
#        filter(RestTremAmpSum >= 1)
#####

##### Plots, Visit1 ####

df2_v1 <- df2 %>%
        filter(timepoint == 'V1')

library(ggplot2)

## BRADYKINESIA ##
# Scatterplot (Bradykinesia/Tremor subscore ~ Disease duration)
bradykinesia_description <- paste("Bradykinesia subscore: \n",
                                  "Limb bradykinesia = Sum item 4-8 (0-40) \n",
                                  "Limb ridigity = Sum item 3 excl. neck (0-16)")

g_brady1 <- ggplot(df2_v1, aes(BradySum)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady1

g_brady2 <- ggplot(df2_v1,aes(x = '',y = BradySum)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady2

g_brady3 <- ggplot(df2_v1, aes(x = EstDisDurYears, y = BradySum, colour = Up3OfHoeYah)) + 
        geom_point(alpha = .6, size = 4) + 
        geom_smooth(method = 'lm', col = 'red') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        theme_cowplot(font_size = 25) +
        labs(x = 'Disease duration (years)',
             y = 'Bradykinesia subscore',
             title = 'Progression of bradykinesia')
g_brady3

g_brady4 <- ggplot() +
        annotate("text", x = 4, y = 25, size=8, label = bradykinesia_description) + 
        theme_bw() +
        theme(panel.grid.major=element_blank(),
              panel.grid.minor=element_blank())
g_brady4

bradykinesia_plots <- plot_grid(g_brady1, g_brady2, g_brady3, g_brady4, labels = 'AUTO', nrow = 2, ncol = 2)
bradykinesia_plots

## TREMOR ##
tremor_description <- paste("Resting tremor amplitude: \n",
                            "Limb resting tremor = Sum item 17 (0-16)")

g_trem1 <- ggplot(df2_v1, aes(RestTremAmpSum)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Resting tremor amplitude') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_trem1

g_trem2 <- ggplot(df2_v1,aes(x = '',y = RestTremAmpSum)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Resting tremor amplitude') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_trem2

g_trem3 <- ggplot(df2_v1, aes(x = EstDisDurYears, y = RestTremAmpSum, colour = Up3OfHoeYah)) + 
        geom_point(alpha = .6, size = 4) + 
        geom_smooth(method = 'lm', col = 'red') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        theme_cowplot(font_size = 25) +
        labs(x = 'Disease duration (years)',
             y = 'Resting tremor amplitude subscore',
             title = 'Progression of tremor')
g_trem3

g_trem4 <- ggplot() +
        annotate("text", x = 4, y = 25, size=8, label = tremor_description) + 
        theme_bw() +
        theme(panel.grid.major=element_blank(),
              panel.grid.minor=element_blank())
g_trem4

tremor_plots <- plot_grid(g_trem1, g_trem2, g_trem3, g_trem4, labels = 'AUTO', nrow = 2, ncol = 2)
tremor_plots

## ESTIMATED DISEASE DURATION ##

g_disdur1 <- ggplot(df2_v1, aes(EstDisDurYears)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Disease duration (years)') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_disdur1

g_disdur2 <- ggplot(df2_v1,aes(x = '',y = EstDisDurYears)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Estimated disease duration (years)') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_disdur2

disdur_plots <- plot_grid(g_disdur1, g_disdur2, labels = 'AUTO', nrow = 1, ncol = 2)
disdur_plots

## AGE ##
g_age1 <- ggplot(df2_v1, aes(Age)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Age') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_age1

g_age2 <- ggplot(df2_v1,aes(x = '',y = Age)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Age') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_age2

age_plots <- plot_grid(g_age1, g_age2, labels = 'AUTO', nrow = 1, ncol = 2)
age_plots

## GENDER ##
g_gender1 <- ggplot(df2_v1, aes(Gender, fill = Gender, colour = Gender)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Gender') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_gender1

## HOEHN & YAHR ##
g_H&Y1 <- ggplot(df2_v1, aes(Up3OfHoeYah, fill = Up3OfHoeYah, colour = Up3OfHoeYah)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Hoehn & Yahr stage') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_H&Y1

## CERTAINTY OF DIAGNOSIS ##
g_certaintyofdiag1 <- ggplot(df2_v1, aes(DiagParkCertain, fill = DiagParkCertain)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Certainty of diagnosis') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_certaintyofdiag1

## PD MEDICATION USAGE ##
g_meduse1 <- ggplot(df2_v1, aes(ParkinMedUser, fill = ParkinMedUser)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'PD medication users') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_meduse1

## TASK ##
g_task1 <- ggplot(df2_v1, aes(MriNeuroPsychTask, fill = MriNeuroPsychTask)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Task') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_task1

## MOST AFFECTED SIDE AND HANDEDNESS##
g_mas1 <- ggplot(df2_v1, aes(MostAffSide, fill = MostAffSide)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Most affected side') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_mas1

g_prefhand1 <- ggplot(df2_v1, aes(PrefHand, fill = PrefHand)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Dominant hand') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_prefhand1

side <- df2_v1 %>%
        select(PrefHand, MostAffSide) %>%
        table()
side

# Summary stats
#df2_summary <- df2 %>%
#        dplyr::summarise(n = n(), 
#                         brady_mean = mean(BradySum), brady_sd = sd(BradySum),
#                         disdur_mean = mean(EstDisDurYears), disdur_sd = sd(EstDisDurYears)) %>%
#        dplyr::mutate(brady_se = brady_sd/sqrt(n), brady_ci = 2*brady_se,
#                      disdur_se = disdur_sd/sqrt(n), disdur_ci = 2*disdur_se)


#####

##### Plots, Visit2

#####

##### Clustering #####

## KMEANS ##
# Kmeans with intention to separate tremor dominant from non-dominant
# Method does not work
# Gives a straight split into low and high bradykinesia
# Tremor is not being weighed high enough. Probably due to low amount of
# participants with noticable tremor.
df2_kmeans <- df2 %>%
        select(BradySum, RestTremAmpSum)
kmeansObj <- kmeans(df2_kmeans, centers = 2)
plot(df2_kmeans$BradySum, df2_kmeans$RestTremAmpSum, col = kmeansObj$cluster, pch = 19, cex = 2)
points(kmeansObj$centers, col = 1:2, pch = 3, cex = 3, lwd = 3)

#####