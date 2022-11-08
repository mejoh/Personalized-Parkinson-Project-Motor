source("M:/scripts/Personalized-Parkinson-Project-Motor/R/motor_dataTable_for_3dLMEr.R")

library(tidyverse)

# Write tables for summary contrasts

dataTable_3dLMEr_single(con = 'con_0010.nii')
dataTable_3dLMEr_single(con = 'con_0012.nii')
dataTable_3dLMEr_single(con = 'con_0013.nii')
dataTable_3dLMEr_single(con = 'con_0008.nii')

# Write tables for choice contrasts

dataTable_3dLMEr_single(con = 'con_0001.nii')
dataTable_3dLMEr_single(con = 'con_0002.nii')
dataTable_3dLMEr_single(con = 'con_0003.nii')
dataTable_3dLMEr_single(con = 'con_0004.nii')

# Generate combined tables to enable modelling of random slopes

c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0001_disease_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0002_disease_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0003_disease_dataTable.txt') %>%
  mutate(trial_type = '3c')
c4 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0004_disease_dataTable.txt') %>%
  mutate(trial_type = 'catch')

c12 <- full_join(c1,c2)
c1234 <- full_join(c12,c3) %>%
  full_join(., c4) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Group, TimepointNr, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_disease_dataTable.txt'
write_tsv(c1234, OutputName)

c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0001_subtype_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0002_subtype_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0003_subtype_dataTable.txt') %>%
  mutate(trial_type = '3c')
c4 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0004_subtype_dataTable.txt') %>%
  mutate(trial_type = 'catch')

c12 <- full_join(c1,c2)
c1234 <- full_join(c12,c3) %>%
  full_join(., c4) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype, TimepointNr, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_subtype_dataTable.txt'
write_tsv(c1234, OutputName)

c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0001_severity_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0002_severity_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0003_severity_dataTable.txt') %>%
  mutate(trial_type = '3c')
c4 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0004_severity_dataTable.txt') %>%
  mutate(trial_type = 'catch')

c12 <- full_join(c1,c2)
c1234 <- full_join(c12,c3) %>%
  full_join(., c4) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_severity_dataTable.txt'
write_tsv(c1234, OutputName)
