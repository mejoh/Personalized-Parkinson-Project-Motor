source("/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/AFNI/dataTable_3dLMEr_single.R")

library(tidyverse)

# Write tables for summary contrasts
dataTable_3dLMEr_single(con = 'con_0008.nii')
dataTable_3dLMEr_single(con = 'con_0010.nii')
dataTable_3dLMEr_single(con = 'con_0012.nii')
dataTable_3dLMEr_single(con = 'con_0013.nii')

# Write tables for choice contrasts
dataTable_3dLMEr_single(con = 'con_0001.nii')
dataTable_3dLMEr_single(con = 'con_0002.nii')
dataTable_3dLMEr_single(con = 'con_0003.nii')
dataTable_3dLMEr_single(con = 'con_0005.nii')

# Assemble combined tables for group comparisons
c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease_dataTable.txt') %>%
  mutate(trial_type = '3c')
c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease_dataTable.txt') %>%
  mutate(trial_type = '23c')

# Patients vs Controls
c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Group, trial_type)
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_dataTable.txt'
write_tsv(c123, OutputName)

c123.c <- full_join(c1,c2n3) %>%
    arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Group, trial_type)
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_dataTable2.txt'
write_tsv(c123.c, OutputName)

# Controls vs Subtypes
tmp <- c123 %>%
    filter(Subtype1 == '0_Healthy' | Subtype1 == '1_Mild-Motor') %>%
    mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_HCvsMMP_dataTable.txt'
write_tsv(tmp, OutputName)
tmp <- c123 %>%
    filter(Subtype1 == '0_Healthy' | Subtype1 == '2_Intermediate') %>%
    mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_HCvsIM_dataTable.txt'
write_tsv(tmp, OutputName)
tmp <- c123 %>%
    filter(Subtype1 == '0_Healthy' | Subtype1 == '3_Diffuse-Malignant') %>%
    mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_HCvsDM_dataTable.txt'
write_tsv(tmp, OutputName)

# Subtypes vs Subtypes
  #MMPvsIM
c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease_MMPvsIM_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease_MMPvsIM_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease_MMPvsIM_dataTable.txt') %>%
  mutate(trial_type = '3c')
c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype1, TimepointNr, trial_type)
tmp <- c123
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_MMPvsIM_dataTable.txt'
write_tsv(tmp, OutputName)
  #MMPvsDM
c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease_MMPvsDM_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease_MMPvsDM_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease_MMPvsDM_dataTable.txt') %>%
  mutate(trial_type = '3c')
c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype1, TimepointNr, trial_type)
tmp <- c123
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_MMPvsDM_dataTable.txt'
write_tsv(tmp, OutputName)
  #IMvsDM
c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease_IMvsDM_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease_IMvsDM_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease_IMvsDM_dataTable.txt') %>%
  mutate(trial_type = '3c')
c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype1, TimepointNr, trial_type)
tmp <- c123
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease_IMvsDM_dataTable.txt'
write_tsv(tmp, OutputName)

# Assemble combined tables for associations with clinical score
c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity_dataTable.txt') %>%
  mutate(trial_type = '1c')
c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity_dataTable.txt') %>%
  mutate(trial_type = '2c')
c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity_dataTable.txt') %>%
  mutate(trial_type = '3c')
c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity_dataTable.txt') %>%
  mutate(trial_type = '23c')

c12 <- full_join(c1,c2)
c123 <- full_join(c12,c3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, TimepointNr, trial_type)
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity_dataTable.txt'
write_tsv(c123, OutputName)

c123 <- full_join(c1,c2n3) %>%
  arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, TimepointNr, trial_type)
OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity_dataTable2.txt'
write_tsv(c123, OutputName)






# # Cubic age
# 
# c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease-poly2_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, Age, Age, Age.poly2, trial_type) %>% relocate(Subj, Group, Age, Age, Age.poly2, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly2_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# c123 <- full_join(c1,c2n3) %>%
#   arrange(Subj, Age, Age, Age.poly2, trial_type) %>% relocate(Subj, Group, Age, Age, Age.poly2, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly2_dataTable2.txt'
# write_tsv(c123, OutputName)
# 
# # Cubic and quadratic age
# 
# c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_disease-poly3_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, Age, Age, Age.poly2, Age.poly3, trial_type) %>% relocate(Subj, Group, Age, Age, Age.poly2, Age.poly3, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly3_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# c123 <- full_join(c1,c2n3) %>%
#   arrange(Subj, Age, Age, Age.poly2, Age.poly3, trial_type) %>% relocate(Subj, Group, Age, Age, Age.poly2, Age.poly3, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_disease-poly3_dataTable2.txt'
# write_tsv(c123, OutputName)

# c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0001_subtype_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0002_subtype_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0003_subtype_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c4 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_0004_subtype_dataTable.txt') %>%
#   mutate(trial_type = 'catch')
# 
# c12 <- full_join(c1,c2)
# c1234 <- full_join(c12,c3) %>%
#   full_join(., c4) %>%
#   arrange(Subj, TimepointNr, trial_type) %>% relocate(Subj, Subtype, TimepointNr, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_subtype_dataTable.txt'
# write_tsv(c1234, OutputName)

# # Quadratic term for ClinScore
# c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity-poly2_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, trial_type) %>% relocate(Subj, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly2_dataTable.txt'
# write_tsv(c123, OutputName)
# 
# # Cubic and quadratic term for ClinScore
# c1 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0001_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '1c')
# c2 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0002_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '2c')
# c3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0003_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '3c')
# c2n3 <- read_tsv('/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_0005_severity-poly3_dataTable.txt') %>%
#   mutate(trial_type = '23c')
# 
# c12 <- full_join(c1,c2)
# c123 <- full_join(c12,c3) %>%
#   arrange(Subj, trial_type) %>% relocate(Subj, trial_type)
# OutputName <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI/con_combined_severity-poly3_dataTable.txt'
# write_tsv(c123, OutputName)
