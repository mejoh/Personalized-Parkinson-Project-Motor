# Generate data frame

ClinicalVarsDatabase()

# Sort data frame
df2 <- df %>%
        arrange(Visit1.pseudonym)

##### Calculate disease onset (time of diagnosis) #####

# Calculate time of diagnosis
# Year, month, and day are not available for all participants
# Make an estimation for those with missing data
# Missing data comes in two forms: Missing day only, or missing both month and day
# We therefore define 3 data frames, one for full data and 2 for the two forms of missing data
YearOnly <- df2 %>%
        select(Visit1.pseudonym, Visit1.DiagParkYear, Visit1.DiagParkMonth, Visit1.DiagParkDay) %>%
        filter(!is.na(Visit1.DiagParkYear)) %>%
        filter(is.na(Visit1.DiagParkMonth))
YearOnly$Visit1.DiagParkYear <- as.numeric(YearOnly$Visit1.DiagParkYear)
YearOnly$Visit1.DiagParkMonth <- c(6)
YearOnly$Visit1.DiagParkDay <- c(15)  # < Time of diagnosis set to middle of the year

YearMonthOnly <- df2 %>%
        select(Visit1.pseudonym, Visit1.DiagParkYear, Visit1.DiagParkMonth, Visit1.DiagParkDay) %>%
        filter(!is.na(Visit1.DiagParkYear)) %>%
        filter(!is.na(Visit1.DiagParkMonth)) %>%
        filter(is.na(Visit1.DiagParkDay))
YearMonthOnly$Visit1.DiagParkYear <- as.numeric(YearMonthOnly$Visit1.DiagParkYear)
YearMonthOnly$Visit1.DiagParkMonth <- as.numeric(YearMonthOnly$Visit1.DiagParkMonth)
YearMonthOnly$Visit1.DiagParkDay <- c(15)     # < Time of diagnosis set to middle of the month

YearMonthDay <- df2 %>%
        select(Visit1.pseudonym, Visit1.DiagParkYear, Visit1.DiagParkMonth, Visit1.DiagParkDay) %>%
        filter(!is.na(Visit1.DiagParkYear)) %>%
        filter(!is.na(Visit1.DiagParkMonth)) %>%
        filter(!is.na(Visit1.DiagParkDay))
YearMonthDay$Visit1.DiagParkYear <- as.numeric(YearMonthDay$Visit1.DiagParkYear)
YearMonthDay$Visit1.DiagParkMonth <- as.numeric(YearMonthDay$Visit1.DiagParkMonth)
YearMonthDay$Visit1.DiagParkDay <- as.numeric(YearMonthDay$Visit1.DiagParkDay)

# Bind together the three tibbles defined above
EstDiagnosisDates <- dplyr::bind_rows(YearOnly, YearMonthOnly, YearMonthDay)

# Sort by pseudoynym (very important to have same order as main data frame)
EstDiagnosisDates <- EstDiagnosisDates %>%
        arrange(Visit1.pseudonym)

# Calculate an exact or estimated disease duration in years
EstDiagnosisDates <- EstDiagnosisDates %>% 
        mutate(EstDiagDate = ymd(paste(Visit1.DiagParkYear,Visit1.DiagParkMonth,Visit1.DiagParkDay))) %>%
        mutate(EstDisDurYears = as.numeric(today() - EstDiagDate) / 364)

# Add disease duration to main data frame
df2 <- bind_cols(df2, tibble(Visit1.EstDisDurYears = EstDiagnosisDates$EstDisDurYears))

#####

##### Select variables + Calculate bradykinesia/tremor subscore #####

