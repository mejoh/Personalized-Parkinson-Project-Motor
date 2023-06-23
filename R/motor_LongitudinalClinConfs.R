library(tidyverse)
library(lubridate)

##### Clinical #####
# Load data
dfClin <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-28.csv', show_col_types = FALSE) %>%
 filter(ParticipantType=='PD_POM' | ParticipantType=='HC_PIT',
        TimepointNr==0 | TimepointNr==2)

# Add scores and variables
source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_cognitive_composite.R")
dfClin <- dfClin %>%
        left_join(., compute_cognitive_composite(dfClin))
source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_pase.R")
dfClin <- dfClin %>%
        left_join(., compute_pase(dfClin))
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
               BMI = Weight / (Length*Length),
               Length = Length * 100)
r <- dfClin %>%
        filter(ParticipantType=='PD_POM',
               TimepointNr==0) %>%
        select(pseudonym, ParticipantType, TimepointNr, CognitiveComposite, PASE)

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
ClinScore <- c('Up3OfBradySum','Up3OnBradySum','Up3OfTotal','Up3OnTotal','MoCASum','CognitiveComposite', 'CognitiveComposite_raw')
vars.prog <- c('pseudonym', 'TimepointNr', ClinScore)
dfClin.prog <- dfClin %>%
 select(all_of(vars.prog))
# Extract confounders
vars.conf <- c('pseudonym', 'ParticipantType', 'Age', 'Gender', 'NpsEducYears', 'Misdiagnosis', 'PrefHand',
               'Subtype_DiagEx3_DisDurSplit', 'PASE', 'SmokingHistory', 'BMI', 'Up1Total', 'RBDSQSum', 'BDI2Sum')
dfClin.conf <- dfClin %>%
        filter(TimepointNr==0) %>%
        select(all_of(vars.conf)) %>%
        mutate(Gender = if_else(Gender=='Male',1,0),
               Subtype_DiagEx3_DisDurSplit = if_else(ParticipantType=='HC_PIT','0_HealthyControl',
                                                     Subtype_DiagEx3_DisDurSplit),
               Subtype_DiagEx3_DisDurSplit = if_else(is.na(Subtype_DiagEx3_DisDurSplit),'4_Undefined',
                                                     Subtype_DiagEx3_DisDurSplit))
# Join
dfClin.prog <- left_join(dfClin.prog, dfClin.conf, by=c('pseudonym')) %>%
 mutate(TimepointNr=if_else(TimepointNr==0,'T0','T2'))
# Widen
dfClin.wide <- dfClin.prog %>%
 pivot_wider(id_cols = all_of(vars.conf),
             names_from = TimepointNr,
             values_from = all_of(ClinScore))

# Adjust raw cognitive composite for age, gender, and education to approximate
# Roy's z-scored version.
# NOTE: Testing has revealed that this score yields exactly the same correlations
# with brain activity as the unadjusted one when age, gender, and education
# are included as covars
# dfClin.tmp.t0 <- dfClin.wide %>%
#         select(pseudonym,ParticipantType,Age,Gender,NpsEducYears, 
#                CognitiveComposite_raw_T0) %>%
#         na.omit() %>%
#         mutate(Age = Age-mean(Age),
#                NpsEducYears = NpsEducYears-mean(NpsEducYears))
# dfClin.tmp.t2 <- dfClin.wide %>%
#         select(pseudonym,ParticipantType,Age,Gender,NpsEducYears, 
#                CognitiveComposite_raw_T2) %>%
#         na.omit() %>%
#         mutate(Age = Age-mean(Age),
#                NpsEducYears = NpsEducYears-mean(NpsEducYears))
# 
# m.T0 <- lm(CognitiveComposite_raw_T0 ~ Age + Gender + NpsEducYears, data = dfClin.tmp.t0)
# m.T2 <- lm(CognitiveComposite_raw_T2 ~ Age + Gender + NpsEducYears, data = dfClin.tmp.t2)
# resid.T0 <- residuals(m.T0)
# resid.T2 <- residuals(m.T2)
# dfClin.tmp.t0 <- dfClin.tmp.t0 %>%
#         bind_cols(., CognitiveComposite_raw_adj_T0 = resid.T0) %>%
#         select(-c(Age,Gender,NpsEducYears,CognitiveComposite_raw_T0))
# dfClin.tmp.t2 <- dfClin.tmp.t2 %>%
#         bind_cols(., CognitiveComposite_raw_adj_T2 = resid.T2) %>%
#         select(-c(Age,Gender,NpsEducYears,CognitiveComposite_raw_T2))
# dfClin.wide <- dfClin.wide %>%
#         left_join(., dfClin.tmp.t0, by = c('pseudonym','ParticipantType')) %>%
#         left_join(., dfClin.tmp.t2, by = c('pseudonym','ParticipantType'))
        

