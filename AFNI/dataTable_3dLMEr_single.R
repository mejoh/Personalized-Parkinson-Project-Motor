dataTable_3dLMEr_single <- function(con='con_0010.nii', outputDir='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/AFNI'){
  
    # con <- 'con_0010.nii'
    # outputDir <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal'
    
    library(tidyverse)
    library(readxl)
    # library(lme4)
    # library(lmerTest)
    # library(emmeans)
    library(tictoc)
    library(mice)
    library(miceadds)
    # source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_mean_covar.R")
    # source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_accuracy.R")
    outputName=paste(outputDir, '/', str_replace(con, '.nii', '_'), 'dataTable.txt', sep='')
    tic()
    
    ##### Load subjects with 1st-level results #####
    dAna <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem'
    Subs <- dir(dAna, pattern = 'sub-.*')
    
    ##### Load clinical data and select subtype variable #####
    # DiagEx1 = Baseline diagnosis - DiagEx2 = Follow-up diagnosis - DiagEx3 = Both
    dfClinVars <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-28.csv') %>%
        rename(Subtype1 = Subtype_DiagEx3_DisDurSplit,
               Subtype2 = Subtype_Imputed_DiagEx3_DisDurSplit,
               Subtype3 = Subtype_DiagEx3_DisDurSplit.MCI) %>%
        mutate(Subtype1 = if_else(ParticipantType=='HC_PIT', '0_Healthy', Subtype1),
               Subtype1 = if_else(is.na(Subtype1),'4_Undefined',Subtype1)) %>%
        mutate(Subtype2 = if_else(ParticipantType=='HC_PIT', '0_Healthy', Subtype2),
               Subtype2 = if_else(is.na(Subtype2),'4_Undefined',Subtype2)) %>%
        mutate(Subtype3 = if_else(ParticipantType=='HC_PIT', '0_Healthy', Subtype3),
               Subtype3 = if_else(is.na(Subtype3),'4_Undefined',Subtype3))
    
    ##### Initialize data frame #####
    df.all <- tibble(Subj=character(), Visit=character(), Group=character(), TimepointNr=numeric(), WeeksToFollowUp=numeric(),
                     Subtype1=character(), Subtype2=character(), Subtype3=character(), Age=numeric(), Sex=character(), 
                     MonthSinceDiag=numeric(), Up3Total=numeric(), BradyRigScore=numeric(), BradyScore=numeric(), 
                     RigScore=numeric(), InputFile=character(), InputFile2=character(), voxelwiseBA=character())
    
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
            Subtype1 <- dat %>% filter(Timepoint==tmp) %>% select(Subtype1) %>% as.character()
            Subtype2 <- dat %>% filter(Timepoint==tmp) %>% select(Subtype2) %>% as.character()
            Subtype3 <- dat %>% filter(Timepoint==tmp) %>% select(Subtype3) %>% as.character()
            Age <- dat %>% filter(Timepoint==tmp) %>% select(Age) %>% as.numeric()
            Sex <- dat %>% filter(Timepoint==tmp) %>% select(Gender) %>% as.character()
            MonthSinceDiag <- dat %>% filter(Timepoint==tmp) %>% select(MonthSinceDiag) %>% as.numeric()
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
            # MeanFD = compute_mean_covar(Subj, Visit, dAna='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem', measure='framewise_displacement')
            ##### DEPRECATED: Define accuarcy  #####
            #PercTaskAccuracy = retrieve_accuracy(Subj, Visit)
            ##### Define input file #####
            # Regular cons
            # InputFile <- file.path(dAna, Subj, Visit, '1st_level') %>% dir(pattern = con, full.names = TRUE) %>%
            #   str_replace('P:/', '/project/')
            # Flipped cons (need to do something about these visit ids not corresponding between studies...)
            # Note that these contrasts have already undergone exclusions in motor_copycontrasts.m
            Visit_re <- Visit %>% str_replace('Visit3','Visit2') %>% str_replace('P[A-Z][A-Z]', '')
            dCon <- file.path(dAna, 'Group', sub('.nii','',con), Visit_re)
            ptn <- paste(Subj, Visit, sep='_')
            InputFile <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('P:/', '/project/')
            if(identical(InputFile, character(0))){
                InputFile <- NA
            }
            ##### Define alternative input file #####
            dCon <- str_replace(dCon, 'Visit[0-9]', 'Diff')
            ptn <- str_replace(ptn, 'Visit[0-9]', 'VisitDiff')
            InputFile2 <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('P:/', '/project/')
            if(identical(InputFile2, character(0))){
                InputFile2 <- NA
            }
            ##### Define baseline input file (voxel-wise covariate) #####
            dCon <- str_replace(dCon, 'Diff', 'Visit1')
            ptn <- str_replace(ptn, 'VisitDiff', 'Visit1')
            voxelwiseBA <- dir(dCon, pattern = ptn, full.names = TRUE) %>%
                str_replace('P:/', '/project/')
            if(identical(voxelwiseBA, character(0))){
                voxelwiseBA <- NA
            }
            
            df.sub <- tibble(Subj=Subj, Visit=Visit, Group=Group, TimepointNr=TimepointNr, WeeksToFollowUp=WeeksToFollowUp,
                             Subtype1=Subtype1, Subtype2=Subtype2, Subtype3=Subtype3, Age=Age, Sex=Sex, MonthSinceDiag=MonthSinceDiag,
                             Up3Total=Up3Total, BradyRigScore=BradyRigScore, BradyScore=BradyScore, RigScore=RigScore,
                             InputFile=InputFile, InputFile2=InputFile2, voxelwiseBA=voxelwiseBA)
            df.all <- bind_rows(df.all, df.sub)
            
        }
    }
    
    ##### FIX: 3 patients with T2 fmri data does not appear to have castor data. These can be fixed easily #####
    df.all <- df.all %>%
        mutate(TimepointNr = if_else(is.na(TimepointNr), 2, TimepointNr))
    
    ##### FIX: TimepointNr and exclude PD_PIT #####
    df.all <- df.all %>%
        mutate(TimepointNr = if_else(TimepointNr == 2, 1, TimepointNr),
               TimepointNr = factor(TimepointNr, labels = c('T0','T1'), levels = c(0,1))) %>%
        filter(Group != 'PD_PIT')
    
    ##### Arrange ####
    df.all <- df.all %>%
        arrange(Group, Subtype1, Subj, TimepointNr)
    
    ##### Check numbers #####
    df.all %>%
        select(TimepointNr, Subtype1) %>%
        table() %>%
        print()
    
    # ##### Check WeeksToFollowUp #####
    df.all %>%
        group_by(Group,TimepointNr) %>%
        select(Group, TimepointNr, WeeksToFollowUp) %>%
        summarise(N=sum(is.na(WeeksToFollowUp))) %>% print()
    df.all <- df.all %>%
        mutate(YearsToFollowUp=WeeksToFollowUp/4/12,
               YearsToFollowUp=if_else(is.na(YearsToFollowUp) & TimepointNr=='T1', 2.3, YearsToFollowUp))
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
    vars.disease <- c('Subj', 'Group', 'Subtype1', 'TimepointNr', 'YearsToFollowUp', 'Age', 'MeanFD', 'Sex', 'InputFile', 'InputFile2', 'voxelwiseBA')
    df.disease <- df.disease %>%
        select(any_of(vars.disease))
    # Association with disease severity
    df.severity <- df.all %>%
        filter(Group == 'PD_POM') %>%
        mutate(ClinScore=BradyScore)
    vars.severity <- c('Subj', 'ClinScore', 'TimepointNr', 'Age', 'Sex', 'MonthSinceDiag', 'InputFile', 'InputFile2', 'voxelwiseBA')
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
        select(Subj, ClinScore, TimepointNr, Age, Sex) %>%
        mutate(Sex = factor(Sex))
    md.pattern(df.severity.imp)
    isna <- apply(df.severity.imp, 2, is.na) %>% colSums()
    cat(paste('\n ', 'Percentage missing values\n', sep=''))
    missing_perc <- round(isna/nrow(df.severity.imp), digits = 3)*100
    print(missing_perc)
    imputed <- df.severity.imp %>% 
        mice(m=round(5*missing_perc[names(missing_perc)=='ClinScore']), 
             maxit = 10, 
             method='pmm', 
             seed=157, 
             print=FALSE)
    summary(imputed)
    print(stripplot(imputed, formula('ClinScore ~ TimepointNr',sep='')),
          pch = 19, xlab = "Imputation number")
    df.severity.imp <- imputed %>%
        complete() %>%
        tibble() %>%
        select(Subj, TimepointNr, ClinScore) %>%
        rename(ClinScore.imp = ClinScore)
    
    df.severity <- left_join(df.severity, df.severity.imp, by=c('Subj','TimepointNr')) %>%
        relocate(Subj, ClinScore, ClinScore.imp)
    
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
    
    ##### Add time to follow-up to age so that it can be used as continuous measure of time
    df.disease <- df.disease %>%
        mutate(Age.timevar=if_else(TimepointNr=='T1',Age+YearsToFollowUp,Age))
    
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
    
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore:', avg_clinscore_at_ba,'\n')
    avg_clinscore_at_ba <- df.severity %>% summarise(mean(ClinScore.imp,na.rm=TRUE)) %>% as.numeric()
    cat('Average ClinScore.imp:', avg_clinscore_at_ba,'\n')
    avg_age_at_ba <- df.severity %>% summarise(mean(Age)) %>% as.numeric()
    cat('Average age at baseline (correlation analysis):', avg_age_at_ba,'\n')
    
    ##### Select variables to be used in 3dLMEr #####
    # Is there a differential effect of PD on changes in brain activity?
    vars.disease <- c('Subj', 'Group', 'Subtype1', 'TimepointNr', 'YearsToFollowUp', 'Age.timevar', 'Age', 'Sex', 'InputFile')
    df.disease.s <- df.disease %>%
        select(any_of(vars.disease)) %>%
        na.omit()
    df.disease.s %>% select(TimepointNr,Group) %>% table() %>% print()
    outputName.disease <- str_replace(outputName, 'dataTable', 'disease_dataTable')
    
    df.disease.HCvsMMP <- df.disease.s %>%
        filter(Subtype1 == '0_Healthy' | Subtype1 == '1_Mild-Motor') %>%
        mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=MMP\n')
    df.disease.HCvsMMP %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.HCvsMMP <- str_replace(outputName, 'dataTable', 'disease_HCvsMMP_dataTable')
    
    df.disease.HCvsIM <- df.disease.s %>%
        filter(Subtype1 == '0_Healthy' | Subtype1 == '2_Intermediate') %>%
        mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=IM\n')
    df.disease.HCvsIM %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.HCvsIM <- str_replace(outputName, 'dataTable', 'disease_HCvsIM_dataTable')
    
    df.disease.HCvsDM <- df.disease.s %>%
        filter(Subtype1 == '0_Healthy' | Subtype1 == '3_Diffuse-Malignant') %>%
        mutate(Subtype1 = if_else(Subtype1=='0_Healthy','G1','G2'))
    cat('G1=HC, G2=DM\n')
    df.disease.HCvsDM %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.HCvsDM <- str_replace(outputName, 'dataTable', 'disease_HCvsDM_dataTable')
    
    df.disease.MMPvsIM <- df.disease.s %>%
        filter(Subtype1 == '1_Mild-Motor' | Subtype1 == '2_Intermediate') %>%
        mutate(Subtype1 = if_else(Subtype1=='1_Mild-Motor','G1','G2'))
    cat('G1=MMP, G2=IM\n')
    df.disease.MMPvsIM %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.MMPvsIM <- str_replace(outputName, 'dataTable', 'disease_MMPvsIM_dataTable')
    
    df.disease.MMPvsDM <- df.disease.s %>%
        filter(Subtype1 == '1_Mild-Motor' | Subtype1 == '3_Diffuse-Malignant') %>%
        mutate(Subtype1 = if_else(Subtype1=='1_Mild-Motor','G1','G2'))
    cat('G1=MMP, G2=DM\n')
    df.disease.MMPvsDM %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.MMPvsDM <- str_replace(outputName, 'dataTable', 'disease_MMPvsDM_dataTable')
    
    df.disease.IMvsDM <- df.disease.s %>%
        filter(Subtype1 == '2_Intermediate' | Subtype1 == '3_Diffuse-Malignant') %>%
        mutate(Subtype1 = if_else(Subtype1=='2_Intermediate','G1','G2'))
    cat('G1=IM, G2=DM\n')
    df.disease.IMvsDM %>% select(TimepointNr,Subtype1) %>% table() %>% print()
    outputName.disease.IMvsDM <- str_replace(outputName, 'dataTable', 'disease_IMvsDM_dataTable')
    
    # Is there an association between symptom progression and changes in brain activity?
    vars.severity <- c('Subj', 'TimepointNr', 'ClinScore.imp', 'Age', 'Sex', 'MonthSinceDiag', 'InputFile')
    df.severity.s <- df.severity %>%
        select(any_of(vars.severity)) %>%
        na.omit()
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
        select(Subj, Group, Subtype1, Age, Sex, voxelwiseBA, InputFile2) %>%
        na.omit() %>%
        rename(InputFile = InputFile2) %>%
        arrange(Group,Subj)
    outputName.disease.delta <- str_replace(outputName, 'dataTable', 'disease-delta_dataTable')
    write_delim(df.disease.delta, outputName.disease.delta, delim = '\t')
    cat('Average age for delta group analysis:', mean(df.disease.delta$Age),'\n')
    
    df.severity.delta <- df.severity %>%
        pivot_wider(id_cols = c('Subj','Age','Sex','voxelwiseBA','InputFile2'),
                    names_from = TimepointNr,
                    values_from = ClinScore.imp) %>%
        mutate(ClinScore.BA=T0,
               ClinScore.FU=T1,
               ClinScore.delta=T1-T0) 
    # subs_without_delta <- df.severity.delta %>% 
    #     filter(is.na(ClinScore.delta) & !is.na(InputFile2))
    df.severity.delta <- df.severity.delta %>%
        select(Subj,ClinScore.delta,ClinScore.BA,ClinScore.FU,Age,Sex,voxelwiseBA,InputFile2) %>%
        rename(InputFile = InputFile2) %>%
        na.omit() %>%
        arrange(Subj)
    m <- lm(ClinScore.FU ~ ClinScore.BA, data=df.severity.delta)
    df.severity.delta <- bind_cols(df.severity.delta, ClinScore.delta.resid = resid(m)) %>%
        relocate(Subj, ClinScore.delta, ClinScore.delta.resid)
    outputName.severity.delta <- str_replace(outputName, 'dataTable', 'severity-delta_dataTable')
    write_delim(df.severity.delta, outputName.severity.delta, delim = '\t')
    cat('Average age for delta correlation analysis:', mean(df.severity.delta$Age),'\n')
    cat('Average delta for delta correlation analysis:', mean(df.severity.delta$ClinScore.delta),'\n')
    cat('Average baseline for delta correlation analysis:', mean(df.severity.delta$ClinScore.BA),'\n')
    
    ##### Write covars for 3dttest++ #####
    df.BAcov.disease <- df.disease.delta %>%
        mutate(Sex = if_else(Sex=='Female',0,1),
               Subj = basename(InputFile),
               Subj = str_sub(Subj,16),
               Subj = str_remove(Subj, '.nii')) %>%
        select(Subj, Age, Sex, voxelwiseBA)
    outputName.disease.BAcov <- str_replace(outputName, 'dataTable', 'disease-BAcov_dataTable')
    write_delim(df.BAcov.disease, outputName.disease.BAcov, delim = '\t')
    
    df.BAcov.severity <- df.severity.delta %>%
        mutate(Sex = if_else(Sex=='Female',0,1),
               Subj = basename(InputFile),
               Subj = str_sub(Subj,16),
               Subj = str_remove(Subj, '.nii')) %>%
        select(Subj, ClinScore.BA, ClinScore.delta, Age, Sex, voxelwiseBA) %>%
        arrange(Subj)
    outputName.severity.delta <- str_replace(outputName, 'dataTable', 'severity-BAcov_dataTable')
    write_delim(df.BAcov.severity, outputName.severity.delta, delim = '\t')
    
    tic() %>% print()
  
  
}
