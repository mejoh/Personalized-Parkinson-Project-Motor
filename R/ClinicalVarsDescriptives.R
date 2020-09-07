source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
df2 <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

##### Subset #####
df2 <- df2 %>%
        filter(MriNeuroPsychTask == 'Motor')
#####

##### Export data #####
pth <- "P:/3022026.01/analyses/nina/"
fname <- paste(pth, "CastorData.csv", sep = '')
write_csv(df2, fname)
#####

##### Summary stats #####

##
#df2 %>% group_by(timepoint) %>% summarise(Off = mean(Up3OfTotal, na.rm = TRUE), On = mean(Up3OnTotal, na.rm = TRUE))
#df2 %>% group_by(timepoint) %>% summarise(missing = sum(is.na(Up3OfTotal)), n = n())

#####

source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
library(ggplot2)
library(cowplot)

##### DEPRECATED Plots, Visit1 ####

df2_v1 <- df2 %>%
        filter(timepoint == 'V1')

## Total UPDRS3 score ##
g_SumUpdrs31 <- ggplot(df2_v1, aes(Up3OfSumOfTotalWithinRange)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Total UPDRS3') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_SumUpdrs31

g_SumUpdrs32 <- ggplot(df2_v1,aes(x = '',y = Up3OfSumOfTotalWithinRange)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Total UPDRS3') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_SumUpdrs32

g_SumUpdrs33 <- ggplot(df2_v1, aes(x = EstDisDurYears, y = Up3OfSumOfTotalWithinRange, colour = Up3OfHoeYah)) + 
        geom_point(alpha = .6, size = 4) + 
        geom_smooth(method = 'lm', col = 'red') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        theme_cowplot(font_size = 25) +
        labs(x = 'Disease duration (years)',
             y = 'Total UPDRS3',
             title = 'Progression of motor symptoms')
g_SumUpdrs33
totalupdrs3_plots <- plot_grid(g_SumUpdrs31, g_SumUpdrs32, g_SumUpdrs33, labels = 'AUTO', nrow = 2, ncol = 2)
totalupdrs3_plots

## BRADYKINESIA ##
# Scatterplot (Bradykinesia/Tremor subscore ~ Disease duration)
bradykinesia_description <- paste("Bradykinesia subscore: \n",
                                  "Limb bradykinesia = Sum item 4-8 (0-40) \n",
                                  "Limb ridigity = Sum item 3 excl. neck (0-16)")

g_brady1 <- ggplot(df2_v1, aes(BradySumOff)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady1

g_brady2 <- ggplot(df2_v1,aes(x = '',y = BradySumOff)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Bradykinesia subscore') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_brady2

g_brady3 <- ggplot(df2_v1, aes(x = EstDisDurYears, y = BradySumOff, colour = Up3OfHoeYah)) + 
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
        labs(title = 'Estimated disease duration (years)') +
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

## Education years ##
g_EducYears1 <- ggplot(df2_v1, aes(NpsEducYears)) +
        geom_density(alpha = 1/2, lwd = 1, colour = 'blue', fill = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Education years') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_EducYears1

g_EducYears2 <- ggplot(df2_v1,aes(x = '',y = NpsEducYears)) +
        geom_boxplot(lwd = 1, colour = 'blue') +
        theme_cowplot(font_size = 25) +
        labs(title = 'Education years') + xlab('Patients') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_EducYears2

EducYears_plots <- plot_grid(g_EducYears1, g_EducYears2, labels = 'AUTO', nrow = 1, ncol = 2)
EducYears_plots

## GENDER ##
g_gender1 <- ggplot(df2_v1, aes(Gender, fill = Gender, colour = Gender)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Gender') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_gender1

## HOEHN & YAHR ##
g_HY1 <- ggplot(df2_v1, aes(Up3OfHoeYah, fill = Up3OfHoeYah, colour = Up3OfHoeYah)) +
        geom_bar() +
        theme_cowplot(font_size = 25) +
        labs(title = 'Hoehn & Yahr stage') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_HY1

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

df2_v1 %>% filter(ParkinMedUser == 'No')

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

##### DEPRECATED Plots, Visit2 #####

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
        geom_boxplot(lwd = 1, colour = 'blue') +
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
                         Up3Sum_mean = mean(Up3OfSumOfTotalWithinRange, na.rm = TRUE), Up3Sum_sd = sd(Up3OfSumOfTotalWithinRange, na.rm = TRUE),
                         brady_mean = mean(BradySum, na.rm = TRUE), brady_sd = sd(BradySum, na.rm = TRUE),
                         tremor_mean = mean(RestTremAmpSum, na.rm = TRUE), tremor_sd = sd(RestTremAmpSum, na.rm = TRUE),
                         disdur_mean = mean(EstDisDurYears, na.rm = TRUE), disdur_sd = sd(EstDisDurYears, na.rm = TRUE)) %>%
        dplyr::mutate(Up3Sum_se = Up3Sum_sd/sqrt(n), Up3Sum_ci = 2*Up3Sum_se,
                      brady_se = brady_sd/sqrt(n), brady_ci = 2*brady_se,
                      tremor_se = tremor_sd/sqrt(n), tremor_ci = 2*tremor_se,
                      disdur_se = disdur_sd/sqrt(n), disdur_ci = 2*disdur_se)

## Total UPDRS3
g_Up3Sumprog1vio <- ggplot(df2, aes(x = timepoint, y = Up3OfSumOfTotalWithinRange, fill = timepoint)) +
        geom_flat_violin(aes(fill = timepoint),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = 'black', size = 1)+
        geom_point(aes(x = as.numeric(timepoint)-.15, y = Up3OfSumOfTotalWithinRange, colour = timepoint),position = position_jitter(width = .05), size = 2, shape = 20, alpha = .7)+
        geom_boxplot(aes(x = timepoint, y = Up3OfSumOfTotalWithinRange, fill = timepoint),outlier.shape = NA, alpha = .5, width = .1, colour = "black", size = 1)+
        geom_line(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = Up3Sum_mean, group = timepoint, colour = timepoint), linetype = 3, lwd = 2)+
        geom_point(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = Up3Sum_mean, group = timepoint, colour = timepoint), shape = 18, size = 1) +
        geom_errorbar(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = Up3Sum_mean, group = timepoint, colour = timepoint, ymin = Up3Sum_mean-Up3Sum_se, ymax = Up3Sum_mean+Up3Sum_se), width = .05, size = 1)+
        scale_colour_brewer(palette = "Set1")+
        scale_fill_brewer(palette = "Set1")+
        ggtitle("Total UPDRS3 as a function of time") +
        theme_cowplot(font_size = 25)
g_Up3Sumprog1vio

g_Up3Sumprog1 <- ggplot(df2, aes(x = EstDisDurYears, y = Up3OfSumOfTotalWithinRange, colour = timepoint)) +
        geom_point(aes(fill = timepoint), size = 3) +
        geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Total UPDRS3 progression')
g_Up3Sumprog1

g_Up3Sumprog2 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(x = timepoint, y = Up3OfSumOfTotalWithinRange, fill = timepoint)) +
        geom_boxplot(lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Total UPDRS3') + xlab('Time') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_Up3Sumprog2

g_Up3Sumprog3 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(Up3OfSumOfTotalWithinRange, fill = timepoint)) +
        geom_density(alpha = 1/2, lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Total UPDRS3') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        geom_vline(aes(xintercept = mean(df2$Up3OfSumOfTotalWithinRange[df2$timepoint == 'V1'], na.rm = TRUE)), lwd = 2, color = 'red') +
        geom_vline(aes(xintercept = mean(df2$Up3OfSumOfTotalWithinRange[df2$timepoint == 'V2'], na.rm = TRUE)), lwd = 2, color = 'blue')
g_Up3Sumprog3

Up3Sum_prog_plots <- plot_grid(g_Up3Sumprog1vio, g_Up3Sumprog1, g_Up3Sumprog2, g_Up3Sumprog3, labels = 'AUTO', nrow = 2, ncol = 2)
Up3Sum_prog_plots


## Bradykinesia
g_bradyprog1vio <- ggplot(df2, aes(x = timepoint, y = BradySum, fill = timepoint)) +
        geom_flat_violin(aes(fill = timepoint),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = 'black', size = 1)+
        geom_point(aes(x = as.numeric(timepoint)-.15, y = BradySum, colour = timepoint),position = position_jitter(width = .05), size = 2, shape = 20, alpha = .7)+
        geom_boxplot(aes(x = timepoint, y = BradySum, fill = timepoint),outlier.shape = NA, alpha = .5, width = .1, colour = "black", size = 1)+
        geom_line(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint), linetype = 3, lwd = 2)+
        geom_point(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint), shape = 18, size = 1) +
        geom_errorbar(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = brady_mean, group = timepoint, colour = timepoint, ymin = brady_mean-brady_se, ymax = brady_mean+brady_se), width = .05, size = 1)+
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
        labs(title = 'Bradykinesia subscore') + xlab('Time') +
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

