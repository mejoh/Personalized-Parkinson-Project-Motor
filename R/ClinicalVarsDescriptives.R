# Generate data frame

source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsDatabase.R')
df_v1 <- ClinicalVarsDatabase('Castor.Visit1')
df_v2 <- ClinicalVarsDatabase('Castor.Visit2')

# Sort data frame
df2_v1 <- df_v1 %>%
        arrange(pseudonym, timepoint)

df2_v2 <- df_v2 %>%
        arrange(pseudonym, timepoint)

# Merge data frames

df2 <- full_join(df2_v1, df2_v2) %>%
        arrange(pseudonym, timepoint)

##### Calculate disease onset (time of diagnosis) and estimated disease duration #####

# Convert time of assessment to 'date' format, removing hm information
df2 <- df2 %>%
        mutate(Up3OfAssesTime = sub(';.*', '', Up3OfAssesTime)) %>%
        mutate(Up3OfAssesTime = dmy(Up3OfAssesTime))

## Calculate time of diagnosis for visit1 ##
# Visit 1 is the only one with diagnosis date information!
# Year, month, and day are not available for all participants
# Make an estimation for those with missing data
# Missing data comes in three forms: Missing day only, missing both month and day, or missing all (>Visit1)
# We therefore define 4 data frames, one for full data and 3 for the three forms of missing data
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
df2 <- bind_cols(df2, tibble(EstDisDurYears = EstDiagnosisDates$EstDisDurYears, TimeToFUYears = EstDiagnosisDates$TimeToFUYears))

# Filter out participants with negative values for TimeToFUYears
BelowZeroFU <- df2$TimeToFUYears[df2$TimeToFUYears < 0]
msg <- paste(length(BelowZeroFU), ' participants have negative time to follow-up, check so that visit 1 data is available. Otherwise a data entry mistake may have been made. These participants will now be filtered out...', sep = '')
warning(msg)
df2 <- df2 %>%
        filter(TimeToFUYears >= 0)

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

##### Calculate disease progression and indicate which participants have FU data #####

df2 <- df2 %>%
        mutate(BradySum.1YearProg = 0,
               RestTremAmpSum.1YearProg = 0,
               MultipleSessions = 0)

for(n in 1:nrow(df2)){
        if(df2$timepoint[n] == 'V2'){
                df2$BradySum.1YearProg[n] <- df2$BradySum[n] - df2$BradySum[n-1]
                df2$RestTremAmpSum.1YearProg[n] <- df2$BradySum[n] - df2$BradySum[n-1]
                df2$MultipleSessions[(n-1):n] = 1
        }
}
df2$MultipleSessions <- as.factor(df2$MultipleSessions)
levels(df2$MultipleSessions) <- c('No','Yes')
#####

source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
library(ggplot2)
library(cowplot)


##### Plots, Visit1 ####

df2_v1 <- df2 %>%
        filter(timepoint == 'V1')

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




#####

##### Plots, Visit2

## Count of Visit2 sessions vs Visit1 sessions ##
g_visits1 <- ggplot(df2, aes(timepoint, fill = timepoint, colour = timepoint)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Sessions') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_visits1

## Time to follow-up ##
g_timetofu1 <- df2 %>%
        filter(timepoint == 'V2') %>%
        ggplot(aes(x = '', y = TimeToFUYears)) +
        geom_boxplot() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Time to follow-up (years)') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_timetofu1

## 1 year progression ##

# Summary stats
df2_summary <- df2 %>%
        dplyr::group_by(timepoint) %>%
        dplyr::summarise(n = n(), 
                         brady_mean = mean(BradySum, na.rm = TRUE), brady_sd = sd(BradySum, na.rm = TRUE),
                         disdur_mean = mean(EstDisDurYears, na.rm = TRUE), disdur_sd = sd(EstDisDurYears, na.rm = TRUE)) %>%
        dplyr::mutate(brady_se = brady_sd/sqrt(n), brady_ci = 2*brady_se,
                      disdur_se = disdur_sd/sqrt(n), disdur_ci = 2*disdur_se)

g_bradyprog1vio <- ggplot(df2, aes(x = timepoint, y = BradySum, fill = timepoint)) +
        geom_flat_violin(aes(fill = timepoint),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = 'black', size = 1)+
        geom_point(aes(x = as.numeric(timepoint)-.15, y = BradySum, colour = timepoint),position = position_jitter(width = .05), size = 4, shape = 20, alpha = .7)+
        geom_boxplot(aes(x = timepoint, y = BradySum, fill = timepoint),outlier.shape = NA, alpha = .5, width = .1, colour = "black", size = 1)+
        geom_line(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint), linetype = 3, lwd = 2)+
        geom_point(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint), shape = 18, size = 2) +
        geom_errorbar(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint, ymin = brady_mean-brady_se, ymax = brady_mean+brady_se), width = .05, size = 2)+
        scale_colour_brewer(palette = "Set1")+
        scale_fill_brewer(palette = "Set1")+
        ggtitle("Bradykinesia subscore as a function of time") +
        theme_cowplot(font_size = 25)
g_bradyprog1vio

g_bradyprog1 <- ggplot(df2, aes(x = EstDisDurYears, y = BradySum, colour = timepoint)) +
        geom_point(aes(fill = timepoint), size = 3) +
        geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia progression')
g_bradyprog1

g_bradyprog2 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(x = timepoint, y = BradySum, fill = timepoint)) +
        geom_boxplot(lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_bradyprog2

g_bradyprog3 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(BradySum, fill = timepoint)) +
        geom_density(alpha = 1/2, lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        geom_vline(aes(xintercept = mean(df2$BradySum[df2$timepoint == 'V1'], na.rm = TRUE)), lwd = 2, color = 'red') +
        geom_vline(aes(xintercept = mean(df2$BradySum[df2$timepoint == 'V2'], na.rm = TRUE)), lwd = 2, color = 'blue')
g_bradyprog3

## Side question: Is symptom progression dependent on disease duration? ##
g_bradyprog4 <- df2 %>%
        filter(timepoint == 'V2') %>%
        ggplot(aes(x = EstDisDurYears, y = BradySum.1YearProg)) +
        geom_point(size = 3) +
        geom_smooth(method = lm, color = 'red')
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia progression as a function of disease duration')
g_bradyprog4

#####

df2_ttest <- df2 %>%
        filter(timepoint == 'V2')
t.test(df2$BradySum.1YearProg, alternative = 'two.sided')

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