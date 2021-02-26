source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
library(tidyverse)
library(lme4)
library(lmerTest)

##### Load data #####

# Import data
# Clin vars for POM
df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-02-23.csv')
# Add LEDD, remove non-medusers
df.ledd <- read_csv('P:/3024006.02/Data/LEDD/MedicationTable.csv')
df.clin.pom <- left_join(df.clin.pom, df.ledd, by = c('pseudonym', 'Timepoint')) %>%
        filter(Timepoint == 'ses-Visit1')
# Add subtypes
df.subtypes <- read_csv('P:/3024006.02/Data/Subtyping/Subtypes.csv')
df.clin.pom <- left_join(df.clin.pom, df.subtypes, by = 'pseudonym')
# Task data for POM
df.task.pom <- read_csv('P:/3022026.01/pep/bids/derivatives/database_motor_task.csv')
df.task.pom_wide <- df.task.pom %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Timepoint, Condition, Response.Time, Percentage.Correct) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Percentage.Correct, Response.Time))

#####

df <- left_join(df.clin.pom, df.task.pom_wide, by = c('pseudonym', 'Timepoint'))

df_selected1 <- df %>%
        select(pseudonym, Subtype, Age, Gender, EstDisDurYears, LEDD, ParkinMedUser, MriNeuroPsychTask,
                Up3OfTotal, Up3OfBradySum, Up3OfPIGDSum, Up3OfRigiditySum, Up3OfRestTremAmpSum,
                Up3OfTotal.1YearDelta, Up3OfBradySum.1YearDelta, Up3OfPIGDSum.1YearDelta, Up3OfRigiditySum.1YearDelta, Up3OfRestTremAmpSum.1YearDelta,
                Up3TotalOnOffDelta, Up3BradySumOnOffDelta, Up3RestTremAmpSumOnOffDelta)

df_selected2 <- df_selected1 %>%
        filter(MriNeuroPsychTask == 'Motor')

df_selected3 <- df %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        select(pseudonym, Subtype, Age, Gender, EstDisDurYears, LEDD, ParkinMedUser,
                Response.Time_Ext, Response.Time_Int2, Response.Time_Int3,
               Percentage.Correct_Ext, Percentage.Correct_Int2, Percentage.Correct_Int3, Percentage.Correct_Catch) %>%
        mutate(Response.Time_Int = (Response.Time_Int2 + Response.Time_Int3)/2,
               Percentage.Correct_Int = (Percentage.Correct_Int2 + Percentage.Correct_Int3)/2,
               IntExtDelta = Response.Time_Int - Response.Time_Ext)

OutputName1 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'ClinVars_All.csv', sep='')
write_csv(df_selected1, OutputName1)
OutputName2 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'ClinVars_MotorOnly.csv', sep='')
write_csv(df_selected2, OutputName2)
OutputName3 <- paste('P:/3022026.01/analyses/nina/FromMartin/', 'Behav_MotorOnly.csv', sep='')
write_csv(df_selected3, OutputName3)