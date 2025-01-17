library(tidyverse)
library(lubridate)
library(mice)
library(miceadds)

##### Clinical #####
# Load data
dfClin <- read_csv('P:/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2024-07-17.csv', show_col_types = FALSE) %>%
 filter(ParticipantType=='PD_POM' | ParticipantType=='HC_PIT',
        TimepointNr==0 | TimepointNr==2)

# Add reserve proxies
SmokingHistory <- dfClin %>% select(pseudonym,ParticipantType,TimepointNr,
                  starts_with('Smoke')) %>%
        mutate(SmokingHistory = NA,
               SmokingHistory = if_else(SmokeEver==0,0,SmokingHistory),
               SmokingHistory = if_else(SmokeEver==1,1,SmokingHistory),
               SmokingHistory = if_else(SmokeCurrent==1,1,SmokingHistory)) %>%
        select(-starts_with('Smoke')) %>%
        group_by(pseudonym) %>%
        summarise(SmokingHistory=mean(SmokingHistory,na.rm=T))
dfClin <- dfClin %>% 
        left_join(., SmokingHistory, by = 'pseudonym')
dfClin <- dfClin %>%
        mutate(Length = Length/100,
               BMI = Weight / (Length^2),
               Gender = if_else(Gender=='Female',-1,1))

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
ClinScore <- c('Up3OfBradySum','Up3OnBradySum','z_MoCA__total')
vars.prog <- c('pseudonym', 'TimepointNr', ClinScore)
dfClin.prog <- dfClin %>%
 select(all_of(vars.prog))
# Extract confounders
# vars.conf <- c('pseudonym', 'ParticipantType', 'Age', 'Gender', 'NpsEducYears', 'Misdiagnosis', 'PrefHand',
#                'Subtype_DiagEx3_DisDurSplit', 'PASE', 'SmokingHistory', 'BMI', 'Up1Total', 'RBDSQSum', 'BDI2Sum')
vars.conf <- c('pseudonym', 'ParticipantType', 'Age', 'Gender', 'NpsEducYears', 'Misdiagnosis', 'PrefHand', 'YearsSinceDiag',
               'Subtype_DiagEx3_DisDurSplit')
dfClin.conf <- dfClin %>%
        filter(TimepointNr==0) %>%
        select(all_of(vars.conf)) %>%
        mutate(Subtype_DiagEx3_DisDurSplit = if_else(ParticipantType=='HC_PIT','0_Healthy',Subtype_DiagEx3_DisDurSplit),
               Subtype_DiagEx3_DisDurSplit = if_else(is.na(Subtype_DiagEx3_DisDurSplit),'4_Undefined',Subtype_DiagEx3_DisDurSplit))
# Join
dfClin.prog <- left_join(dfClin.prog, dfClin.conf, by=c('pseudonym')) %>%
 mutate(TimepointNr=if_else(TimepointNr==0,'T0','T2'))
# Widen
dfClin.wide <- dfClin.prog %>%
 pivot_wider(id_cols = all_of(vars.conf),
             names_from = TimepointNr,
             values_from = all_of(ClinScore))

##### Multiple imputation of missing ClinScore #####
# Bradykinesia and MoCA
dfClin.wide.imp1 <- dfClin.wide %>%
    filter(ParticipantType=='PD_POM') %>%
    select(pseudonym, ParticipantType, Age, Gender, NpsEducYears, YearsSinceDiag,
           Up3OfBradySum_T0, Up3OfBradySum_T2, Up3OnBradySum_T0, Up3OnBradySum_T2, 
           z_MoCA__total_T0, z_MoCA__total_T2) %>%
    mutate(ParticipantType=factor(ParticipantType),
           Gender = factor(Gender))
md.pattern(dfClin.wide.imp1)
isna <- apply(dfClin.wide.imp1, 2, is.na) %>% colSums()
cat(paste('\n ', 'Percentage missing values\n', sep=''))
missing_perc <- round(isna/nrow(dfClin.wide.imp1), digits = 3)*100
print(missing_perc)

