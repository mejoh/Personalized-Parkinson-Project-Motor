source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
detach(package:dplyr)
library(dplyr)
library(tidyverse)

##### Load data #####
# Write csv files
bidsdir_clin <- 'P:/3022026.01/pep/ClinVars/'
bidsdir <- 'P:/3022026.01/pep/bids/'
#generate_castor_csv(bidsdir_clin)
#generate_PIT_castor_csv(bidsdir_clin)
#generate_motor_task_csv(bidsdir)

# Import data
# Clin vars for POM
df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-04-15.csv')
df.clin.pit <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_PIT_clinical_variables_2021-05-21.csv')
# remove non-medusers
df.clin.pom <- df.clin.pom %>% filter(ParkinMedUser == 'Yes')
# Add subtypes
df.subtypes <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/Subtypes_2021-04-12.csv')
df.clin.pom <- left_join(df.clin.pom, df.subtypes, by = 'pseudonym')
# Task data for POM
df.task <- read_csv('P:/3022026.01/pep/bids/derivatives/database_motor_task_2021-05-21.csv')
# Remove study identifier from Timepoint
df.clin.pom$Timepoint <- str_remove(df.clin.pom$Timepoint, 'POM')
df.clin.pit$Timepoint <- str_remove(df.clin.pit$Timepoint, 'PIT')
df.task$Timepoint <- str_remove(df.task$Timepoint, 'POM')
df.task$Timepoint <- str_remove(df.task$Timepoint, 'PIT')

#Assemble data frame
g <- 'PD_POM'
df <- df.task %>%
        filter(Group == 'HC_PIT' | Group == g) %>% 
        filter(Condition != 'Catch') %>%
        mutate(Response.Time_log = log(Response.Time),
               Condition = as.factor(Condition))
covars1 <- df.clin.pom %>% select(pseudonym, Timepoint, Age, Gender, Group, Subtype, EstDisDurYears) %>% na.omit
covars2 <- df.clin.pit %>% select(pseudonym, Timepoint, Age, Gender, Group) %>% na.omit
covars <- full_join(covars1,covars2)
df <- left_join(df, covars, by = c('pseudonym', 'Timepoint', 'Group')) %>%
        mutate(Group = as.factor(Group),
               Gender = as.factor(Gender),
               Age_c = scale(Age, center = TRUE, scale = FALSE))

df_wide <- df %>%
        select(pseudonym, Age, Gender, Group, Subtype, Responding.Hand, Timepoint, Condition, Response.Time, Percentage.Correct, Button.Press.SwitchRatio) %>%
        pivot_wider(names_from = 'Condition',
                    values_from = c('Response.Time', 'Percentage.Correct'))

PoorPerformanceIndex <- which(df_wide$Percentage.Correct_Ext < 0.25 | is.na(df_wide$Percentage.Correct_Ext))
cat('Number of subjects excluded due to poor performance:', length(PoorPerformanceIndex))
df_wide <- df_wide[-PoorPerformanceIndex, ]

df_rt <- df_wide %>% 
        pivot_longer(cols = starts_with('Response.Time'),
                     names_to = 'Condition',
                     names_prefix = 'Response.Time_',
                     values_to = 'Response.Time') %>%
        select(-starts_with('Percentage.Correct'))
df_pc <- df_wide %>%
        pivot_longer(cols = starts_with('Percentage.Correct'),
                     names_to = 'Condition',
                     names_prefix = 'Percentage.Correct_',
                     values_to = 'Percentage.Correct') %>%
        select(Percentage.Correct)
df_long <- bind_cols(df_rt,df_pc)

df_fmriconfs <- df_long %>%
        filter(Condition=='Ext') %>%
        filter(Timepoint=='ses-Visit1') %>%
        select(pseudonym, Group, Age, Gender) %>%
        arrange(Group, pseudonym)

outputname <- 'P:/3024006.02/Users/susvdlog/FromMartin/database_fmri_confounds.csv'
write_csv(df_fmriconfs, outputname)

outputname <- 'P:/3024006.02/Users/susvdlog/FromMartin/database_motor_performance_wide.csv'
write_csv(df_wide, outputname)

outputname <- 'P:/3024006.02/Users/susvdlog/FromMartin/database_motor_performance_long.csv'
write_csv(df_long, outputname)