bradykinesia_prog_plots <- plot_grid(g_bradyprog1vio, g_bradyprog1, g_bradyprog2, g_bradyprog3, labels = 'AUTO', nrow = 2, ncol = 2)
bradykinesia_prog_plots

## Tremor
g_tremorprog1vio <- ggplot(df2, aes(x = timepoint, y = RestTremAmpSum, fill = timepoint)) +
        geom_flat_violin(aes(fill = timepoint),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = 'black', size = 1)+
        geom_point(aes(x = as.numeric(timepoint)-.15, y = RestTremAmpSum, colour = timepoint),position = position_jitter(width = .05), size = 2, shape = 20, alpha = .7)+
        geom_boxplot(aes(x = timepoint, y = RestTremAmpSum, fill = timepoint),outlier.shape = NA, alpha = .5, width = .1, colour = "black", size = 1)+
        geom_line(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = tremor_mean, group = timepoint, colour = timepoint), linetype = 3, lwd = 2)+
        geom_point(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = tremor_mean, group = timepoint, colour = timepoint), shape = 18, size = 1) +
        geom_errorbar(data = df2_summary, aes(x = as.numeric(timepoint)+.1, y = tremor_mean, group = timepoint, colour = timepoint, ymin = tremor_mean-tremor_se, ymax = tremor_mean+tremor_se), width = .05, size = 1)+
        scale_colour_brewer(palette = "Set1")+
        scale_fill_brewer(palette = "Set1")+
        ggtitle("Tremor subscore as a function of time") +
        theme_cowplot(font_size = 25)