# Variable selection
# Definition of bradykinesia subscore
df2 <- df2 %>%
        select(Visit1.pseudonym, 
               Visit1.Up3OfRigRue, Visit1.Up3OfRigRle, Visit1.Up3OfRigLue, Visit1.Up3OfRigLle,
               Visit1.Up3OfFiTaYesDev, Visit1.Up3OfFiTaNonDev,
               Visit1.Up3OfHaMoYesDev, Visit1.Up3OfHaMoNonDev,
               Visit1.Up3OfProSYesDev, Visit1.Up3OfProSNonDev,
               Visit1.Up3OfToTaYesDev, Visit1.Up3OfToTaNonDev,
               Visit1.Up3OfLAgiYesDev, Visit1.Up3OfLAgiNonDev,
               Visit1.Up3OfRAmpArmYesDev, Visit1.Up3OfRAmpArmNonDev,
               Visit1.Up3OfRAmpLegYesDev, Visit1.Up3OfRAmpLegNonDev,
               Visit1.Up3OfRAmpJaw,
               Visit1.EstDisDurYears,
               Visit1.Up3OfHoeYah,
               Visit1.MriNeuroPsychTask,
               Visit1.DiagParkCertain,
               Visit1.MostAffSide,
               Visit1.PrefHand,
               Visit1.Age,
               Visit1.Gender,
               Visit1.ParkinMedUser,
               Visit1.SmokeCurrent) %>%
        mutate(across(2:20, as.numeric)) %>%
        mutate(Visit1.BradySum = rowSums(.[2:15])) %>%
        mutate(Visit1.RestTremAmpSum = rowSums(.[16:20]))