# # Bradykinesia
# imputed <- dfClin.wide.imp1 %>%
#         select(pseudonym, ParticipantType, Age, Gender, NpsEducYears, 
#                Up3OfBradySum_T0, Up3OfBradySum_T2, Up3OnBradySum_T0, Up3OnBradySum_T2) %>%
#         mice(m=round(5*missing_perc[names(missing_perc)=='Up3OnBradySum_T2']),
#              maxit = 10,
#              method='pmm',
#              seed=157,
#              print=FALSE)
# summary(imputed)
# imputed <- imputed %>%
#         complete() %>%
#         tibble() %>%
#         select(pseudonym, ParticipantType, Up3OfBradySum_T0, Up3OfBradySum_T2, Up3OnBradySum_T0, Up3OnBradySum_T2) %>%
#         rename(Up3OfBradySum_T0_imp=Up3OfBradySum_T0, 
#                Up3OfBradySum_T2_imp=Up3OfBradySum_T2, 
#                Up3OnBradySum_T0_imp=Up3OnBradySum_T0, 
#                Up3OnBradySum_T2_imp=Up3OnBradySum_T2)
# dfClin.wide <- left_join(dfClin.wide, imputed, by=c('pseudonym','ParticipantType'))
# # MoCA
# imputed <- dfClin.wide.imp1 %>%
#         select(pseudonym, ParticipantType, Age, Gender, NpsEducYears, z_MoCA__total_T0, z_MoCA__total_T2) %>%
#         mice(m=round(5*missing_perc[names(missing_perc)=='z_MoCA__total_T2']),
#              maxit = 10,
#              method='pmm',
#              seed=157,
#              print=FALSE)
# summary(imputed)
# imputed <- imputed %>%
#         complete() %>%
#         tibble() %>%
#         select(pseudonym, ParticipantType, z_MoCA__total_T0, z_MoCA__total_T2) %>%
#         rename(z_MoCA__total_T0_imp=z_MoCA__total_T0, 
#                z_MoCA__total_T2_imp=z_MoCA__total_T2)
# dfClin.wide <- left_join(dfClin.wide, imputed, by=c('pseudonym','ParticipantType'))
# Everything together
imputed <- dfClin.wide.imp1 %>%
        mice(m=round(5*missing_perc[names(missing_perc)=='Up3OnBradySum_T2']),
             maxit = 10,
             method='pmm',
             seed=157,
             print=FALSE)
summary(imputed)
imputed <- imputed %>%
        complete() %>%
        tibble() %>%
        select(pseudonym, ParticipantType, 
               Up3OfBradySum_T0, Up3OfBradySum_T2, 
               Up3OnBradySum_T0, Up3OnBradySum_T2,
               z_MoCA__total_T0, z_MoCA__total_T2) %>%
        rename(Up3OfBradySum_T0_imp=Up3OfBradySum_T0, 
               Up3OfBradySum_T2_imp=Up3OfBradySum_T2, 
               Up3OnBradySum_T0_imp=Up3OnBradySum_T0, 
               Up3OnBradySum_T2_imp=Up3OnBradySum_T2,
               z_MoCA__total_T0_imp=z_MoCA__total_T0, 
               z_MoCA__total_T2_imp=z_MoCA__total_T2)
dfClin.wide <- left_join(dfClin.wide, imputed, by=c('pseudonym','ParticipantType'))

# Calculate raw change score
dfClin.wide <- dfClin.wide %>%
 mutate(Up3OfBradySum_T2sub0 = Up3OfBradySum_T2-Up3OfBradySum_T0,
        Up3OnBradySum_T2sub0 = Up3OnBradySum_T2-Up3OnBradySum_T0,
        z_MoCASum_T2sub0 = z_MoCA__total_T2-z_MoCA__total_T0,
        
        Up3OfBradySum_T2sub0_imp = Up3OfBradySum_T2_imp-Up3OfBradySum_T0_imp,
        Up3OnBradySum_T2sub0_imp = Up3OnBradySum_T2_imp-Up3OnBradySum_T0_imp,
        z_MoCASum_T2sub0_imp = z_MoCA__total_T2_imp-z_MoCA__total_T0_imp) %>%
 select(all_of(vars.conf),ends_with(c('T0','T2','T2sub0','_imp')))

##### Task #####
# Load data
dfTask <- read_csv('P:/3022026.01/pep/bids/derivatives/manipulated_merged_motor_task_mri_2023-09-15.csv', show_col_types = FALSE) %>%
 select(pseudonym, Timepoint, trial_type, response_time, trial_number,
        event_type, correct_response, block, RespondingHand, Group, Percentage.Correct,
        Percentage.Correct.BelowCutoff, Button.Press.SwitchRatio, Button.Press.CoV,
        Button.Press.RepetitionRatio, Button.Press.AdjacentRatio) %>%
 rename(ParticipantType = Group) %>%
 mutate(TimepointNr = if_else(str_detect(Timepoint, 'Visit1'), 'T0', 'T2')) %>%
 select(-Timepoint) %>%
 relocate(pseudonym, TimepointNr, ParticipantType) %>%
 filter(ParticipantType=='PD_POM' | ParticipantType=='HC_PIT')