g_tremorprog1vio

g_tremorprog1 <- ggplot(df2, aes(x = EstDisDurYears, y = RestTremAmpSum, colour = timepoint)) +
        geom_point(aes(fill = timepoint), size = 3) +
        geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Tremor progression')
g_tremorprog1

g_tremorprog2 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(x = timepoint, y = RestTremAmpSum, fill = timepoint)) +
        geom_boxplot(lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Tremor subscore') + xlab('Time') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1')
g_tremorprog2

g_tremorprog3 <- df2 %>%
        filter(MultipleSessions == 'Yes') %>%
        ggplot(aes(RestTremAmpSum, fill = timepoint)) +
        geom_density(alpha = 1/2, lwd = 1) +
        theme_cowplot(font_size = 25) +
        labs(title = 'Tremor subscore') +
        scale_color_brewer(palette = 'Set1') +
        scale_fill_brewer(palette = 'Set1') +
        geom_vline(aes(xintercept = mean(df2$RestTremAmpSum[df2$timepoint == 'V1'], na.rm = TRUE)), lwd = 2, color = 'red') +
        geom_vline(aes(xintercept = mean(df2$RestTremAmpSum[df2$timepoint == 'V2'], na.rm = TRUE)), lwd = 2, color = 'blue')
g_tremorprog3

tremor_prog_plots <- plot_grid(g_tremorprog1vio, g_tremorprog1, g_tremorprog2, g_tremorprog3, labels = 'AUTO', nrow = 2, ncol = 2)
tremor_prog_plots

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

##### General plotting #####

