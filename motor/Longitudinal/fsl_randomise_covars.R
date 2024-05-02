# Generates output files for complete case analyses (i.e., only subjects that have both sessions)
fsl_randomise_covars <- function(condir1, condir2, condir3, csvfile, outputdir){
    
    library(tidyverse)
    library(mice)
    library(miceadds)
    library(MatchIt)
    
    dir.create(outputdir, showWarnings = F, recursive = T)
    
    # Initialize data frame
    imgs = list.files(condir1)
    imgs_fp = list.files(condir1,full.names = T) %>%
        str_replace('P:','/project')
    imgs2_fp = list.files(condir2,full.names = T) %>%
        str_replace('P:','/project')
    imgs3_fp = list.files(condir3,full.names = T) %>%
        str_replace('P:','/project')
    group = str_sub(imgs, start = 1, end = 6)
    pseudonym = str_sub(imgs, start = 8, end = 31)
    dfinit <- tibble(pseudonym=pseudonym,ParticipantType=group,imgs=imgs,imgs_fp=imgs_fp,imgs2_fp,imgs3_fp)
    
    # Select baseline covars
    baseline_covars <- read_csv(csvfile,
                                col_select = all_of(c('pseudonym','ParticipantType','TimepointNr','Age',
                                               'Gender','NpsEducYears','YearsSinceDiag','PrefHand'))) %>%
        filter(ParticipantType != 'PD_PIT',
               TimepointNr == 0) %>%
        mutate(Gender=if_else(Gender=='Female',0,1))
    
    source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_resphand.R")
    resphand <- retrieve_resphand() %>% rename(ParticipantType=Group) %>% filter(str_detect(Timepoint,'Visit1'))
    baseline_covars <- baseline_covars %>%
        left_join(., resphand, by = c('pseudonym','ParticipantType')) %>%
        mutate(RespHandIsDominant = if_else(RespondingHand == PrefHand | PrefHand == 'NoPref',1,0)) %>%
        select(-c(PrefHand,RespondingHand))
    
    ## Unpaired t-tests: pd vs hc
    # Add covariates
    df <- dfinit %>%
        left_join(., baseline_covars[,c('pseudonym','ParticipantType','TimepointNr',
                                        'Age','Gender','NpsEducYears','RespHandIsDominant')], 
                  by=c('pseudonym','ParticipantType')) %>%
        mutate(HC=if_else(ParticipantType=='HC_PIT',1,0),
               PD=if_else(ParticipantType=='PD_POM',1,0))
    # Case-control matching
    # Optimal matching creates pairs of controls and patients
    set.seed(312)
    matching0 <- df %>%
        mutate(Group = if_else(HC==1,0,1),
               Gender = factor(Gender),
               RespHandIsDominant = factor(RespHandIsDominant)) %>%
        matchit(Group ~ Age + Gender + NpsEducYears + RespHandIsDominant,
                data = .,
                method = NULL,
                distance = 'glm',
                link = 'probit',
                estimand = 'ATT')
    summary(matching0)
    matching1 <- df %>%
        mutate(Group = if_else(HC==1,0,1),
               Gender = factor(Gender),
               RespHandIsDominant = factor(RespHandIsDominant)) %>%
        matchit(Group ~ Age + Gender + NpsEducYears + RespHandIsDominant,
                data = .,
                method = 'optimal',
                distance = 'glm',
                link = 'probit',
                estimand = 'ATT',
                tol = 1e-4)
    summary(matching1, un = F)
    plot(summary(matching1))
    plot(matching1, type = 'jitter', interactive = F)
    plot(matching1, type = 'density', interactive = F,
         which.xs = ~Age + Gender + NpsEducYears + RespHandIsDominant)
    df.matched <- match.data(matching1) %>%
        mutate(Gender = as.numeric(Gender)-1,
               RespHandIsDominant = as.numeric(RespHandIsDominant)-1)
    # Select and demean
    df.s <- df %>% 
        select(HC,PD,Age,Gender,NpsEducYears,RespHandIsDominant) %>%
        mutate(Age=Age-mean(Age),
               Gender=Gender-mean(Gender),
               NpsEducYears=NpsEducYears-mean(NpsEducYears),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               vxlEV=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    df.s.matched <- df.matched %>% 
        select(HC,PD,Age,Gender,NpsEducYears,RespHandIsDominant) %>%
        mutate(Age=Age-mean(Age),
               Gender=Gender-mean(Gender),
               NpsEducYears=NpsEducYears-mean(NpsEducYears),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               vxlEV=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Write to file
    write_delim(df[,4], paste0(outputdir, '/imgs__delta_unpaired_ttest_unmatched.txt'), col_names = F)
    write_delim(df[,5], paste0(outputdir, '/imgs__ba_unpaired_ttest_unmatched.txt'), col_names = F)
    write_delim(df[,6], paste0(outputdir, '/imgs__fu_unpaired_ttest_unmatched.txt'), col_names = F)
    write_delim(df.s, paste0(outputdir, '/covs__delta_unpaired_ttest_unmatched_vxlEV.txt'), col_names = F)
    df.s %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/covs__delta_unpaired_ttest_unmatched.txt'), col_names = F)
    tmp <- df.s %>% filter(HC == 1) %>% select(-PD)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gHC__covs__delta_unpaired_ttest_unmatched_vxlEV.txt'), col_names = F)
    tmp %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/posthoc_gHC__covs__delta_unpaired_ttest_unmatched.txt'), col_names = F)
    tmp <- df.s %>% filter(PD == 1) %>% select(-HC)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gPD__covs__delta_unpaired_ttest_unmatched_vxlEV.txt'), col_names = F)
    tmp %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/posthoc_gPD__covs__delta_unpaired_ttest_unmatched.txt'), col_names = F)
    
    write_delim(df.matched[,4], paste0(outputdir, '/imgs__delta_unpaired_ttest_matched.txt'), col_names = F)
    write_delim(df.matched[,5], paste0(outputdir, '/imgs__ba_unpaired_ttest_matched.txt'), col_names = F)
    write_delim(df.matched[,6], paste0(outputdir, '/imgs__fu_unpaired_ttest_matched.txt'), col_names = F)
    write_delim(df.s.matched, paste0(outputdir, '/covs__delta_unpaired_ttest_matched_vxlEV.txt'), col_names = F)
    
    df.s.matched %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/covs__delta_unpaired_ttest_matched.txt'), col_names = F)
    
    tmp <- df.s.matched %>% filter(HC == 1) %>% select(-PD)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gHC__covs__delta_unpaired_ttest_matched_vxlEV.txt'), col_names = F)
    tmp %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/posthoc_gHC__covs__delta_unpaired_ttest_matched.txt'), col_names = F)
    tmp <- df.s.matched %>% filter(PD == 1) %>% select(-HC)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gPD__covs__delta_unpaired_ttest_matched_vxlEV.txt'), col_names = F)
    tmp %>% select(-vxlEV) %>% write_delim(., paste0(outputdir, '/posthoc_gPD__covs__delta_unpaired_ttest_matched.txt'), col_names = F)
    
    # Contrasts
    
    rbind(c(1,-1,0,0,0,0,0),
          c(-1,1,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__unpaired_ttest_vxlEV.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,-1,0,0,0,0),
          c(-1,1,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__unpaired_ttest.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0),
          c(-1,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__singlegroup_ttest_vxlEV.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0),
          c(-1,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__singlegroup_ttest.txt'),col.names=F,row.names=F,quote=F)
    
    ## One-sample t-test: clinical correlations
    # Initialize clinical data
    df.delta <- read_csv(csvfile,
                        col_select = c('pseudonym','ParticipantType','TimepointNr',
                                       'Up3OnBradySum','z_MoCA__total', 'LEDD')) %>%
        filter(ParticipantType == 'PD_POM',
               TimepointNr != 1) %>%
        pivot_wider(id_cols = c('pseudonym','ParticipantType'),
                    names_from = 'TimepointNr',
                    values_from = c('Up3OnBradySum','z_MoCA__total', 'LEDD'),
                    names_prefix = 'T') %>%
        mutate(Up3OnBradySum_Delta = Up3OnBradySum_T2 - Up3OnBradySum_T0,
               z_MoCA__total_Delta = z_MoCA__total_T2 - z_MoCA__total_T0,
               LEDD_Delta = LEDD_T2 - LEDD_T0)
    # Add covariates and clinical variables
    df.delta <- dfinit %>%
        filter(ParticipantType=='PD_POM') %>%
        left_join(., baseline_covars[,1:9], by=c('pseudonym','ParticipantType')) %>%
        left_join(., df.delta)
    # Select variables
    df.delta.s <- df.delta %>%
        select(Up3OnBradySum_Delta,Up3OnBradySum_T0,
               z_MoCA__total_Delta,z_MoCA__total_T0,
               LEDD_Delta, LEDD_T0,
               Age,Gender,NpsEducYears,YearsSinceDiag,RespHandIsDominant)
    # Impute missing values
    isna <- apply(df.delta.s, 2, is.na) %>% colSums()
    missing_perc <- round(isna/nrow(df.delta.s), digits = 3)*100
    print(missing_perc)
    df.delta.s.imp <- df.delta.s %>%
        mice(m=round(5*missing_perc[names(missing_perc)=='Up3OnBradySum_Delta']),
             maxit = 10,
             method='pmm',
             seed=157,
             print=FALSE) %>%
        complete() %>%
        as_tibble()
    # Demean
    df.delta.s.imp <- df.delta.s.imp %>%
        mutate(Up3OnBradySum_Delta = Up3OnBradySum_Delta - mean(Up3OnBradySum_Delta),
               Up3OnBradySum_T0 = Up3OnBradySum_T0 - mean(Up3OnBradySum_T0),
               z_MoCA__total_Delta = z_MoCA__total_Delta - mean(z_MoCA__total_Delta),
               z_MoCA__total_T0 = z_MoCA__total_T0 - mean(z_MoCA__total_T0),
               LEDD_Delta = LEDD_Delta - mean(LEDD_Delta),
               LEDD_T0 = LEDD_T0 - mean(LEDD_T0),
               Age = Age - mean(Age),
               Gender = Gender - mean(Gender),
               NpsEducYears = NpsEducYears - mean(NpsEducYears),
               YearsSinceDiag = YearsSinceDiag - mean(YearsSinceDiag),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               Mean=1,
               vxlEV=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Non-imputed data set
    ## TO DO: Write out files
    df.delta.no_imp <- df.delta %>% na.omit()
    df.delta.s.no_imp <- df.delta.s %>% na.omit()
    df.delta.s.no_imp <- df.delta.s.imp %>%
        mutate(Up3OnBradySum_Delta = Up3OnBradySum_Delta - mean(Up3OnBradySum_Delta),
               Up3OnBradySum_T0 = Up3OnBradySum_T0 - mean(Up3OnBradySum_T0),
               z_MoCA__total_Delta = z_MoCA__total_Delta - mean(z_MoCA__total_Delta),
               z_MoCA__total_T0 = z_MoCA__total_T0 - mean(z_MoCA__total_T0),
               LEDD_Delta = LEDD_Delta - mean(LEDD_Delta),
               LEDD_T0 = LEDD_T0 - mean(LEDD_T0),
               Age = Age - mean(Age),
               Gender = Gender - mean(Gender),
               NpsEducYears = NpsEducYears - mean(NpsEducYears),
               YearsSinceDiag = YearsSinceDiag - mean(YearsSinceDiag),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               Mean=1,
               vxlEV=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Write
    write_delim(df.delta[,4], paste0(outputdir, '/imgs__delta_clincorr.txt'), col_names = F)
    write_delim(df.delta[,5], paste0(outputdir, '/imgs__ba_clincorr.txt'), col_names = F)
    write_delim(df.delta[,6], paste0(outputdir, '/imgs__fu_clincorr.txt'), col_names = F)
    # Brady + MoCA + LEDD
    write_delim(df.delta.s.imp, paste0(outputdir, '/covs__delta_clincorr_all_vxlEV.txt'), col_names = F)
    df.delta.s.imp %>%
        select(-c('vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_all.txt'), col_names = F)
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'z_MoCA__total_Delta', 'LEDD_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__ba_clincorr_all.txt'), col_names = F)
    df.delta.s.imp %>%
        mutate(Up3OnBradySum_T0 = Up3OnBradySum_T0 + Up3OnBradySum_Delta,
               z_MoCA__total_T0 = Up3OnBradySum_Delta + Up3OnBradySum_T0,
               LEDD_T0 = LEDD_T0 + LEDD_Delta,
               across(where(is.numeric), \(x) round(x, digits=3))) %>%
        rename(Up3OnBradySum_T2 = Up3OnBradySum_T0,
               z_MoCA__total_T2 = z_MoCA__total_T0,
               LEDD_T2 = LEDD_T0) %>%
        select(-c('z_MoCA__total_Delta', 'Up3OnBradySum_Delta', 'LEDD_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__fu_clincorr_all.txt'), col_names = F)
    # Bradykinesia
        # Delta: Voxel-wise EV
    df.delta.s.imp %>%
        select(-c('z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'LEDD_T0')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_brady_vxlEV.txt'), col_names = F)
        # Delta: Un-adjusted
    df.delta.s.imp %>%
        select(-c('z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'LEDD_T0', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_brady.txt'), col_names = F)
        # Baseline
    df.delta.s.imp %>%
        select(-c('z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'LEDD_T0', 'Up3OnBradySum_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__ba_clincorr_brady.txt'), col_names = F)
        # Follow-up
    df.delta.s.imp %>%
        mutate(Up3OnBradySum_T0 = Up3OnBradySum_T0 + Up3OnBradySum_Delta,
               across(where(is.numeric), \(x) round(x, digits=3))) %>%
        rename(Up3OnBradySum_T2 = Up3OnBradySum_T0) %>%
        select(-c('z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'LEDD_T0', 'Up3OnBradySum_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__fu_clincorr_brady.txt'), col_names = F)
    # MoCA
        # Delta: Voxel-wise EV
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'LEDD_Delta', 'LEDD_T0')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_moca_vxlEV.txt'), col_names = F)
        # Delta: Un-adjusted
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'LEDD_Delta', 'LEDD_T0', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_moca.txt'), col_names = F)
        # Baseline
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'LEDD_Delta', 'LEDD_T0', 'z_MoCA__total_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__ba_clincorr_moca.txt'), col_names = F)
        # Follow-up
    df.delta.s.imp %>%
        mutate(z_MoCA__total_T0 = z_MoCA__total_T0 + z_MoCA__total_Delta,
               across(where(is.numeric), \(x) round(x, digits=3))) %>%
        rename(z_MoCA__total_T2 = z_MoCA__total_T0) %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'LEDD_Delta', 'LEDD_T0', 'z_MoCA__total_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__fu_clincorr_moca.txt'), col_names = F)
    # LEDD
        # Delta: Voxel-wise EV
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'z_MoCA__total_Delta', 'z_MoCA__total_T0')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_LEDD_vxlEV.txt'), col_names = F)
        # Delta: Un-adjusted
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'z_MoCA__total_Delta', 'z_MoCA__total_T0', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__delta_clincorr_LEDD.txt'), col_names = F)
        # Baseline
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__ba_clincorr_LEDD.txt'), col_names = F)
        # Follow-up
    df.delta.s.imp %>%
        mutate(LEDD_T0 = LEDD_T0 + LEDD_Delta,
               across(where(is.numeric), \(x) round(x, digits=3))) %>%
        rename(LEDD_T2 = LEDD_T0) %>%
        select(-c('Up3OnBradySum_Delta', 'Up3OnBradySum_T0', 'z_MoCA__total_Delta', 'z_MoCA__total_T0', 'LEDD_Delta', 'vxlEV')) %>%
        write_delim(., paste0(outputdir, '/covs__fu_clincorr_LEDD.txt'), col_names = F)
    
    # Contrasts
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all_vxlEV_AddCov2.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all_vxlEV_AddCov1.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all_vxlEV.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all_AddCov2.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all_AddCov1.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0,0,0,0),
          c(0,0,1,0,0,0,0,0,0,0,0,0),
          c(0,0,-1,0,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_all.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_one_vxlEV.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__delta_clincorr_one.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0,0,0),
          c(0,1,0,0,0,0,0,0,0),
          c(0,-1,0,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__ses_clincorr_all.txt'),col.names=F,row.names=F,quote=F)
    rbind(c(1,0,0,0,0,0,0),
          c(-1,0,0,0,0,0,0)) %>% write.table(., paste0(outputdir, '/cons__ses_clincorr_one.txt'),col.names=F,row.names=F,quote=F)
    
}

# Generates output files for each sessions, separately, containing all subjects
fsl_randomise_covars_byses <- function(condir, csvfile, timepointnr, outputdir){
    
    library(tidyverse)
    library(mice)
    library(miceadds)
    
    dir.create(outputdir, showWarnings = F, recursive = T)
    
    # Initialize data frame
    imgs = list.files(condir)
    imgs_fp = list.files(condir,full.names = T) %>%
        str_replace('P:','/project')
    group = str_sub(imgs, start = 1, end = 6)
    pseudonym = str_sub(imgs, start = 8, end = 31)
    dfinit <- tibble(pseudonym=pseudonym,ParticipantType=group,imgs=imgs,imgs_fp=imgs_fp) %>%
        filter(group != 'PD_PIT')
    
    # Select baseline covars
    baseline_covars <- read_csv(csvfile,
                                col_select = c('pseudonym','ParticipantType','TimepointNr','Age',
                                               'Gender','NpsEducYears','YearsSinceDiag','PrefHand')) %>%
        filter(ParticipantType != 'PD_PIT') %>%
        mutate(Gender=if_else(Gender=='Female',0,1),
               TimepointNr = if_else(ParticipantType=='HC_PIT' & TimepointNr==1, 2, TimepointNr)) %>%
        filter(TimepointNr == 0)
    
    source("M:/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_resphand.R")
    resphand <- retrieve_resphand() %>% 
        rename(ParticipantType=Group) %>% 
        mutate(TimepointNr=if_else(str_detect(Timepoint,'Visit1'),0,2)) %>%
        filter(TimepointNr==0) %>%
        select(pseudonym,ParticipantType,RespondingHand)
    baseline_covars <- baseline_covars %>%
        left_join(., resphand, by = c('pseudonym','ParticipantType')) %>%
        mutate(RespHandIsDominant = if_else(RespondingHand == PrefHand | PrefHand == 'NoPref',1,0)) %>%
        select(-c(PrefHand,RespondingHand,TimepointNr))
    
    ## Unpaired t-tests: pd vs hc
    # Add covariates
    df <- dfinit %>%
        left_join(., baseline_covars[,c('pseudonym','ParticipantType',
                                        'Age','Gender','NpsEducYears','RespHandIsDominant')], 
                  by=c('pseudonym','ParticipantType')) %>%
        mutate(HC=if_else(ParticipantType=='HC_PIT',1,0),
               PD=if_else(ParticipantType=='PD_POM',1,0)) %>%
        na.omit()
    # Select and demean
    df.s <- df %>% 
        select(HC,PD,Age,Gender,NpsEducYears,RespHandIsDominant) %>%
        mutate(Age=Age-mean(Age),
               Gender=Gender-mean(Gender),
               NpsEducYears=NpsEducYears-mean(NpsEducYears),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Write to file
    write_delim(df[,'imgs_fp'], paste0(outputdir, paste0('/imgs__unpaired_ttest_unmatched.txt')), col_names = F)
    write_delim(df.s, paste0(outputdir, paste0('/covs__unpaired_ttest_unmatched.txt')), col_names = F)
    
    tmp <- df.s %>% filter(HC == 1) %>% select(-PD)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gHC__covs__unpaired_ttest_unmatched.txt'), col_names = F)
    tmp <- df.s %>% filter(PD == 1) %>% select(-HC)
    tmp %>% write_delim(., paste0(outputdir, '/posthoc_gPD__covs__unpaired_ttest_unmatched.txt'), col_names = F)
    
    ## One-sample t-test: clinical correlations
    # Initialize clinical data
    df.delta <- read_csv(csvfile,
                         col_select = c('pseudonym','ParticipantType','TimepointNr',
                                        'Up3OnBradySum','z_MoCA__total', 'LEDD')) %>%
        filter(ParticipantType == 'PD_POM',
               TimepointNr == timepointnr)
    # Add covariates and clinical variables
    df.delta <- dfinit %>%
        filter(ParticipantType=='PD_POM') %>%
        left_join(., baseline_covars[,1:7], by=c('pseudonym','ParticipantType')) %>%
        left_join(., df.delta)
    # Select variables
    df.delta.s <- df.delta %>%
        select(Up3OnBradySum,
               z_MoCA__total,
               LEDD,
               Age,Gender,NpsEducYears,YearsSinceDiag,RespHandIsDominant)
    # Impute missing values
    isna <- apply(df.delta.s, 2, is.na) %>% colSums()
    missing_perc <- round(isna/nrow(df.delta.s), digits = 3)*100
    print(missing_perc)
    df.delta.s.imp <- df.delta.s %>%
        mice(m=round(5*missing_perc[names(missing_perc)=='Up3OnBradySum']),
             maxit = 10,
             method='pmm',
             seed=157,
             print=FALSE) %>%
        complete() %>%
        as_tibble()
    # Demean
    df.delta.s.imp <- df.delta.s.imp %>%
        mutate(Up3OnBradySum = Up3OnBradySum - mean(Up3OnBradySum),
               z_MoCA__total = z_MoCA__total - mean(z_MoCA__total),
               LEDD = LEDD - mean(LEDD),
               Age = Age - mean(Age),
               Gender = Gender - mean(Gender),
               NpsEducYears = NpsEducYears - mean(NpsEducYears),
               YearsSinceDiag = YearsSinceDiag - mean(YearsSinceDiag),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               Mean=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Non-imputed data set
    ## TO DO: Write out files
    df.delta.no_imp <- df.delta %>% na.omit()
    df.delta.s.no_imp <- df.delta.s %>% na.omit()
    df.delta.s.no_imp <- df.delta.s.imp %>%
        mutate(Up3OnBradySum = Up3OnBradySum - mean(Up3OnBradySum),
               z_MoCA__total = z_MoCA__total - mean(z_MoCA__total),
               LEDD = LEDD - mean(LEDD),
               Age = Age - mean(Age),
               Gender = Gender - mean(Gender),
               NpsEducYears = NpsEducYears - mean(NpsEducYears),
               YearsSinceDiag = YearsSinceDiag - mean(YearsSinceDiag),
               RespHandIsDominant = RespHandIsDominant - mean(RespHandIsDominant),
               Mean=1,
               across(where(is.numeric), \(x) round(x, digits=3)))
    # Write
    write_delim(df.delta[,4], paste0(outputdir, '/imgs__clincorr.txt'), col_names = F)
    # Brady + MoCA + LEDD
    write_delim(df.delta.s.imp, paste0(outputdir, '/covs__clincorr_all.txt'), col_names = F)
    # Bradykinesia
    df.delta.s.imp %>%
        select(-c('z_MoCA__total', 'LEDD')) %>%
        write_delim(., paste0(outputdir, '/covs__clincorr_brady.txt'), col_names = F)
    # MoCA
    # Delta: Voxel-wise EV
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum', 'LEDD')) %>%
        write_delim(., paste0(outputdir, '/covs__clincorr_moca.txt'), col_names = F)
    # LEDD
    # Delta: Voxel-wise EV
    df.delta.s.imp %>%
        select(-c('Up3OnBradySum', 'z_MoCA__total')) %>%
        write_delim(., paste0(outputdir, '/covs__clincorr_LEDD.txt'), col_names = F)
    
}

csvfile='P:/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2023-10-18.csv'
con=c('con_0007','con_0010')#,'con_0011','con_0012')
for(i in 1:length(con)){
    # Complete case analyses (only participants with both sessions)
    condir1=paste0('P:/3024006.02/Analyses/motor_task/Group/', con[i], '/ses-Diff/')
    condir2=paste0('P:/3024006.02/Analyses/motor_task/Group/', con[i], '/COMPLETE_ses-Visit1/')
    condir3=paste0('P:/3024006.02/Analyses/motor_task/Group/', con[i], '/COMPLETE_ses-Visit2/')
    outputdir=paste0('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/', con[i])
    fsl_randomise_covars(condir1, condir2, condir3, csvfile, outputdir)
    
    # By-session analyses (full number of participants for each session)
    condir=paste0('P:/3024006.02/Analyses/motor_task/Group/', con[i], '/ses-Visit1/')
    timepointnr=0
    outputdir=paste0('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/', con[i], '/by_session/ses-Visit1/')
    fsl_randomise_covars_byses(condir,csvfile,timepointnr,outputdir)
    condir=paste0('P:/3024006.02/Analyses/motor_task/Group/', con[i], '/ses-Visit2/')
    timepointnr=2
    outputdir=paste0('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/data/', con[i], '/by_session/ses-Visit2/')
    fsl_randomise_covars_byses(condir,csvfile,timepointnr,outputdir)
}
