source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
library(tidyverse)

##### Load data #####

# Import data
# Clin vars for POM
df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-05-27.csv')
write_csv(df.clin.pom, paste('P:/3022026.01/analyses/nina/FromMartin/CastorData_', today(), '.csv', sep = ''))
# Add LEDD, remove non-medusers
df.ledd <- read_csv('P:/3024006.02/Data/LEDD/MedicationTable.csv')
df.clin.pom <- left_join(df.clin.pom, df.ledd, by = c('pseudonym', 'Timepoint')) %>%
        filter(Timepoint == 'ses-POMVisit1')
# Add subtypes
df.subtypes <- read_csv('P:/3024006.02/Data/Subtyping/Subtypes_2021-04-06.csv')
df.clin.pom <- left_join(df.clin.pom, df.subtypes, by = 'pseudonym')
# Task data for POM
df.task.pom <- read_csv('P:/3022026.01/pep/bids/derivatives/database_motor_task_2021-05-21.csv')
df.task.pom_wide <- df.task.pom %>%
        filter(Timepoint == 'ses-POMVisit1') %>%
        select(pseudonym, Timepoint, Condition, Response.Time, Percentage.Correct, Button.Press.SwitchRatio) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Percentage.Correct, Response.Time, Button.Press.SwitchRatio))

#####

variable_list <- c('StaiTrait01', 'StaiTrait02', 'StaiTrait03', 'StaiTrait04', 'StaiTrait05', 'StaiTrait06', 'StaiTrait07', 'StaiTrait08', 'StaiTrait09', 'StaiTrait10', 'StaiTrait11', 'StaiTrait12', 'StaiTrait13', 'StaiTrait14', 'StaiTrait15', 'StaiTrait16', 'StaiTrait17', 'StaiTrait18', 'StaiTrait19', 'StaiTrait20',
                    'StaiState01', 'StaiState02', 'StaiState03', 'StaiState04', 'StaiState05', 'StaiState06', 'StaiState07', 'StaiState08', 'StaiState09', 'StaiState10', 'StaiState11', 'StaiState12', 'StaiState13', 'StaiState14', 'StaiState15', 'StaiState16', 'StaiState17', 'StaiState18', 'StaiState19', 'StaiState20',
                    'QuipIt01', 'QuipIt02', 'QuipIt03', 'QuipIt04', 'QuipIt05', 'QuipIt06', 'test', 'QuipIt08', 'QuipIt09', 'QuipIt10', 'QuipIt12', 'QuipIt13', 'QuipIt14', 'QuipIt15', 'QuipIt16', 'QuipIt17', 'QuipIt18', 'QuipIt19', 'QuipIt20', 'QuipIt21', 'QuipIt22', 'QuipIt23', 'QuipIt24', 'QuipIt25', 'QuipIt26', 'QuipIt27', 'QuipIt28',
                    'Aes12Pd01', 'Aes12Pd02', 'Aes12Pd03', 'Aes12Pd04', 'Aes12Pd05', 'Aes12Pd06', 'Aes12Pd07', 'Aes12Pd08', 'Aes12Pd09', 'Aes12Pd10', 'Aes12Pd11', 'Aes12Pd12',
                    'Sf12It01', 'Sf12It02', 'Sf12It03', 'Sf12It04', 'SfIt05', 'SfIt056', 'SfIt07', 'SfIt08', 'SfIt09', 'SfIt10', 'SfIt11', 'Sf12It12',
                    'Bdi2It01', 'Bdi2It02', 'Bdi2It03', 'Bdi2It04', 'Bdi2It05', 'Bdi2It06', 'Bdi2It07', 'Bdi2It08', 'Bdi2It09',  'Bdi2It10', 'Bdi2It11', 'Bdi2It12', 'Bdi2It13', 'Bdi2It14', 'Bdi2It15', 'Bdi2It16', 'Bdi2It17', 'Bdi2It18', 'Bdi2It19', 'Bdi2It20', 'Bdi2It21',
                    'Pdq39It01', 'Pdq39It02', 'Pdq39It03', 'Pdq39It04', 'Pdq39It05', 'Pdq39It06', 'Pdq39It07', 'Pdq39It08', 'Pdq39It09', 'Pdq39It10', 'Pdq39It11', 'Pdq39It12', 'Pdq39It13', 'Pdq39It14', 'Pdq39It15', 'Pdq39It16', 'Pdq39It17', 'Pdq39It18', 'Pdq39It19', 'Pdq39It20', 'Pdq39It21', 'Pdq39It22', 'Pdq39It23', 'Pdq39It24', 'Pdq39It25', 'Pdq39It26', 'Pdq39It27', 'Pdq39It28a', 'Pdq39It28b', 'Pdq39It29', 'Pdq39It30', 'Pdq39It31', 'Pdq39It32', 'Pdq39It33', 'Pdq39It34', 'Pdq39It35', 'Pdq39It36', 'Pdq39It37', 'Pdq39It38', 'Pdq39It39',
                    'Woq1Off', 'Woq2Off', 'Woq3Off', 'Woq4Off', 'Woq5Off', 'Woq6Off', 'Woq7Off', 'Woq8Off', 'Woq9Off',
                    'Woq1Bet', 'Woq2Bet', 'Woq3Bet', 'Woq4Bet', 'Woq5Bet', 'Woq6Bet', 'Woq7Bet', 'Woq8Bet', 'Woq9Bet',
                    'TalkProb01', 'TalkProb02', 'TalkProb03', 'TalkProb04', 'TalkProb05', 'TalkProb06', 'TalkProb07',
                    'VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04', 'VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr08', 'VisualPr09', 'VisualPr10', 'VisualPr11', 'VisualPr12', 'VisualPr13', 'VisualPr14', 'VisualPr15', 'VisualPr16', 'VisualPr17', 'VisualPr18', 'VisualPr19', 'VisualPr20', 'VisualPr21', 'VisualPr22', 'VisualPr23',
                    'FrOfGait01', 'FrOfGait02', 'FrOfGait03', 'FrOfGait04', 'FrOfGait05', 'FrOfGait06', 'FrOfGait07', 'FrOfGait08', 'FrOfGait09',
                    'PaseVr01', 'PaseVr02', 'PaseVr02a', 'PaseVr02b', 'PaseVr03', 'PaseVr04', 'PaseVr04a', 'PaseVr05', 'PaseVr05a', 'PaseVr05b', 'PaseVr06', 'PaseVr06a', 'PaseVr06b', 'PaseVr07', 'PaseVr07a', 'PaseVr07b', 'PaseVr08', 'PaseVr09', 'PaseRem3', 'PaseVr10a', 'PaseVr10b', 'PaseVr10c', 'PaseVr10d', 'PaseVr11','PaseVr11a', 'PaseVr11b',
                    'FallenLast5Year', 'FallenTimes', 'FallenLastTimeYear', 'FallenLastTimeMonth', 'FallenLastTimeDay')