# Box plots for exploring Time x Group interactions (e.g. effect of medication)
SessionByGroupBoxPlots <- function(dataframe, x, groups){
        
        library(reshape2)
        
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint == 'V1' | timepoint == 'V2') %>%
                select(c(pseudonym, timepoint, !!groups)) %>%
                melt(id.vars = c('pseudonym', 'timepoint'), variable.name = 'group') %>%
                tibble        
                
        g_SbyGbox <- dataframe %>%
                ggplot(aes(timepoint, value, fill = group)) +
                geom_boxplot(lwd = 1, outlier.size = 3) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        g_SbyGdens <- dataframe %>%
                ggplot(aes(value, colour = timepoint)) +
                geom_density(data = dataframe %>% filter(timepoint=='V1'), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                geom_density(data = dataframe %>% filter(timepoint=='V2'), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_SbyGbox, g_SbyGdens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label('Time x Group interaction plot', fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
x <- c('timepoint')
groups <- c('Up3OfTotal', 'Up3OnTotal')
SessionByGroupBoxPlots(df2, x, groups)

# Box and density plots for exploring variables from multiple sessions
MultipleSessionBoxDensPlots <- function(dataframe, x, y){
        
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint == 'V1' | timepoint == 'V2')
       
         g_box <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) + 
                geom_boxplot(lwd=1, outlier.size = 3, fill = 'darkgrey') + 
                theme_cowplot(font_size = 25)
        
        g_dens <- dataframe %>%
                ggplot(aes_string(y, fill = x)) +
                geom_density(alpha = 1/2, lwd = 1) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_box, g_dens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label(y, fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('timepoint')
for(n in unique(y)){
        g <- MultipleSessionBoxDensPlots(df2, x, n)
        print(g)
}

# Box and density plots for exploring variables from single sessions
SingleSessionBoxDensPlots <- function(dataframe, y, visit){
        
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_box <- ggplot(dataframe, aes_string(x = "''", y = y)) +
                geom_boxplot(lwd = 1, fill = 'darkgrey', outlier.size = 3) +
                theme_cowplot(font_size = 25)
        
        g_dens <- ggplot(dataframe, aes_string(y)) +
                geom_density(alpha = 1/2, lwd = 1, fill = 'darkgrey') +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_box, g_dens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label(paste(y, '   Timepoint =', visit), fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
visit = c('V1')
for(n in unique(y)){
        g <- SingleSessionBoxDensPlots(df2, n, visit)
        print(g)
}

# Bar graphs for exploring frequencies
SingleSessionBarPlots <- function(dataframe, y, visit){
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_bar <- dataframe %>%
                ggplot(aes_string(y)) +
                geom_bar(colour = 'darkgrey') +
                theme_cowplot(font_size = 25) +
                labs(title = paste(y, '   Timepoint =', visit))
        g_bar
}
y <- c('Gender')
visit <- c('V1')
for(n in unique(y)){
        g <- SingleSessionBarPlots(df2, n, visit)
        print(g)
}

# Scatter plots for exploring relationships between disease progression and duration, tagged with timepoint
ScatterPlotsComplex <- function(dataframe, y, x, group){
        dataframe <- dataframe %>%
                filter(timepoint == 'V1' | timepoint == 'V2')
                
        g_scatter1 <- dataframe %>%
                ggplot(aes_string(x = x, y = y, colour = group)) + 
                geom_point(size = 3) +
                geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25)
        
        progvar <- paste(y, '.1YearProg', sep = '')
        
        g_scatter2 <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) + 
                geom_point(size = 3) +
                geom_point(data = dataframe %>% filter(timepoint == 'V2'), aes_string(y = y, color = progvar), size = 3) +
                geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient(low = 'blue', high = 'red')
        
        mean_progression <- mean(unlist(dataframe[, colnames(dataframe) == progvar]), na.rm = TRUE)
        
        g_scatter3 <- dataframe %>% filter(timepoint == 'V2') %>%
                ggplot(aes_string(x = x, y = progvar, colour = progvar)) +
                geom_point(size = 3) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient(low = 'blue', high = 'red') +
                geom_hline(yintercept = mean_progression, linetype = 3, lwd = 1)
        
        plots <- plot_grid(g_scatter1, g_scatter2, g_scatter3, labels = 'AUTO', nrow = 3, ncol = 1)
        plot_grid(plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('EstDisDurYears')
group <- c('timepoint')
for(n in unique(y)){
        g <- ScatterPlotsComplex(df2, n, x, group)
        print(g)
}

# Simpler scatter plots
ScatterPlotsSimple <- function(dataframe, y, x, visit){
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_scatter <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) +
                geom_point(size = 3) +
                geom_smooth(method = 'lm') +
                theme_cowplot(font_size = 25)
        g_scatter + labs(title = paste(y, ' ~ ', x, '   Timepoint =', visit))
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('EstDisDurYears')
visit <- c('V1')
for(n in unique(y)){
        g <- ScatterPlotsSimple(df2, n, x, visit)
        print(g)
}

# Lineplots for lmer
SubjectSlopesPlots <- function(dataframe, y, x, group){
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes')
        
        progvar <- paste(y, '.1YearProg', sep = '')
        g_line <- ggplot(dataframe, aes_string(x=x, y=y, group=group)) +
                geom_line(aes_string(color=progvar), lwd = 1.2,  alpha = .7) + 
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25)
        g_line
}
y <- c('Up3OfTotal')
x <- c('timepoint')
group <- c('pseudonym')
for(n in unique(y)){
        g <- SubjectSlopesPlots(df2, y, x, group)
        print(g)
}

MedSlopesMeanPlots <- function(dataframe){
        dataframe <- dataframe %>%
                select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal) %>%
                group_by(timepoint) %>%
                summarise(Off=mean(Up3OfTotal, na.rm=TRUE), On=mean(Up3OnTotal, na.rm=TRUE)) %>%
                pivot_longer(!timepoint, names_to='Medication', values_to='Up3Total')
        
        g_line <- ggplot(dataframe, aes(x=timepoint, y = Up3Total, group=Medication)) +
                geom_line(aes(color=Medication), lwd=1) +
                geom_point(size=5) +
                theme_cowplot(font_size = 25)
        
        g_line
}

MedSlopesMeanPlots(df2)


#####

df2_ttest <- df2 %>%
        filter(timepoint == 'V2')

t.test(df2_ttest$Up3OfSumOfTotalWithinRange.1YearProg, alternative = 'two.sided')
t.test(df2_ttest$BradySum.1YearProg, alternative = 'two.sided')
t.test(df2_ttest$RestTremAmpSum.1YearProg, alternative = 'two.sided')

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