# Transformations
df2$Visit1.Up3OfHoeYah <- as.factor(df2$Visit1.Up3OfHoeYah)                     # Hoen & Yahr stage
df2$Visit1.MriNeuroPsychTask <- as.factor(df2$Visit1.MriNeuroPsychTask)         # Which task was done?
levels(df2$Visit1.MriNeuroPsychTask) <- c('Motor', 'Reward')
df2$Visit1.DiagParkCertain <- as.factor(df2$Visit1.DiagParkCertain)             # Certainty of diagnosis
levels(df2$Visit1.DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
df2$Visit1.MostAffSide <- as.factor(df2$Visit1.MostAffSide)                     # Most affected side
levels(df2$Visit1.MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
df2$Visit1.PrefHand <- as.factor(df2$Visit1.PrefHand)                           # Dominant hand
levels(df2$Visit1.PrefHand) <- c('Right', 'Left', 'NoPref')
df2$Visit1.Gender <- as.factor(df2$Visit1.Gender)                               # Gender
levels(df2$Visit1.Gender) <- c('Male', 'Female')
df2$Visit1.Age <- as.numeric(df2$Visit1.Age)                                    # Age
df2$Visit1.ParkinMedUser <- as.factor(df2$Visit1.ParkinMedUser)                 # Parkinson's medication use
levels(df2$Visit1.ParkinMedUser) <- c('No','Yes')
df2$Visit1.SmokeCurrent <- as.factor(df2$Visit1.SmokeCurrent)                   # Smoking
levels(df2$Visit1.SmokeCurrent) <- c('Yes','No')

# Subsetting by task
#df2 <- df2 %>%
#        filter(Visit1.MriNeuroPsychTask == 'Motor')
# Subset by noticable tremor
#df2 <- df2 %>%
#        filter(Visit1.RestTremAmpSum >= 1)
#####

##### Plot ####

library(ggplot2)

## BRADYKINESIA ##
# Scatterplot (Bradykinesia/Tremor subscore ~ Disease duration)
bradykinesia_description <- paste("Bradykinesia subscore: \n",
                                  "Limb bradykinesia = Sum item 4-8 (0-40) \n",
                                  "Limb ridigity = Sum item 3 excl. neck (0-16)")

g_brady1 <- ggplot(df2, aes(Visit1.BradySum)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady1

g_brady2 <- ggplot(df2,aes(x = '',y = Visit1.BradySum)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady2

g_brady3 <- ggplot(df2, aes(x = Visit1.EstDisDurYears, y = Visit1.BradySum, colour = Visit1.Up3OfHoeYah)) + 
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

g_trem1 <- ggplot(df2, aes(Visit1.RestTremAmpSum)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Resting tremor amplitude') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_trem1

g_trem2 <- ggplot(df2,aes(x = '',y = Visit1.RestTremAmpSum)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Resting tremor amplitude') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_trem2

g_trem3 <- ggplot(df2, aes(x = Visit1.EstDisDurYears, y = Visit1.RestTremAmpSum, colour = Visit1.Up3OfHoeYah)) + 
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

g_disdur1 <- ggplot(df2, aes(Visit1.EstDisDurYears)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Disease duration (years)') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_disdur1

g_disdur2 <- ggplot(df2,aes(x = '',y = Visit1.EstDisDurYears)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Estimated disease duration (years)') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_disdur2

disdur_plots <- plot_grid(g_disdur1, g_disdur2, labels = 'AUTO', nrow = 1, ncol = 2)
disdur_plots

## AGE ##
g_age1 <- ggplot(df2, aes(Visit1.Age)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Age') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_age1

g_age2 <- ggplot(df2,aes(x = '',y = Visit1.Age)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Age') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_age2

age_plots <- plot_grid(g_age1, g_age2, labels = 'AUTO', nrow = 1, ncol = 2)
age_plots

## GENDER ##
g_gender1 <- ggplot(df2, aes(Visit1.Gender, fill = Visit1.Gender, colour = Visit1.Gender)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Gender') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_gender1

## HOEHN & YAHR ##
g_H&Y1 <- ggplot(df2, aes(Visit1.Up3OfHoeYah, fill = Visit1.Up3OfHoeYah, colour = Visit1.Up3OfHoeYah)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Hoehn & Yahr stage') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_H&Y1

## CERTAINTY OF DIAGNOSIS ##
g_certaintyofdiag1 <- ggplot(df2, aes(Visit1.DiagParkCertain, fill = Visit1.DiagParkCertain)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Certainty of diagnosis') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_certaintyofdiag1

## PD MEDICATION USAGE ##
g_meduse1 <- ggplot(df2, aes(Visit1.ParkinMedUser, fill = Visit1.ParkinMedUser)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'PD medication users') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_meduse1

## TASK ##
g_task1 <- ggplot(df2, aes(Visit1.MriNeuroPsychTask, fill = Visit1.MriNeuroPsychTask)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Task') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_task1

## MOST AFFECTED SIDE AND HANDEDNESS##
g_mas1 <- ggplot(df2, aes(Visit1.MostAffSide, fill = Visit1.MostAffSide)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Most affected side') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_mas1

g_prefhand1 <- ggplot(df2, aes(Visit1.PrefHand, fill = Visit1.PrefHand)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Dominant hand') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_prefhand1

df2_side <- df2 %>%
        select(Visit1.PrefHand, Visit1.MostAffSide) %>%
        table()
df2_side

# Summary stats
#df2_summary <- df2 %>%
#        dplyr::summarise(n = n(), 
#                         brady_mean = mean(Visit1.BradySum), brady_sd = sd(Visit1.BradySum),
#                         disdur_mean = mean(Visit1.EstDisDurYears), disdur_sd = sd(Visit1.EstDisDurYears)) %>%
#        dplyr::mutate(brady_se = brady_sd/sqrt(n), brady_ci = 2*brady_se,
#                      disdur_se = disdur_sd/sqrt(n), disdur_ci = 2*disdur_se)


#####

##### Clustering #####

## KMEANS ##
# Kmeans with intention to separate tremor dominant from non-dominant
# Method does not work
# Gives a straight split into low and high bradykinesia
# Tremor is not being weighed high enough. Probably due to low amount of
# participants with noticable tremor.
df2_kmeans <- df2 %>%
        select(Visit1.BradySum, Visit1.RestTremAmpSum)
kmeansObj <- kmeans(df2_kmeans, centers = 2)
plot(df2_kmeans$Visit1.BradySum, df2_kmeans$Visit1.RestTremAmpSum, col = kmeansObj$cluster, pch = 19, cex = 2)
points(kmeansObj$centers, col = 1:2, pch = 3, cex = 3, lwd = 3)

#####