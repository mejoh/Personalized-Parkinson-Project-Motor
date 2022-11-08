dataTable_3dLMEr_single <- function(con='con_0010.nii', outputDir='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal'){
  
  # con <- 'con_0010.nii'
  # outputDir <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal'
  
  library(tidyverse)
  library(readxl)
  library(lme4)
  library(lmerTest)
  library(emmeans)
  outputName=paste(outputDir, '/', str_replace(con, '.nii', '_'), 'dataTable.txt', sep='')
  
  ##### Load subjects with 1st-level results #####
  dAna <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem'
  Subs <- dir(dAna, pattern = 'sub-.*')
  
  ##### Load clinical data and select subtype variable #####
  # DiagEx1 = Baseline diagnosis - DiagEx2 = Follow-up diagnosis - DiagEx3 = Both
  dfClinVars <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-28.csv') %>%
    rename(Subtype = Subtype_DiagEx3_DisDurSplit)
  
  ##### Initialize data frame #####
  df.all <- tibble(Subj=character(), Visit=character(), Group=character(), TimepointNr=numeric(), WeeksToFollowUp=numeric(),
                   Subtype=character(), Age=numeric(), Sex=character(), Up3Total=numeric(),
                   BradyRigScore=numeric(), BradyScore=numeric(), RigScore=numeric(), MeanFD=numeric(),
                   PercTaskAccuracy=numeric(), InputFile=character())
  
  ##### Write one row for each subject's visits #####
  for(n in 1:length(Subs)){
    ###### Determine subject ID and available visits ######
    Subj <- Subs[n]
    Visits <- file.path(dAna, Subj) %>% dir(pattern = 'ses-')
    for(v in 1:length(Visits)){
      Visit <- Visits[v]
      ##### Select subject's data #####
      dat <- c()
      dat <- dfClinVars %>% filter(pseudonym==Subj)
      ##### Define group #####
      Group <- dat %>% filter(Timepoint==Visit) %>% select(ParticipantType) %>% as.character()
      ##### FIX: Missing Visit3 demographics are replaced with available Visit1 demographics #####
      if(Group == 'character(0)'){
        Group <- dat %>% filter(Timepoint==Visits[1]) %>% select(ParticipantType) %>% as.character()
      }
      ##### Define age and sex #####
      # (has to take values from PD_POM cohort, not from PD_PIT, unless POMVisit1 does not exist...)
      if(Group=='PD_POM' & sum(str_detect(dat$Timepoint, 'ses-POMVisit1')) > 0){
        tmp <- 'ses-POMVisit1'
      }else{
        tmp <- Visits[1]
      }
      Subtype <- dat %>% filter(Timepoint==tmp) %>% select(Subtype) %>% as.character()
      Age <- dat %>% filter(Timepoint==tmp) %>% select(Age) %>% as.numeric()
      Sex <- dat %>% filter(Timepoint==tmp) %>% select(Gender) %>% as.character()
      ##### Define timepoint (integer) #####
      TimepointNr <- dat %>% filter(Timepoint==Visit) %>% select(TimepointNr) %>% as.numeric()
      ##### FIX: Missing Visit3 demographics are filled in based on visit label #####
      if(Visit=='ses-POMVisit3' & is.na(TimepointNr)){
        TimepointNr = 2
      }
      ##### Define weeks to follow-up #####
      WeeksToFollowUp <- dat %>% filter(Timepoint==Visit) %>% select(WeeksToFollowUp) %>% as.numeric()
      ##### Define MDS-UPDRS III bradykinetic-rigid severity #####
      Up3Total <- dat %>% filter(Timepoint==Visit) %>% select(Up3OfTotal) %>% as.numeric()
      BradyScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OfBradySum) %>% as.numeric()
      RigScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OfRigiditySum) %>% as.numeric()
      BradyRigScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OfAppendicularSum) %>% as.numeric()
      ##### Define Mean FD (from fmriprep covars that were used at 1st-level) #####
      source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_mean_covar.R")
      MeanFD = compute_mean_covar(Subj, Visit, dAna='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem', measure='framewise_displacement')
      ##### Define accuarcy  #####
      source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_accuracy.R")
      PercTaskAccuracy = retrieve_accuracy(Subj, Visit)
      ##### Define input file #####
      # Regular cons
      # InputFile <- file.path(dAna, Subj, Visit, '1st_level') %>% dir(pattern = con, full.names = TRUE) %>%
      #   str_replace('P:/', '/project/')
      # Flipped cons (need to do something about these visit ids not corresponding between studies...)
      Visit_re <- Visit %>% str_replace('Visit3','Visit2') %>% str_replace('P[A-Z][A-Z]', '')
      dCon <- file.path(dAna, 'Group', sub('.nii','',con), Visit_re)
      ptn <- paste(Subj, Visit, sep='_')
      InputFile <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
        str_replace('P:/', '/project/')
      if(identical(InputFile, character(0))){
        InputFile <- NA
      }
      df.sub <- tibble(Subj=Subj, Visit=Visit, Group=Group, TimepointNr=TimepointNr, WeeksToFollowUp=WeeksToFollowUp,
                       Subtype=Subtype, Age=Age, Sex=Sex, BradyRigScore=BradyRigScore, MeanFD=MeanFD,
                       PercTaskAccuracy=PercTaskAccuracy, InputFile=InputFile)
      df.all <- bind_rows(df.all, df.sub)
    }
  }
  
  ##### Exclude patients with non-PD diagnosis at baseline or follow-up #####
  diagnosis <- dfClinVars %>% 
    filter(ParticipantType=='PD_POM') %>% 
    select(pseudonym, TimepointNr, DiagParkCertain, DiagParkPersist)
  # Diagnosis at baseline
  exclusion.diag_baseline <- diagnosis %>%
    filter(TimepointNr==0) %>%
    select(pseudonym, DiagParkCertain) %>%
    filter(DiagParkCertain != 'PD' & DiagParkCertain != 'DoubtAboutPD') %>%
    select(pseudonym)
  cat('Number of subjects with non-PD diagnosis at baseline: ', length(exclusion.diag_baseline$pseudonym), '\n')
  # Diagnosis at follow-up
  exclusion.diag_persistance <- diagnosis %>%
    filter(TimepointNr==2) %>%
    select(pseudonym, DiagParkPersist) %>%
    filter(DiagParkPersist == 2) %>%
    select(pseudonym)
  cat('Number of subjects converting to non-PD conversion at follow-up:', length(exclusion.diag_persistance$pseudonym), '\n')
  diag_exclusions <- full_join(exclusion.diag_baseline, exclusion.diag_persistance, by = 'pseudonym') %>% unique()
  df.all <- df.all %>%
    filter(!(Subj %in% diag_exclusions$pseudonym))
  
  ##### FIX: 3 patients with T2 fmri data does not appear to have castor data. These can be fixed easily #####
  df.all <- df.all %>%
    mutate(TimepointNr = if_else(is.na(TimepointNr), 2, TimepointNr))
  
  ##### FIX: TimepointNr and Subtype and exclude PD_PIT #####
  df.all <- df.all %>%
    mutate(TimepointNr = if_else(TimepointNr == 2, 1, TimepointNr),
           TimepointNr = factor(TimepointNr, labels = c('T0','T1'), levels = c(0,1)),
           Subtype = if_else(Group == 'HC_PIT', '0_Healthy', Subtype)) %>%
    filter(Group != 'PD_PIT')
  
  ##### Arrange ####
  df.all <- df.all %>%
    arrange(Group, Subtype, Subj, TimepointNr)
  
  ##### Check FD and exclude above threshold #####
  FDcutoff <- 0.8
  df.all %>%
    ggplot(aes(x=Group,y=MeanFD, fill=Visit)) +
    geom_boxplot() +
    geom_hline(yintercept = FDcutoff)
  df.all <- df.all %>%
    filter(MeanFD < FDcutoff)
  
  ##### Exclude participants with poor performance #####
  SubsBelowCutoff <- df.all %>% 
    filter(PercTaskAccuracy < 25)
  length(SubsBelowCutoff)
  cat('Number of subjects performing below cutoff (25% on one-choice trials):', length(SubsBelowCutoff$Subj), '\n')
  df.all <- df.all %>% 
    filter(PercTaskAccuracy > 25)
  
  ##### Exclude participants with poor data quality #####
  QCExclusions <- read_xlsx('P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Exclusions.xlsx') %>%
    filter(definitive_exclusions==1 | definitive_exclusions==0) %>%
    mutate(Outlier = 1) %>%
    rename(Subj = pseudonym,
           Visit=visit)
  df.all <- left_join(df.all, QCExclusions, by = c('Subj','Visit')) %>%
    mutate(Outlier = if_else(is.na(Outlier),0,Outlier)) %>%
    filter(Outlier == 0)
  
  ##### Check numbers #####
  df.all %>%
    select(TimepointNr, Group) %>%
    table() %>%
    print()
  
  ##### Check WeeksToFollowUp #####
  df.all %>%
    filter(TimepointNr=='T1') %>%
    ggplot(aes(y=WeeksToFollowUp/4/12,x=Subtype)) +
    ylab('Years to follow-up') +
    geom_boxplot()
  df.weeks <- df.all %>%
    filter(TimepointNr=='T1') %>%
    select(Group, Subtype, WeeksToFollowUp)
  m.group <- lm(WeeksToFollowUp ~ Group, data = df.weeks)
  m.subtype <- lm(WeeksToFollowUp ~ Subtype, data = df.weeks)
  emmeans(m.group, pairwise ~ Group) %>% print()
  emmeans(m.subtype, pairwise ~ Subtype) %>% print()
  
  ##### Check change in FD #####
  df.all %>%
    ggplot(aes(y=MeanFD,x=Subtype, fill=TimepointNr)) + 
    geom_boxplot()
  m.group <- lmer(MeanFD ~ Group*TimepointNr + (1|Subj), data = df.all)
  m.subtype <- lmer(MeanFD ~ Subtype*TimepointNr + (1|Subj), data = df.all)
  emmeans(m.group, pairwise ~ TimepointNr | Group, adjust = 'none') %>% print()
  emmeans(m.subtype, pairwise ~ TimepointNr | Subtype, adjust = 'none') %>% print()
  
  ##### Define tables per question of interest #####
  # Effect of PD
  df.disease <- df.all
  vars.disease <- c('Subj', 'Group', 'TimepointNr', 'Age', 'MeanFD', 'Sex', 'InputFile')
  df.disease <- df.disease %>%
    select(any_of(vars.disease)) %>%
    na.omit()
  # Effect of subtype
  df.subtype <- df.all %>%
    filter(Group == 'PD_POM',
           Subtype != '4_Undefined')
  vars.subtype <- c('Subj', 'Subtype', 'TimepointNr', 'Age', 'MeanFD', 'Sex', 'InputFile')
  df.subtype <- df.subtype %>%
    select(any_of(vars.subtype)) %>%
    na.omit()
  # Association with disesase severity
  df.severity <- df.all %>%
    filter(Group == 'PD_POM')
  vars.severity <- c('Subj', 'BradyRigScore', 'TimepointNr', 'Age', 'MeanFD', 'Sex', 'InputFile')
  df.severity <- df.severity %>%
    select(any_of(vars.severity)) %>%
    na.omit()
  
  ##### Demean covars #####
  df.disease <- df.disease %>%
    mutate(Age.gmc = Age - mean(Age),
           MeanFD.gmc = MeanFD - mean(MeanFD)) %>%
    group_by(Subj) %>%
    mutate(MeanFD.cm = mean(MeanFD),
           MeanFD.cwc = MeanFD - MeanFD.cm) %>%
    ungroup() %>%
    mutate(MeanFD.cmc = MeanFD.cm - mean(MeanFD.cm)) %>%
    mutate(across(where(is.numeric), round, digits=5))
  df.subtype <- df.subtype %>%
    mutate(Age.gmc = Age - mean(Age),
           MeanFD.gmc = MeanFD - mean(MeanFD)) %>%
    group_by(Subj) %>%
    mutate(MeanFD.cm = mean(MeanFD),
           MeanFD.cwc = MeanFD - MeanFD.cm) %>%
    ungroup() %>%
    mutate(MeanFD.cmc = MeanFD.cm - mean(MeanFD.cm)) %>%
    mutate(across(where(is.numeric), round, digits=5))
  df.severity <- df.severity %>%
    # Grand mean centering
    mutate(Age.gmc = Age - mean(Age),
           MeanFD.gmc = MeanFD - mean(MeanFD),
           BradyRigScore.gmc = BradyRigScore - mean(BradyRigScore)) %>%
    # Person mean centering (more generally, centering within cluster)
    # cwc represents variability in each subject's repeated measurement relative to the subject's own mean
    # Example: A patient's variability in symptom severity over time 
    group_by(Subj) %>%
    mutate(MeanFD.cm = mean(MeanFD),
           BradyRigScore.cm = mean(BradyRigScore),
           MeanFD.cwc = MeanFD - MeanFD.cm,
           BradyRigScore.cwc = BradyRigScore - BradyRigScore.cm) %>%
    # Grand mean centering of the aggregated variable
    # cmc represents variability in each subject's mean relative to the cohort's mean
    # Example: A patient's average symptom severity
    ungroup() %>%
    mutate(MeanFD.cmc = MeanFD.cm - mean(MeanFD.cm),
           BradyRigScore.cmc = BradyRigScore.cm - mean(BradyRigScore.cm)) %>%
    # Round to get cleaner output
    mutate(across(where(is.numeric), round, digits=5))
  
  ##### Select variables to be used in 3dLMEr #####
  # Is there a differential effect of PD on changes in brain activity?
  vars.disease <- c('Subj', 'Group', 'TimepointNr', 'Age.gmc', 'MeanFD.cwc', 'MeanFD.cmc', 'Sex', 'InputFile')
  df.disease <- df.disease %>%
    select(any_of(vars.disease))
  outputName.disease <- str_replace(outputName, 'dataTable', 'disease_dataTable')
  # Is there a differential effect of Subtype on changes in brain activity?
  vars.subtype <- c('Subj', 'Subtype', 'TimepointNr', 'Age.gmc', 'MeanFD.cwc', 'MeanFD.cmc', 'Sex', 'InputFile')
  df.subtype <- df.subtype %>%
    select(any_of(vars.subtype))
  outputName.subtype <- str_replace(outputName, 'dataTable', 'subtype_dataTable')
  # Is there an association between symptom progression and changes in brain activity?
  vars.severity <- c('Subj', 'BradyRigScore.cwc', 'BradyRigScore.cmc', 'TimepointNr', 'Age.gmc', 'MeanFD.cwc', 'MeanFD.cmc', 'Sex', 'InputFile')
  df.severity <- df.severity %>%
    select(any_of(vars.severity))
  outputName.severity <- str_replace(outputName, 'dataTable', 'severity_dataTable')
  
  ##### Write to file #####
  write_delim(df.disease, outputName.disease, delim = '\t') 
  write_delim(df.subtype, outputName.subtype, delim = '\t')
  write_delim(df.severity, outputName.severity, delim = '\t')
  
  ##### Write out a list of subjects that have both T0 and T1 input #####
  ids.t0 <- df.disease %>%
    filter(TimepointNr=='T0') %>%
    select(Subj)
  
  ids.t1 <- df.disease %>%
    filter(TimepointNr=='T1') %>%
    select(Subj)
  
  t0.and.t1 <- intersect(ids.t0, ids.t1)
  
  write_csv(ids.t0, str_replace(outputName, 'dataTable', 'listSubjectsT0'))
  write_csv(ids.t1, str_replace(outputName, 'dataTable', 'listSubjectsT1'))
  write_csv(t0.and.t1, str_replace(outputName, 'dataTable', 'listSubjectsIntersect'))
  
  
}