df <- left_join(df.clin.pom, df.task.pom_wide, by = c('pseudonym', 'Timepoint'))

df_selected1 <- df %>%
        select(pseudonym, Subtype, Age, Gender, EstDisDurYears, LEDD, ParkinMedUser, MriNeuroPsychTask,
                Up3OfTotal, Up3OfBradySum, Up3OfPIGDSum, Up3OfRigiditySum, Up3OfRestTremAmpSum, Up3OfPegRLBSum,
                Up3OfTotal.1YearDelta, Up3OfBradySum.1YearDelta, Up3OfPIGDSum.1YearDelta, Up3OfRigiditySum.1YearDelta, Up3OfRestTremAmpSum.1YearDelta, Up3OfPegRLBSum.1YearDelta,
                Up3TotalOnOffDelta, Up3BradySumOnOffDelta, Up3RestTremAmpSumOnOffDelta,
               STAITraitSum, STAIStateSum, QUIPicdSum, QUIPrsSum, AES12Sum, BDI2Sum, TalkProbSum, VisualProb23Sum, VisualProb17Sum,
               PDQ39_mobilitySum, PDQ39_activitiesSum, PDQ39_emotionalSum, PDQ39_stigmaSum, PDQ39_socialsupportSum, PDQ39_cognitionsSum, PDQ39_communicationSum, PDQ39_bodilydiscomfortSum, PDQ39_SingleIndex,
               STAITraitSum.1YearDelta, STAIStateSum.1YearDelta, QUIPicdSum.1YearDelta, QUIPrsSum.1YearDelta, AES12Sum.1YearDelta, BDI2Sum.1YearDelta, PDQ39_SingleIndex.1YearDelta, TalkProbSum.1YearDelta,
               VisualProb23Sum.1YearDelta, VisualProb17Sum.1YearDelta,
               starts_with('Up3Of'),
               starts_with('Up3On'),
               any_of(variable_list))

df_selected2 <- df_selected1 %>%
        filter(MriNeuroPsychTask == 'Motor')

df_selected3 <- df %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        select(pseudonym, Subtype, Age, Gender, EstDisDurYears, LEDD, ParkinMedUser, Button.Press.SwitchRatio_Ext,
                Response.Time_Ext, Response.Time_Int2, Response.Time_Int3,
               Percentage.Correct_Ext, Percentage.Correct_Int2, Percentage.Correct_Int3, Percentage.Correct_Catch) %>%
        mutate(Response.Time_Int = (Response.Time_Int2 + Response.Time_Int3)/2,
               Percentage.Correct_Int = (Percentage.Correct_Int2 + Percentage.Correct_Int3)/2,
               IntExtDelta = Response.Time_Int - Response.Time_Ext)

OutputName1 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'ClinVars_All_', today(), '.csv', sep='')
write_csv(df_selected1, OutputName1)
OutputName2 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'ClinVars_MotorOnly_', today(), '.csv', sep='')
write_csv(df_selected2, OutputName2)
OutputName3 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'Behav_MotorOnly_', today(), '.csv', sep='')
write_csv(df_selected3, OutputName3)