# Aggregate
dfTask <- dfTask %>%
 filter(event_type == 'response') %>%
 filter(trial_type != 'Catch') %>%
 filter(response_time > 0.3) %>%
 filter(correct_response=='Hit') %>%
 select(pseudonym, RespondingHand, TimepointNr, trial_type, response_time) %>% 
 group_by(pseudonym, RespondingHand, TimepointNr, trial_type) %>%
 summarise(response_time = median(response_time,na.rm=TRUE)) %>%
 mutate(response_time=round(response_time*1000)) %>%
 ungroup()
# Extract responding hand
dfTask.conf <- dfTask %>%
 select(pseudonym, TimepointNr, RespondingHand) %>%
 group_by(pseudonym, TimepointNr) %>%
 summarise(TimepointNr = first(TimepointNr),
           RespondingHand=first(RespondingHand)) %>%
 ungroup() %>%
 pivot_wider(id_cols = 'pseudonym',
             names_from = TimepointNr,
             values_from = RespondingHand) %>%
 rename(RespondingHand_T0 = T0,
        RespondingHand_T2 = T2)
dfTask <- dfTask %>%
 select(-RespondingHand) %>%
 left_join(., dfTask.conf, by = 'pseudonym')
# Widen
dfTask.wide <- dfTask %>%
 pivot_wider(id_cols = c('pseudonym','RespondingHand_T0', 'RespondingHand_T2'),
             names_from = c(TimepointNr, trial_type),
             values_from = response_time) %>%
        mutate(RespondingHand_Match = if_else(RespondingHand_T0 == RespondingHand_T2, 1, 0))
# Calculate raw change score
dfTask.wide <- dfTask.wide %>%
 mutate(Motor_T0 = (T0_NChoice1+T0_NChoice2+T0_NChoice3)/3,
        Motor_T2 = (T2_NChoice1+T2_NChoice2+T2_NChoice3)/3,
        Motor_T2sub0 = Motor_T2-Motor_T0,
        Select_T0 = (T0_NChoice2+T0_NChoice3)/2 - T0_NChoice1,
        Select_T2 = (T2_NChoice2+T2_NChoice3)/2 - T2_NChoice1,
        Select_T2sub0 = Select_T2-Select_T0,
        Select2_T0 = T0_NChoice2-T0_NChoice1,
        Select2_T2 = T2_NChoice2-T2_NChoice1,
        Select2_T2sub0 = Select2_T2-Select2_T0,
        Select3_T0 = T0_NChoice3-T0_NChoice1,
        Select3_T2 = T2_NChoice3-T2_NChoice1,
        Select3_T2sub0 = Select3_T2-Select3_T0,
        across(where(is.numeric), round)) %>%
 select(pseudonym, starts_with('RespondingHand'), starts_with('Motor'), starts_with('Select'))

##### Task + Clin #####
dfTaskClin.wide <- dfTask.wide %>% 
 left_join(., dfClin.wide, by = c('pseudonym'))

dfTaskClin.wide <- dfTaskClin.wide %>%
 mutate(ParticipantType = if_else(ParticipantType=='PD_POM',1,-1),
        RespHandIsDominant_T0 = if_else(RespondingHand_T0 == PrefHand | PrefHand == 'NoPref',1,-1),
        RespHandIsDominant_T2 = if_else(RespondingHand_T2 == PrefHand | PrefHand == 'NoPref',1,-1),
        across(where(is.numeric), \(x) round(x, digits = 5)))

dfTaskClin.wide <- dfTaskClin.wide %>%
 relocate(pseudonym, ParticipantType, Subtype_DiagEx3_DisDurSplit, Age, Gender, 
          NpsEducYears, Misdiagnosis, YearsSinceDiag, PrefHand,
          RespondingHand_T0, RespondingHand_T2, RespondingHand_Match, 
          RespHandIsDominant_T0, RespHandIsDominant_T2,
          starts_with(c('Up3Of','Up3On','z_MoCA','Motor','Select')))

dfTaskClin.wide %>%
 write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_', today(), '.csv',sep=''))


