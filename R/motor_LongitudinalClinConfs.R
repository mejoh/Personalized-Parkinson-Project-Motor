library(tidyverse)
library(lubridate)

##### Clinical #####
# Load data
dfClin <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-28.csv', show_col_types = FALSE) %>%
  filter(ParticipantType=='PD_POM' | ParticipantType=='HC_PIT',
         TimepointNr==0 | TimepointNr==2) %>%
        mutate(ClinScore = Up3OfBradySum)

# Define misdiagnoses
diagnosis <- dfClin %>% 
        filter(ParticipantType=='PD_POM') %>% 
        select(pseudonym, TimepointNr, DiagParkCertain, DiagParkPersist, DiagParkReplace)
baseline_exclusion <- diagnosis %>%
  filter(TimepointNr==0, (DiagParkCertain == 'NeitherDisease' | DiagParkCertain == 'DoubtAboutParkinsonism' | DiagParkCertain == 'Parkinsonism')) %>% 
  select(pseudonym)
visit2_exclusion <- diagnosis %>%
  filter(TimepointNr==2, (DiagParkPersist == 2)) %>% 
  select(pseudonym)
diag_exclusions <- full_join(baseline_exclusion, visit2_exclusion, by='pseudonym') %>% 
  unique()
dfClin <- dfClin %>%
  mutate(Misdiagnosis = if_else(pseudonym %in% diag_exclusions$pseudonym,1,0))

# Extract data of interest
vars.prog <- c('pseudonym', 'TimepointNr', 'ClinScore')
dfClin.prog <- dfClin %>%
  select(all_of(vars.prog))
# Extract confounders
vars.conf <- c('pseudonym', 'ParticipantType', 'Age', 'Gender', 'Misdiagnosis')
dfClin.conf <- dfClin %>%
  filter(TimepointNr==0) %>%
  select(all_of(vars.conf))
# Join
dfClin.prog <- left_join(dfClin.prog, dfClin.conf, by=c('pseudonym')) %>%
  mutate(TimepointNr=if_else(TimepointNr==0,'T0','T2'),
         Gender = if_else(Gender=='Male',1,0))

# Save long format
dfClin.prog %>% 
        filter(TimepointNr=='T0') %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-clin_ses-baseline_groups-all_', today(), '.csv',sep=''))

dfClin.prog %>% 
        filter(ParticipantType=='PD_POM') %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-clin_ses-longitudinal_groups-pd_', today(), '.csv',sep=''))

# Pivot wider
dfClin.wide <- dfClin.prog %>%
        filter(ParticipantType=='PD_POM') %>%
  pivot_wider(id_cols = all_of(vars.conf),
              names_from = TimepointNr,
              values_from = ClinScore)

# Calculate raw change score
dfClin.wide <- dfClin.wide %>%
  mutate(ClinScore.BA = T0,
         ClinScore.RawChange = T2-T0) %>%
  na.omit() %>%
  select(all_of(vars.conf),starts_with('ClinScore'))

# Save wide format
dfClin.wide %>% 
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-clin_ses-diff_groups-pd_', today(), '.csv',sep=''))

##### Task #####
dfTask <- read_csv('P:/3022026.01/pep/bids/derivatives/manipulated_merged_motor_task_mri_2022-04-22.csv', show_col_types = FALSE) %>%
  select(pseudonym, Timepoint, trial_type, response_time, trial_number,
         event_type, correct_response, block, RespondingHand, Group, Percentage.Correct,
         Percentage.Correct.BelowCutoff, Button.Press.SwitchRatio, Button.Press.CoV,
         Button.Press.RepetitionRatio, Button.Press.AdjacentRatio) %>%
  rename(ParticipantType = Group) %>%
  mutate(TimepointNr = if_else(str_detect(Timepoint, 'Visit1'), 0, 2)) %>%
  relocate(pseudonym, TimepointNr, ParticipantType) %>%
  select(-Timepoint) %>%
  filter(ParticipantType=='PD_POM' | ParticipantType=='HC_PIT')

dfTask <- dfTask %>%
  filter(event_type == 'response') %>%
  filter(trial_type != 'Catch') %>%
  filter(response_time > 0.3) %>%
  filter(correct_response=='Hit') %>%
  select(pseudonym, TimepointNr, trial_number, trial_type, response_time) %>% 
  group_by(pseudonym, TimepointNr, trial_type) %>%
  summarise(response_time = median(response_time,na.rm=TRUE)) %>%
  mutate(response_time=round(response_time*1000)) %>%
  ungroup()

# Join
dfTask.prog <- left_join(dfTask, dfClin.conf, by='pseudonym') %>%
  mutate(TimepointNr=if_else(TimepointNr==0,'T0','T2'),
         Gender = if_else(Gender=='Male',1,0))

# Save long format
dfTask.prog %>% 
        filter(TimepointNr=='T0') %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-task_ses-baseline_groups-all_', today(), '.csv',sep=''))

dfTask.prog %>% 
        filter(ParticipantType=='PD_POM') %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-task_ses-longitudinal_groups-pd_', today(), '.csv',sep=''))

# Pivot wider
dfTask.wide <- dfTask.prog %>%
  pivot_wider(id_cols = all_of(vars.conf),
              names_from = c(TimepointNr, trial_type),
              values_from = response_time)

# Calculate raw change score
dfTask.wide <- dfTask.wide %>%
  mutate(T0_Motor = (T0_1choice+T0_2choice+T0_3choice)/3,
         T2_Motor = (T2_1choice+T2_2choice+T2_3choice)/3,
         T0_Select2 = T0_2choice-T0_1choice,
         T0_Select3 = T0_3choice-T0_1choice,
         T2_Select2 = T2_2choice-T2_1choice,
         T2_Select3 = T2_3choice-T2_1choice,
         RTMotor.RawChange = T2_Motor-T0_Motor,
         RTSelect2.RawChange = T2_Select2-T0_Select2,
         RTSelect3.RawChange = T2_Select3-T0_Select3,
         across(where(is.numeric), round)) %>%
  na.omit() %>%
  select(all_of(vars.conf),starts_with('RT'))

# Save data
dfTask.wide %>% 
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-task_ses-diff_groups-all_', today(), '.csv',sep=''))

dfTask.wide %>% 
        filter(ParticipantType == 'PD_POM') %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-task_ses-diff_groups-pd_', today(), '.csv',sep=''))

##### Task + Clin #####

dfTaskClin.wide <- dfTask.wide %>% 
        filter(ParticipantType == 'PD_POM') %>% 
        na.omit() %>%
        left_join(., dfClin.wide, by=c('pseudonym','ParticipantType', 'Age', 'Gender', 'Misdiagnosis'))

dfTaskClin.wide %>%
        write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-taskclin_ses-diff_groups-pd_', today(), '.csv',sep=''))