# Calculate raw change score
dfClin.wide <- dfClin.wide %>%
 mutate(Up3OfBradySum_RawChange = Up3OfBradySum_T2-Up3OfBradySum_T0,
        Up3OnBradySum_RawChange = Up3OnBradySum_T2-Up3OnBradySum_T0,
        Up3OfTotal_RawChange = Up3OfTotal_T2-Up3OfTotal_T0,
        Up3OnTotal_RawChange = Up3OnTotal_T2-Up3OnTotal_T0,
        MoCASum_RawChange = MoCASum_T2-MoCASum_T0,
        CognitiveComposite_RawChange = CognitiveComposite_T2-CognitiveComposite_T0,
        CognitiveComposite_raw_RawChange = CognitiveComposite_raw_T2-CognitiveComposite_raw_T0) %>%
 select(all_of(vars.conf),ends_with(c('T0','T2','RawChange')))

##### Task #####
# Load data
dfTask <- read_csv('P:/3022026.01/pep/bids/derivatives/manipulated_merged_motor_task_mri_2022-04-22.csv', show_col_types = FALSE) %>%
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
 select(pseudonym, RespondingHand, TimepointNr, trial_number, trial_type, response_time) %>% 
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
             values_from = response_time)
# Calculate raw change score
dfTask.wide <- dfTask.wide %>%
 mutate(Motor_T0 = (T0_1choice+T0_2choice+T0_3choice)/3,
        Motor_T2 = (T2_1choice+T2_2choice+T2_3choice)/3,
        Select2_T0 = T0_2choice-T0_1choice,
        Select3_T0 = T0_3choice-T0_1choice,
        Select2_T2 = T2_2choice-T2_1choice,
        Select3_T2 = T2_3choice-T2_1choice,
        Motor_RawChange = Motor_T2-Motor_T0,
        Select2_RawChange = Select2_T2-Select2_T0,
        Select3_RawChange = Select3_T2-Select3_T0,
        across(where(is.numeric), round)) %>%
 select(pseudonym, starts_with('RespondingHand'), starts_with('Motor'), starts_with('Select'))

##### Task + Clin #####
dfTaskClin.wide <- dfTask.wide %>% 
 left_join(., dfClin.wide, by = c('pseudonym'))

dfTaskClin.wide <- dfTaskClin.wide %>%
 mutate(RespHandIsDominant_T0 = if_else(RespondingHand_T0 == PrefHand | PrefHand == 'NoPref',1,0),
        RespHandIsDominant_T2 = if_else(RespondingHand_T2 == PrefHand | PrefHand == 'NoPref',1,0),
        across(where(is.numeric), \(x) round(x, digits = 5)))

dfTaskClin.wide <- dfTaskClin.wide %>%
 relocate(pseudonym, ParticipantType, Subtype_DiagEx3_DisDurSplit, Age, Gender, NpsEducYears, Misdiagnosis, PrefHand,
          PASE, SmokingHistory, BMI, Up1Total, RBDSQSum, BDI2Sum,
          RespondingHand_T0, RespondingHand_T2, RespHandIsDominant_T0, RespHandIsDominant_T2,
          starts_with(c('Up3OfBrady','Up3OfTotal','Up3OnBrady','Up3OnTotal',
                        'MoCASum','CognitiveComposite','Motor','Select')))

dfTaskClin.wide %>%
 write_csv(., paste('P:/3024006.02/Data/matlab/fmri-confs-taskclin_ses-all_groups-all_', today(), '.csv',sep=''))


