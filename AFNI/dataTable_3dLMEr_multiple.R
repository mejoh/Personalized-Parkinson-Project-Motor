source("M:/scripts/Personalized-Parkinson-Project-Motor/AFNI/dataTable_3dLMEr_single.R")

library(tidyverse)
library(tictoc)

# Write tables for summary contrasts

dataTable_3dLMEr_single(con = 'con_0010.nii')
dataTable_3dLMEr_single(con = 'con_0012.nii')
dataTable_3dLMEr_single(con = 'con_0013.nii')

# Write tables for choice contrasts
dataTable_3dLMEr_single(con = 'con_0001.nii')
dataTable_3dLMEr_single(con = 'con_0002.nii')
dataTable_3dLMEr_single(con = 'con_0003.nii')
dataTable_3dLMEr_single(con = 'con_0005.nii')

# Linear time

c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease-poly1_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease-poly1_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease-poly1_dataTable.txt') %>%
  mutate(trial_type = '3c')
c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease-poly1_dataTable.txt') %>%
  mutate(trial_type = '23c')

c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Group, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly1_dataTable.txt'
write_tsv(c123, OutputName)

c123 <- full_join(c1,c2n3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Group, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly1_dataTable2.txt'
write_tsv(c123, OutputName)

# # Cubic age
# 
# c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, Age, Age.poly1, Age.poly2, trial_type) %>% relocate(Subj, Group, Age, Age.poly1, Age.poly2, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly2_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# c123 <- full_join(c1,c2n3) %>%
#   arrange(Subj, Age, Age.poly1, Age.poly2, trial_type) %>% relocate(Subj, Group, Age, Age.poly1, Age.poly2, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly2_dataTable2.txt'
# write_tsv(c123, OutputName)
# 
# # Cubic and quadratic age
# 
# c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, Age, Age.poly1, Age.poly2, Age.poly3, trial_type) %>% relocate(Subj, Group, Age, Age.poly1, Age.poly2, Age.poly3, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly3_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# c123 <- full_join(c1,c2n3) %>%
#   arrange(Subj, Age, Age.poly1, Age.poly2, Age.poly3, trial_type) %>% relocate(Subj, Group, Age, Age.poly1, Age.poly2, Age.poly3, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly3_dataTable2.txt'
# write_tsv(c123, OutputName)

# c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0001_subtype_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0002_subtype_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0003_subtype_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c4 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0004_subtype_dataTable.txt') %>%
#   mutate(trial_type = 'catch')
# 
# c12 <- full_join(c1,c2)
# c1234 <- full_join(c12,c3) %>%
#   full_join(., c4) %>%
#   arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype, TimepointNr, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_subtype_dataTable.txt'
# write_tsv(c1234, OutputName)

# Linear term for ClinScore
c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity-poly1_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity-poly1_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity-poly1_dataTable.txt') %>%
  mutate(trial_type = '3c')
c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity-poly1_dataTable.txt') %>%
  mutate(trial_type = '23c')

c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, TimepointNr, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly1_dataTable.txt'
write_tsv(c123, OutputName)

c123 <- full_join(c1,c2n3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, TimepointNr, trial_type)
OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly1_dataTable2.txt'
write_tsv(c123, OutputName)

# # Quadratic term for ClinScore
# c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, trial_type) %>% relocate(Subj, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly2_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# # Cubic and quadratic term for ClinScore
# c1 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, trial_type) %>% relocate(Subj, trial_type)
# OutputName <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly3_dataTable.txt'
# write_tsv(c123, OutputName)
