dataTable_3dLMEr_single <- function(con='con_0007.nii', outputDir='/project/3024006.02/Analyses/motor_task/Group/Longitudinal/AFNI'){
  
    # con <- 'con_0010.nii'
    # outputDir <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal'
    
    library(tidyverse)
    library(readxl)
    # library(lme4)
    # library(lmerTest)
    # library(emmeans)
    library(tictoc)
    library(mice)
    library(miceadds)
    library(bmlm)
    # source("/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_mean_covar.R")
    # source("/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_accuracy.R")
    outputName=paste(outputDir, '/', str_replace(con, '.nii', '_'), 'dataTable.txt', sep='')
    tic()
    
    ##### Load subjects with 1st-level results #####
    dAna <- '/project/3024006.02/Analyses/motor_task'
    Subs <- dir(dAna, pattern = 'sub-.*')
    
    ##### Load clinical data and select subtype variable #####
    # DiagEx1 = Baseline diagnosis - DiagEx2 = Follow-up diagnosis - DiagEx3 = Both
    dfClinVars <- read_csv('/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2024-07-17.csv') %>%
        rename(Subtype = Subtype_DiagEx3_DisDurSplit.MCI_z) %>%
        mutate(Subtype = if_else(ParticipantType=='HC_PIT', '0_Healthy', Subtype),
               Subtype = if_else(is.na(Subtype),'4_Undefined',Subtype))
    
    ##### Load task performance data (needed for responding hand) #####
    dfTaskVars <- read_csv('/project/3022026.01/pep/bids/derivatives/manipulated_collapsed_merged_motor_task_mri_2023-09-15.csv') %>%
      group_by(pseudonym,Group,Timepoint) %>%
      summarise(across(everything(), ~first(.x))) %>%
      ungroup() %>%
      filter(Group != 'PD_PIT') %>%
      mutate(TimepointNr = if_else(str_detect(Timepoint,'Visit1'), 0, 1),
             RespondingHand = if_else(RespondingHand=='Right',0,1)) %>%
      select(pseudonym,Group,TimepointNr,RespondingHand) %>%
      pivot_wider(id_cols = c('pseudonym','Group'),
                  names_from = TimepointNr,
                  values_from = RespondingHand,
                  names_prefix = 'T') %>%
      mutate(T0 = if_else(is.na(T0),T1,T0),
             T1 = if_else(is.na(T1),T0,T1),
             RespHand = T0*T1,
             RespHand = if_else(RespHand==0,'Right','Left'))
    
    ##### Initialize data frame #####
    df.all <- tibble(Subj=character(), Visit=character(), Group=character(), TimepointNr=numeric(), YearsToFollowUp=numeric(),
                     Subtype=character(), Age=numeric(), Sex=character(), YearsSinceDiag=numeric(), NpsEducYears=numeric(),
                     RespHandIsDominant=numeric(),LEDD=numeric(),
                     Up3Total=numeric(), BradyRigScore=numeric(), BradyScore=numeric(),RigScore=numeric(),
                     z_MoCA=numeric(),raw_MoCA=numeric(),z_CognitiveComposite=numeric(),
                     InputFile=character(), InputFile2=character(), voxelwiseBA=character())
    
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
            ##### Time-invariant covariates #####
            # (has to take values from PD_POM cohort, not from PD_PIT, unless POMVisit1 does not exist...)
            if(Group=='PD_POM' & sum(str_detect(dat$Timepoint, 'ses-POMVisit1')) > 0){
                tmp <- 'ses-POMVisit1'
            }else{
                tmp <- Visits[1]
            }
            Subtype <- dat %>% filter(Timepoint==Visits[1]) %>% select(Subtype) %>% as.character() # From baseline
            Age <- dat %>% filter(Timepoint==tmp) %>% select(Age) %>% as.numeric()
            Sex <- dat %>% filter(Timepoint==tmp) %>% select(Gender) %>% as.character()
            YearsSinceDiag <- dat %>% filter(Timepoint==tmp) %>% select(YearsSinceDiag) %>% as.numeric()
            NpsEducYears <- dat %>% filter(Timepoint==tmp) %>% select(NpsEducYears) %>% as.numeric()
            PrefHand <- dat %>% filter(Timepoint==tmp) %>% select(PrefHand) %>% as.character()
            RespHand <- dfTaskVars %>% filter(pseudonym==Subj) %>% select(RespHand) %>% as.character()
            RespHandIsDominant <- if_else(PrefHand==RespHand,1,0)
            ##### Define timepoint (integer) #####
            TimepointNr <- dat %>% filter(Timepoint==Visit) %>% select(TimepointNr) %>% as.numeric()
            ##### FIX: Missing Visit3 demographics are filled in based on visit label #####
            if(Visit=='ses-POMVisit3' & is.na(TimepointNr)){
                TimepointNr = 2
            }
            ##### Define weeks to follow-up #####
            YearsToFollowUp <- dat %>% filter(Timepoint==Visit) %>% select(YearsToFollowUp) %>% as.numeric()
            ##### Define MDS-UPDRS III bradykinetic-rigid severity #####
            Up3Total <- dat %>% filter(Timepoint==Visit) %>% select(Up3OnTotal) %>% as.numeric()
            BradyScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OnBradySum) %>% as.numeric()
            RigScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OnRigiditySum) %>% as.numeric()
            BradyRigScore <- dat %>% filter(Timepoint==Visit) %>% select(Up3OnAppendicularSum) %>% as.numeric()
            ##### MoCA #####
            z_MoCA <- dat %>% filter(Timepoint==Visit) %>% select(z_MoCA__total) %>% as.numeric()
            raw_MoCA <- dat %>% filter(Timepoint==Visit) %>% select(MoCASum) %>% as.numeric()
            if(str_detect(Visit,'ses-POMVisit3') & is.na(raw_MoCA)){
              z_MoCA <- NA
            }
            ##### Cognitive composite #####
            z_CognitiveComposite <- dat %>% filter(Timepoint==Visit) %>% select(z_CognitiveComposite) %>% as.numeric()
            ##### Define Mean FD (from fmriprep covars that were used at 1st-level) #####
            # MeanFD = compute_mean_covar(Subj, Visit, dAna='/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem', measure='framewise_displacement')
            ##### DEPRECATED: Define accuarcy  #####
            #PercTaskAccuracy = retrieve_accuracy(Subj, Visit)
            ##### Define input file #####
            # Regular cons
            # InputFile <- file.path(dAna, Subj, Visit, '1st_level') %>% dir(pattern = con, full.names = TRUE) %>%
            #   str_replace('/project/', '/project/')
            # Flipped cons (need to do something about these visit ids not corresponding between studies...)
            # Note that these contrasts have already undergone exclusions in motor_copycontrasts.m
            ##### LEDD
            LEDD <- dat %>% filter(Timepoint==Visit) %>% select(LEDD) %>% as.numeric()
            Visit_re <- Visit %>% str_replace('Visit3','Visit2') %>% str_replace('P[A-Z][A-Z]', '')
            dCon <- file.path(dAna, 'Group', sub('.nii','',con), Visit_re)
            ptn <- paste(Subj, Visit, sep='_')
            InputFile <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('/project/', '/project/')
            if(identical(InputFile, character(0))){
                InputFile <- NA
            }
            ##### Define alternative input file #####
            dCon <- str_replace(dCon, 'Visit[0-9]', 'Diff')
            ptn <- str_replace(ptn, 'Visit[0-9]', 'VisitDiff')
            InputFile2 <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('/project/', '/project/')
            if(identical(InputFile2, character(0))){
                InputFile2 <- NA
            }
            ##### Define baseline input file (voxel-wise covariate) #####
            dCon <- str_replace(dCon, 'Diff', 'Visit1')
            ptn <- str_replace(ptn, 'VisitDiff', 'Visit1')
            voxelwiseBA <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('/project/', '/project/')
            if(identical(voxelwiseBA, character(0))){
                voxelwiseBA <- NA
            }
            
            df.sub <- tibble(Subj=Subj, Visit=Visit, Group=Group, TimepointNr=TimepointNr, YearsToFollowUp=YearsToFollowUp,
                             Subtype=Subtype, Age=Age, Sex=Sex, YearsSinceDiag=YearsSinceDiag,NpsEducYears=NpsEducYears,
                             RespHandIsDominant=RespHandIsDominant,LEDD=LEDD,
                             Up3Total=Up3Total, BradyRigScore=BradyRigScore, BradyScore=BradyScore, RigScore=RigScore,
                             z_MoCA=z_MoCA, raw_MoCA=raw_MoCA, z_CognitiveComposite=z_CognitiveComposite, 
                             InputFile=InputFile, InputFile2=InputFile2, voxelwiseBA=voxelwiseBA)
            df.all <- bind_rows(df.all, df.sub)
            
        }
    }
    
    ##### DEPRECATED FIX: 3 patients with T2 fmri data does not appear to have castor data. These can be fixed easily #####
    # df.all <- df.all %>%
    #     mutate(TimepointNr = if_else(is.na(TimepointNr), 2, TimepointNr))
    
    ##### FIX: TimepointNr and exclude PD_PIT #####
    df.all <- df.all %>%
        mutate(TimepointNr = if_else(TimepointNr == 2, 1, TimepointNr),
               TimepointNr = factor(TimepointNr, labels = c('T0','T1'), levels = c(0,1))) %>%
        filter(Group != 'PD_PIT')
    
    ##### Arrange ####
    df.all <- df.all %>%
        arrange(Group, Subtype, Subj, TimepointNr)
    
    ##### Check numbers #####
    df.all %>%
        select(TimepointNr, Subtype) %>%
        table() %>%
        print()
    
    # ##### Check YearsToFollowUp #####
    df.all %>%
        group_by(Group,TimepointNr) %>%
        select(Group, TimepointNr, YearsToFollowUp) %>%
        summarise(N=sum(is.na(YearsToFollowUp))) %>% print()
    df.all <- df.all %>%
        mutate(YearsToFollowUp=if_else(is.na(YearsToFollowUp) & TimepointNr=='T1', 2.3, YearsToFollowUp))
    # df.all %>%
    #     filter(TimepointNr=='T1') %>%
    #     ggplot(aes(y=YearsToFollowUp,x=Subtype1)) +
    #     ylab('Years to follow-up') +
    #     geom_boxplot()
    # df.weeks <- df.all %>%
    #     filter(TimepointNr=='T1') %>%
    #     select(Group, Subtype1, YearsToFollowUp)
    # m.group <- lm(YearsToFollowUp ~ Group, data = df.weeks)
    # m.subtype <- lm(YearsToFollowUp ~ Subtype1, data = df.weeks)
    # emmeans(m.group, pairwise ~ Group) %>% print()
    # emmeans(m.subtype, pairwise ~ Subtype1) %>% print()
    
    # ##### Check change in FD #####
    # df.all %>%
    #     ggplot(aes(y=MeanFD,x=Subtype1, fill=TimepointNr)) + 
    #     geom_boxplot()
    # m.group <- lmer(MeanFD ~ Group*TimepointNr + (1|Subj), data = df.all)
    # m.subtype <- lmer(MeanFD ~ Subtype1*TimepointNr + (1|Subj), data = df.all)
    # emmeans(m.group, pairwise ~ TimepointNr | Group, adjust = 'none') %>% print()
    # emmeans(m.subtype, pairwise ~ TimepointNr | Subtype1, adjust = 'none') %>% print()
    
    ##### Define tables per question of interest #####
    # Effect of PD
    df.disease <- df.all
    vars.disease <- c('Subj', 'Group', 'Subtype', 'TimepointNr', 'YearsToFollowUp', 'Age', 'YearsSinceDiag',
                      'NpsEducYears','RespHandIsDominant', 'Sex', 'InputFile', 'InputFile2', 'voxelwiseBA')
    df.disease <- df.disease %>%
        select(any_of(vars.disease))
    # Association with disease severity
    df.severity <- df.all %>%
        filter(Group == 'PD_POM') %>%
        mutate(ClinScore_brady=BradyScore,
               ClinScore_cog=z_MoCA)
    vars.severity <- c('Subj', 'ClinScore_brady', 'ClinScore_cog', 'TimepointNr', 'Age', 'Sex', 'YearsSinceDiag',
                       'NpsEducYears','RespHandIsDominant','LEDD', 'InputFile', 'InputFile2', 'voxelwiseBA')
    df.severity <- df.severity %>%
        select(any_of(vars.severity))
    
    ##### Multiple imputation of missing ClinScore ####
    # df.severity.imp1 <- df.severity %>%
    #     select(Subj, ClinScore, TimepointNr, Age, Sex) %>%
    #     mutate(Sex = factor(Sex)) %>%
    #     pivot_wider(id_cols = c('Subj','Age','Sex'),
    #                 names_from = TimepointNr,
    #                 values_from = ClinScore)
    # md.pattern(df.severity.imp1)
    # isna <- apply(df.severity.imp1, 2, is.na) %>% colSums()
    # cat(paste('\n ', 'Percentage missing values\n', sep=''))
    # missing_perc <- round(isna/nrow(df.severity.imp1), digits = 3)*100
    # print(missing_perc)
    # imputed <- df.severity.imp1 %>% 
    #     mice(m=round(5*missing_perc[names(missing_perc)=='T1']), 
    #          maxit = 10, 
    #          method='pmm', 
    #          seed=157, 
    #          print=FALSE)
    # summary(imputed)
    # print(stripplot(imputed, formula('T1 ~ TimepointNr',sep='')),
    #       pch = 19, xlab = "Imputation number")
    # df.severity.imp1 <- imputed %>%
    #     complete() %>%
    #     tibble() %>%
    #     pivot_longer(cols = c('T0','T1'),
    #                  names_to = 'TimepointNr',
    #                  values_to = 'ClinScore') %>%
    #     select(Subj, TimepointNr, ClinScore) %>%
    #     rename(ClinScore.imp1 = ClinScore)
    
    df.severity.imp <- df.severity %>%
        select(Subj, ClinScore_brady, ClinScore_cog, TimepointNr, Age, Sex, YearsSinceDiag, NpsEducYears, RespHandIsDominant, LEDD) %>%
        mutate(Sex = factor(Sex),
               RespHandIsDominant = factor(RespHandIsDominant))
    md.pattern(df.severity.imp)
    isna <- apply(df.severity.imp, 2, is.na) %>% colSums()
    cat(paste('\n ', 'Percentage missing values\n', sep=''))
    missing_perc <- round(isna/nrow(df.severity.imp), digits = 3)*100
    print(missing_perc)
    imputed <- df.severity.imp %>% 
        mice(m=round(5*missing_perc[names(missing_perc)=='ClinScore_brady']), 
             maxit = 10, 
             method='pmm', 
             seed=157, 
             print=FALSE)
    summary(imputed)
    print(stripplot(imputed, formula('ClinScore_brady ~ TimepointNr',sep='')),
          pch = 19, xlab = "Imputation number")
    print(stripplot(imputed, formula('ClinScore_cog ~ TimepointNr',sep='')),
          pch = 19, xlab = "Imputation number")
    df.severity.imp <- imputed %>%
      complete() %>%
      tibble() %>%
      select(Subj, TimepointNr, ClinScore_brady, ClinScore_cog, YearsSinceDiag, NpsEducYears, LEDD) %>%
      rename(ClinScore_brady_imp = ClinScore_brady,
             ClinScore_cog_imp = ClinScore_cog,
             YearsSinceDiag.imp = YearsSinceDiag,
             NpsEducYears.imp = NpsEducYears,
             LEDD_imp = LEDD) %>%
      group_by(Subj) %>%
      mutate(YearsSinceDiag.imp = first(YearsSinceDiag.imp),
             NpsEducYears.imp = first(NpsEducYears.imp)) %>%
      ungroup()
    
    df.severity <- left_join(df.severity, df.severity.imp, by=c('Subj','TimepointNr')) %>%
        relocate(Subj, ClinScore_brady, ClinScore_brady_imp, ClinScore_cog, ClinScore_cog_imp, TimepointNr, Age, Sex, YearsSinceDiag,
                 YearsSinceDiag.imp, NpsEducYears, NpsEducYears.imp, RespHandIsDominant, LEDD, LEDD_imp)
    
    # #### Disagreggation of within and between subject variability. Demeaning should be done in AFNI by setting appropriate values for qVarCenters #####
    # # NOTE: 
    # df.disease <- df.disease %>%
    #   mutate(Age.gmc = Age - mean(Age),
    #          MeanFD.gmc = MeanFD - mean(MeanFD)) %>%
    #   group_by(Subj) %>%
    #   mutate(MeanFD.cm = mean(MeanFD),
    #          MeanFD.cwc = MeanFD - MeanFD.cm) %>%
    #   ungroup() %>%
    #   mutate(MeanFD.cmc = MeanFD.cm - mean(MeanFD.cm)) %>%
    #   mutate(across(where(is.numeric), round, digits=5))
    # # df.subtype <- df.subtype %>%
    # #   mutate(Age.gmc = Age - mean(Age),
    # #          MeanFD.gmc = MeanFD - mean(MeanFD)) %>%
    # #   group_by(Subj) %>%
    # #   mutate(MeanFD.cm = mean(MeanFD),
    # #          MeanFD.cwc = MeanFD - MeanFD.cm) %>%
    # #   ungroup() %>%
    # #   mutate(MeanFD.cmc = MeanFD.cm - mean(MeanFD.cm)) %>%
    # #   mutate(across(where(is.numeric), round, digits=5))
    # df.severity <- df.severity %>%
    #   # Grand mean centering
    #   mutate(Age.gmc = Age - mean(Age),
    #          MeanFD.gmc = MeanFD - mean(MeanFD),
    #          ClinScore.gmc = ClinScore - mean(ClinScore,na.rm=TRUE)) %>%
    #   # Person mean centering (more generally, centering within cluster)
    #   # cwc represents variability in each subject's repeated measurement relative to the subject's own mean
    #   # Example: A patient's variability in symptom severity over time
    #   group_by(Subj) %>%
    #   mutate(ClinScore.cm = mean(ClinScore,na.rm=TRUE),
    #          ClinScore.cwc = ClinScore - ClinScore.cm) %>%
    #   # Grand mean centering of the aggregated variable
    #   # cmc represents variability in each subject's mean relative to the cohort's mean
    #   # Example: A patient's average symptom severity
    #   ungroup() %>%
    #   mutate(ClinScore.cmc = ClinScore.cm - mean(ClinScore.cm,na.rm=TRUE)) %>%
    #   # Round to get cleaner output
    #   mutate(across(where(is.numeric), round, digits=5))
    df.severity <- df.severity %>%
      isolate(d = .,
              by = 'Subj',
              value = c('ClinScore_brady','ClinScore_brady_imp', 'ClinScore_cog', 'ClinScore_cog_imp', 'LEDD', 'LEDD_imp'),
              which = 'both') %>%
      mutate(ClinScore_brady_cbxcw = ClinScore_brady_cb*ClinScore_brady_cw,
             ClinScore_brady_imp_cbxcw = ClinScore_brady_imp_cb*ClinScore_brady_imp_cw,
             ClinScore_cog_cbxcw = ClinScore_cog_cb*ClinScore_cog_cw,
             ClinScore_cog_imp_cbxcw = ClinScore_cog_imp_cb*ClinScore_cog_imp_cw,
             LEDD_cbxcw = LEDD_cb*LEDD_cw,
             LEDD_imp_cbxcw = LEDD_imp_cb*LEDD_imp_cw) %>%
      mutate(across(where(is.numeric), \(x) round(x, digits = 5)))
    
    ##### Add time to follow-up to age so that it can be used as continuous measure of time
    df.disease <- df.disease %>%
      mutate(Age.timevar=if_else(TimepointNr=='T1',Age+YearsToFollowUp,Age)) %>%
      mutate(across(where(is.numeric), \(x) round(x, digits=5)))
    
    ##### NOT APPROPRIATE: Add polynomials for Age and ClinScore #####
    # df.disease <- df.disease %>%
    #   bind_cols(Age=poly(df.disease$Age,degree=3)[,1],
    #             Age.poly2=poly(df.disease$Age,degree=3)[,2],
    #             Age.poly3=poly(df.disease$Age,degree=3)[,3])
    # df.severity <- bind_cols(df.severity,
    #                          ClinScore=poly(df.severity$ClinScore,degree=3)[,1],
    #                          ClinScore.poly2=poly(df.severity$ClinScore,degree=3)[,2],
    #                          ClinScore.poly3=poly(df.severity$ClinScore,degree=3)[,3])
    
    ##### Report centers of quantitative vars
    avg_age_at_ba <- df.disease %>% filter(TimepointNr=='T0') %>% summarise(mean(Age)) %>% as.numeric()
    cat('Average age at baseline (group analysis):', avg_age_at_ba,'\n')
    avg_age <- df.disease %>% summarise(mean(Age)) %>% as.numeric()
    cat('Average age at baseline across sessions (group analysis):', avg_age,'\n')
    avg_timetofu <- df.disease %>% summarise(mean(YearsToFollowUp)) %>% as.numeric()
    cat('Average years to follow-up (group analysis):', avg_timetofu,'\n')
    
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore_brady,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore_brady:', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore_brady_imp,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore_brady_imp', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore_cog,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore_cog:', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore_cog_imp,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore_cog_imp', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(LEDD,na.rm=TRUE)) %>% as.numeric()
    cat('Average LEDD:', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(LEDD_imp,na.rm=TRUE)) %>% as.numeric()
    cat('Average LEDD_imp', avg_clinscore_at_ba,'\n')
    avg_age_at_ba <- df.severity %>% filter(TimepointNr=='T0') %>% summarise(mean(Age)) %>% as.numeric()
    cat('Average age at baseline (correlation analysis):', avg_age_at_ba,'\n')
    
    ##### Select variables to be used in 3dLMEr #####
    # Is there a differential effect of PD on changes in brain activity?
    vars.disease <- c('Subj', 'Group', 'Subtype', 'TimepointNr', 'YearsToFollowUp', 'Age.timevar', 'Age', 'Sex',
                      'NpsEducYears', 'RespHandIsDominant', 'InputFile')
    df.disease.s <- df.disease %>%
        select(any_of(vars.disease)) %>%
        na.omit()
    df.disease.s %>% select(TimepointNr,Group) %>% table() %>% print()
    outputName.disease <- str_replace(outputName, 'dataTable', 'disease_dataTable')
    
    vars.disease <- c('Subj', 'Group', 'Subtype', 'TimepointNr', 'YearsToFollowUp', 'Age.timevar', 'Age', 'Sex',
                      'NpsEducYears','RespHandIsDominant','YearsSinceDiag', 'InputFile')
    df.disease.s_type <- df.disease %>%
      select(any_of(vars.disease)) %>%
      na.omit()
    df.disease.s_type %>% select(TimepointNr,Subtype) %>% table() %>% print()
    
    df.disease.HCvsMMP <- df.disease.s %>%
        filter(Subtype == '0_Healthy' | Subtype == '1_Mild-Motor') %>%
        mutate(Subtype = if_else(Subtype=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=MMP\n')
    df.disease.HCvsMMP %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.HCvsMMP <- str_replace(outputName, 'dataTable', 'disease_HCvsMMP_dataTable')
    
    df.disease.HCvsIM <- df.disease.s %>%
        filter(Subtype == '0_Healthy' | Subtype == '2_Intermediate') %>%
        mutate(Subtype = if_else(Subtype=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=IM\n')
    df.disease.HCvsIM %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.HCvsIM <- str_replace(outputName, 'dataTable', 'disease_HCvsIM_dataTable')
    
    df.disease.HCvsDM <- df.disease.s %>%
        filter(Subtype == '0_Healthy' | Subtype == '3_Diffuse-Malignant') %>%
        mutate(Subtype = if_else(Subtype=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=DM\n')
    df.disease.HCvsDM %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.HCvsDM <- str_replace(outputName, 'dataTable', 'disease_HCvsDM_dataTable')
    
    df.disease.MMPvsIM <- df.disease.s_type %>%
        filter(Subtype == '1_Mild-Motor' | Subtype == '2_Intermediate') %>%
        mutate(Subtype = if_else(Subtype=='1_Mild-Motor','G1','G2'))
    cat('G1=MMP, G2=IM\n')
    df.disease.MMPvsIM %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.MMPvsIM <- str_replace(outputName, 'dataTable', 'disease_MMPvsIM_dataTable')
    
    df.disease.MMPvsDM <- df.disease.s_type %>%
        filter(Subtype == '1_Mild-Motor' | Subtype == '3_Diffuse-Malignant') %>%
        mutate(Subtype = if_else(Subtype=='1_Mild-Motor','G1','G2'))
    cat('G1=MMP, G2=DM\n')
    df.disease.MMPvsDM %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.MMPvsDM <- str_replace(outputName, 'dataTable', 'disease_MMPvsDM_dataTable')
    
    df.disease.IMvsDM <- df.disease.s_type %>%
        filter(Subtype == '2_Intermediate' | Subtype == '3_Diffuse-Malignant') %>%
        mutate(Subtype = if_else(Subtype=='2_Intermediate','G1','G2'))
    cat('G1=IM, G2=DM\n')
    df.disease.IMvsDM %>% select(TimepointNr,Subtype) %>% table() %>% print()
    outputName.disease.IMvsDM <- str_replace(outputName, 'dataTable', 'disease_IMvsDM_dataTable')
    
    # Is there an association between symptom progression and changes in brain activity?
    vars.severity <- c('Subj', 'TimepointNr', 
                       'ClinScore_brady', 'ClinScore_brady_cb', 'ClinScore_brady_cw', 'ClinScore_brady_cbxcw',
                       'ClinScore_brady_imp', 'ClinScore_brady_imp_cb', 'ClinScore_brady_imp_cw', 'ClinScore_brady_imp_cbxcw',
                       'ClinScore_cog', 'ClinScore_cog_cb', 'ClinScore_cog_cw', 'ClinScore_cog_cbxcw',
                       'ClinScore_cog_imp', 'ClinScore_cog_imp_cb', 'ClinScore_cog_imp_cw', 'ClinScore_cog_imp_cbxcw',
                       'LEDD','LEDD_cb','LEDD_cw','LEDD_cbxcw','LEDD_imp','LEDD_imp_cb','LEDD_imp_cw','LEDD_imp_cbxcw',
                       'Age', 'Sex', 'YearsSinceDiag.imp','NpsEducYears.imp','RespHandIsDominant', 'InputFile')#, 'InputFile2')
    df.severity.s <- df.severity %>%
        select(any_of(vars.severity)) %>%
        na.omit() #%>%
      #select(-InputFile2)
    outputName.severity <- str_replace(outputName, 'dataTable', 'severity_dataTable')
    # vars.severity <- c('Subj', 'ClinScore', 'ClinScore', 'ClinScore.poly2', 'Age', 'Sex', 'InputFile')
    # df.severity.poly2 <- df.severity %>%
    #   select(any_of(vars.severity))
    # outputName.severity.poly2 <- str_replace(outputName, 'dataTable', 'severity-poly2_dataTable')
    # vars.severity <- c('Subj', 'ClinScore', 'ClinScore', 'ClinScore.poly2', 'ClinScore.poly3', 'Age', 'Sex', 'InputFile')
    # df.severity.poly3 <- df.severity %>%
    #   select(any_of(vars.severity))
    # outputName.severity.poly3 <- str_replace(outputName, 'dataTable', 'severity-poly3_dataTable')
    
    ##### Write to file #####
    write_delim(df.disease.s, outputName.disease, delim = '\t')
    write_delim(df.disease.HCvsMMP, outputName.disease.HCvsMMP, delim = '\t')
    write_delim(df.disease.HCvsIM, outputName.disease.HCvsIM, delim = '\t')
    write_delim(df.disease.HCvsDM, outputName.disease.HCvsDM, delim = '\t')
    write_delim(df.disease.MMPvsIM, outputName.disease.MMPvsIM, delim = '\t')
    write_delim(df.disease.MMPvsDM, outputName.disease.MMPvsDM, delim = '\t')
    write_delim(df.disease.IMvsDM, outputName.disease.IMvsDM, delim = '\t')
    write_delim(df.severity.s, outputName.severity, delim = '\t')
    
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
    
    ##### Write alternative input files (deltas) #####
    df.disease.delta <- df.disease %>%
        filter(TimepointNr=='T0') %>%
        select(Subj, Group, Subtype, Age, Sex, NpsEducYears, RespHandIsDominant, voxelwiseBA, InputFile2) %>%
        na.omit() %>%
        rename(InputFile = InputFile2) %>%
        arrange(Group,Subj)
    outputName.disease.delta <- str_replace(outputName, 'dataTable', 'disease-delta_dataTable')
    write_delim(df.disease.delta, outputName.disease.delta, delim = '\t')
    cat('Average age for delta group analysis:', mean(df.disease.delta$Age),'\n')
    
    df.severity.delta <- df.severity %>%
        pivot_wider(id_cols = c('Subj','Age','Sex','YearsSinceDiag.imp','NpsEducYears','RespHandIsDominant','voxelwiseBA','InputFile2'),
                    names_from = 'TimepointNr',
                    values_from = c('ClinScore_brady_imp','ClinScore_cog_imp','LEDD_imp')) %>%
        mutate(ClinScore_brady.BA=ClinScore_brady_imp_T0,
               ClinScore_brady.FU=ClinScore_brady_imp_T1,
               ClinScore_brady.delta=ClinScore_brady_imp_T1-ClinScore_brady_imp_T0,
               ClinScore_brady.deltaxBA=ClinScore_brady.delta*ClinScore_brady.BA,
               ClinScore_cog.BA=ClinScore_cog_imp_T0,
               ClinScore_cog.FU=ClinScore_cog_imp_T1,
               ClinScore_cog.delta=ClinScore_cog_imp_T1-ClinScore_cog_imp_T0,
               ClinScore_cog.deltaxBA=ClinScore_cog.delta*ClinScore_cog.BA,
               LEDD.BA=LEDD_imp_T0,
               LEDD.FU=LEDD_imp_T1,
               LEDD.delta=LEDD_imp_T1-LEDD_imp_T0,
               LEDD.deltaxBA=LEDD.delta*LEDD.BA) 
    # subs_without_delta <- df.severity.delta %>% 
    #     filter(is.na(ClinScore.delta) & !is.na(InputFile2))
    df.severity.delta <- df.severity.delta %>%
        select(Subj,ClinScore_brady.delta,ClinScore_brady.BA,ClinScore_brady.FU,
               ClinScore_cog.delta,ClinScore_cog.BA,ClinScore_cog.FU,
               LEDD.delta,LEDD.BA,LEDD.FU,
               Age,Sex,NpsEducYears,RespHandIsDominant,YearsSinceDiag.imp,voxelwiseBA,InputFile2) %>%
        rename(InputFile = InputFile2) %>%
        na.omit() %>%
        arrange(Subj)
    # df.severity.delta <- bind_cols(df.severity.delta, ClinScore.delta.resid = resid(m)) %>%
    #     relocate(Subj, ClinScore.delta, ClinScore.delta.resid)
    outputName.severity.delta <- str_replace(outputName, 'dataTable', 'severity-delta_dataTable')
    write_delim(df.severity.delta, outputName.severity.delta, delim = '\t')
    cat('Average age for delta correlation analysis:', mean(df.severity.delta$Age),'\n')
    cat('Average bradykinesia delta for delta correlation analysis:', mean(df.severity.delta$ClinScore_brady.delta),'\n')
    cat('Average bradykinesia baseline for delta correlation analysis:', mean(df.severity.delta$ClinScore_brady.BA),'\n')
    cat('Average moca delta for delta correlation analysis:', mean(df.severity.delta$ClinScore_cog.delta),'\n')
    cat('Average moca baseline for delta correlation analysis:', mean(df.severity.delta$ClinScore_cog.BA),'\n')
    cat('Average LEDD delta for delta correlation analysis:', mean(df.severity.delta$ClinScore_cog.delta),'\n')
    cat('Average LEDD baseline for delta correlation analysis:', mean(df.severity.delta$ClinScore_cog.BA),'\n')
    
    ##### Write covars for 3dttest++ #####
    df.BAcov.disease <- df.disease.delta %>%
        mutate(Sex = if_else(Sex=='Female',0,1),
               Subj = basename(InputFile),
               Subj = str_sub(Subj,16),
               Subj = str_remove(Subj, '.nii')) %>%
        select(Subj, Age, Sex,NpsEducYears,RespHandIsDominant, voxelwiseBA)
    outputName.disease.BAcov <- str_replace(outputName, 'dataTable', 'disease-BAcov_dataTable')
    write_delim(df.BAcov.disease, outputName.disease.BAcov, delim = '\t')
    
    df.BAcov.severity <- df.severity.delta %>%
        mutate(Sex = if_else(Sex=='Female',0,1),
               Subj = basename(InputFile),
               Subj = str_sub(Subj,16),
               Subj = str_remove(Subj, '.nii')) %>%
        select(Subj, ClinScore_brady.BA, ClinScore_brady.delta, ClinScore_cog.BA, ClinScore_cog.delta, LEDD.BA, LEDD.delta,
               Age, Sex, YearsSinceDiag.imp, NpsEducYears,RespHandIsDominant, voxelwiseBA) %>%
        arrange(Subj)
    outputName.severity.delta <- str_replace(outputName, 'dataTable', 'severity-BAcov_dataTable')
    write_delim(df.BAcov.severity, outputName.severity.delta, delim = '\t')
    
    df.BAcov.severity_brady <- df.BAcov.severity %>% select(-c(ClinScore_cog.BA, ClinScore_cog.delta, LEDD.BA, LEDD.delta))
    outputName.severity.delta_brady <- str_replace(outputName, 'dataTable', 'severity-BAcov_brady_dataTable')
    write_delim(df.BAcov.severity_brady, outputName.severity.delta_brady, delim = '\t')
    df.BAcov.severity_moca <- df.BAcov.severity %>% select(-c(ClinScore_brady.BA, ClinScore_brady.delta, LEDD.BA, LEDD.delta))
    outputName.severity.delta_moca <- str_replace(outputName, 'dataTable', 'severity-BAcov_moca_dataTable')
    write_delim(df.BAcov.severity_moca, outputName.severity.delta_moca, delim = '\t')
    df.BAcov.severity_ledd <- df.BAcov.severity %>% select(-c(ClinScore_brady.BA, ClinScore_brady.delta, ClinScore_cog.BA, ClinScore_cog.delta))
    outputName.severity.delta_ledd <- str_replace(outputName, 'dataTable', 'severity-BAcov_ledd_dataTable')
    write_delim(df.BAcov.severity_ledd, outputName.severity.delta_ledd, delim = '\t')
    
    tic() %>% print()
  
  
}
