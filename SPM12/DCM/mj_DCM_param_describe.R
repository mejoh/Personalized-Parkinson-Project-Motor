library(tidyverse)
library(GGally)
library(lme4)
library(lmerTest)
library(car)
library(ggeffects)

# Load DCM and clinical data
paramfile <- c('P:/3024006.02/Analyses/motor_task_dcm_03/DCM/04_Param/DCMpar_ses-collated_c-full_r-M1-PMd-PUT_PEB-0.csv',
               'P:/3024006.02/Analyses/motor_task_dcm_03/DCM/04_Param/DCMpar_ses-collated_c-full_r-M1-PMd-PUT_spectral_PEB-0.csv')
df.dcm <- read_csv(paramfile[2])
df.clin <- read_csv('P:/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2024-07-17.csv',show_col_types = F) %>%
    select(pseudonym,ParticipantType,Timepoint,Up3OfBradySum,Up3OnBradySum,z_MoCA__total,Age,Gender,YearsSinceDiag,NpsEducYears) %>%
    filter(ParticipantType != 'PD_PIT')
ptype <- df.clin %>%
    select(pseudonym,ParticipantType) %>%
    unique()
df.dcm <- df.dcm %>%
    left_join(ptype, by = 'pseudonym') %>%
    mutate(TimepointNr = if_else(str_detect(Timepoint,'Visit1'),0,1),
           TimepointNr = factor(TimepointNr),
           ParticipantType = factor(ParticipantType)) %>%
    relocate(pseudonym,ParticipantType, TimepointNr)

# Write data for glmnet
df.dcm.glmnet <- df.dcm %>%
    filter(!(ParticipantType == 'PD_POM' & Timepoint == 'ses-PITVisit1')) %>%
    mutate(Timepoint = str_sub(Timepoint,13,13),
           Timepoint = if_else(Timepoint==1,'T0','T2')) %>%
    pivot_longer(cols = where(is.numeric),
                 names_to = 'par',
                 values_to = 'Hz') %>%
    pivot_wider(id_cols = c('pseudonym','ParticipantType','par'),
                names_from = 'Timepoint',
                values_from = 'Hz') %>%
    mutate(Td = T2-T0) %>%
    pivot_wider(id_cols = c('pseudonym','ParticipantType'),
                names_from = 'par',
                names_glue = '{par}_{.value}',
                values_from = c('T0','T2','Td'))
df.dcm.glmnet %>%
    filter(ParticipantType=='PD_POM') %>%
    select(!ParticipantType) %>%
    write_csv('P:/3024006.02/Data/GLMNET_NatComm/glmnet_func_dcmpar.csv')

# A: Fixed
df.dcm.a <- df.dcm %>%
    filter(!(ParticipantType == 'PD_POM' & Timepoint == 'ses-PITVisit1')) %>%
    select(pseudonym,ParticipantType,Timepoint,starts_with('A_')) %>%
    pivot_longer(cols = (starts_with('A_')),
                 names_to = 'par',
                 values_to = 'val') %>%
    left_join(df.clin, by = c('pseudonym','ParticipantType','Timepoint'))
df.dcm.a %>%
    ggplot(aes(x=factor(Timepoint),y=val, color=ParticipantType)) +
    geom_boxplot() + 
    stat_summary(fun.data = 'mean_cl_boot', geom = 'point', color='darkred', size=1.5, 
                 mapping = aes(group=ParticipantType), position = position_dodge(width=0.8)) +
    facet_wrap(~par, scales = 'free_y')
df.dcm.a %>%
    filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3') %>%
    pivot_wider(id_cols = c('pseudonym','Timepoint','Up3OfBradySum','Up3OnBradySum'),
                names_from = 'par',
                values_from = 'val') %>%
    select(!pseudonym) %>%
    ggpairs(lower = list(continuous = 'smooth'),
            aes(color=factor(Timepoint),alpha=0.5))

# B: Modulation
df.dcm.b <- df.dcm %>%
    filter(!(ParticipantType == 'PD_POM' & Timepoint == 'ses-PITVisit1')) %>%
    select(pseudonym,ParticipantType,Timepoint,starts_with('B_')) %>%
    pivot_longer(cols = (starts_with('B_')),
                 names_to = 'par',
                 values_to = 'val') %>%
    left_join(df.clin, by = c('pseudonym','ParticipantType','Timepoint'))
df.dcm.b %>%
    ggplot(aes(x=factor(Timepoint),y=val,color=ParticipantType)) +
    geom_boxplot() + 
    stat_summary(fun.data = 'mean_cl_boot', geom = 'point', color='darkred', size=1.5, 
                 mapping = aes(group=ParticipantType), position = position_dodge(width=0.8)) +
    facet_wrap(~par, scales = 'free_y')
df.dcm.b %>%
    filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3') %>%
    pivot_wider(id_cols = c('pseudonym','Timepoint','Up3OfBradySum','Up3OnBradySum'),
                names_from = 'par',
                values_from = 'val') %>%
    select(!pseudonym) %>%
    ggpairs(lower = list(continuous = 'smooth'),
            aes(color=factor(Timepoint),alpha=0.5))
# C: Input
df.dcm.c <- df.dcm %>%
    filter(!(ParticipantType == 'PD_POM' & Timepoint == 'ses-PITVisit1')) %>%
    select(pseudonym,ParticipantType,Timepoint,starts_with('C_')) %>%
    select(!ends_with('C2')) %>%
    pivot_longer(cols = (starts_with('C_')),
                 names_to = 'par',
                 values_to = 'val') %>%
    left_join(df.clin, by = c('pseudonym','ParticipantType','Timepoint'))
df.dcm.c %>%
    ggplot(aes(x=factor(Timepoint),y=val,color=ParticipantType)) +
    geom_boxplot() + 
    stat_summary(fun.data = 'mean_cl_boot', geom = 'point', color='darkred', size=1.5, 
                 mapping = aes(group=ParticipantType), position = position_dodge(width=0.8)) +
    facet_wrap(~par, scales = 'free_y')
df.dcm.c %>%
    filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3') %>%
    pivot_wider(id_cols = c('pseudonym','Timepoint','Up3OfBradySum','Up3OnBradySum'),
                names_from = 'par',
                values_from = 'val') %>%
    select(!pseudonym) %>%
    ggpairs(lower = list(continuous = 'smooth'),
            aes(color=factor(Timepoint),alpha=0.5))

# Longitudinal correlations
# A
params <- c('A_To1_From1','A_To1_From2','A_To1_From3',
            'A_To2_From1','A_To2_From2','A_To2_From3',
            'A_To3_From1','A_To3_From2','A_To3_From3')
pvals.a <- c()
pvals.spear <- c()
for(i in params){
    df.longcor <- df.dcm.a %>%
        filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3',
               par == i) %>%
        select(pseudonym,Timepoint,val,Up3OnBradySum,z_MoCA__total,Age,Gender,YearsSinceDiag,NpsEducYears) %>%
        mutate(Timepoint = if_else(Timepoint=='ses-POMVisit1','T0','T1')) %>%
        pivot_wider(id_cols = c('pseudonym','Age','Gender','YearsSinceDiag','NpsEducYears'),
                    names_from = 'Timepoint',
                    values_from = c('val','Up3OnBradySum','z_MoCA__total')) %>%
        mutate(val_T1sub0 = val_T1-val_T0,
               Up3OnBradySum_T1sub0 = Up3OnBradySum_T1-Up3OnBradySum_T0,
               z_MoCA__total_T1sub0 = z_MoCA__total_T1-z_MoCA__total_T0,
               Gender=factor(Gender)) %>%
        na.omit() %>%
        filter(Up3OnBradySum_T1sub0>-20)
    m <- lm(Up3OnBradySum_T1sub0 ~ + val_T0 + val_T1sub0 + Up3OnBradySum_T0 + Age + Gender + NpsEducYears + YearsSinceDiag, data = df.longcor)
    spear <- cor.test(df.longcor$Up3OnBradySum_T1sub0,df.longcor$val_T1sub0,method='spearman')
    s <- summary(m)
    a <- Anova(m)
    print(a)
    print(spear)
    pvals.a <- c(pvals.a,round(s$coefficients[3,4], digits=5))
    pvals.spear <- c(pvals.spear,round(spear$p.value, digits=5))
}
names(pvals.a) <- params
names(pvals.spear) <- params
print(pvals.a)
print(pvals.spear)
# B
params <- c('B_To1_From1','B_To1_From2','B_To1_From3',
            'B_To2_From1','B_To2_From2','B_To2_From3',
            'B_To3_From1','B_To3_From2','B_To3_From3')
pvals.a <- c()
pvals.spear <- c()
for(i in params){
    df.longcor <- df.dcm.b %>%
        filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3',
               par == i) %>%
        select(pseudonym,Timepoint,val,Up3OnBradySum,z_MoCA__total,Age,Gender,YearsSinceDiag,NpsEducYears) %>%
        mutate(Timepoint = if_else(Timepoint=='ses-POMVisit1','T0','T1')) %>%
        pivot_wider(id_cols = c('pseudonym','Age','Gender','YearsSinceDiag','NpsEducYears'),
                    names_from = 'Timepoint',
                    values_from = c('val','Up3OnBradySum')) %>%
        mutate(val_T1sub0 = val_T1-val_T0,
               Up3OnBradySum_T1sub0 = Up3OnBradySum_T1-Up3OnBradySum_T0,
               Gender=factor(Gender)) %>%
        na.omit() %>%
        filter(Up3OnBradySum_T1sub0>-20)
    m <- lm(Up3OnBradySum_T1sub0 ~ + val_T0 + val_T1sub0 + Up3OnBradySum_T0 + Age + Gender + NpsEducYears + YearsSinceDiag, data = df.longcor)
    spear <- cor.test(df.longcor$Up3OnBradySum_T1sub0,df.longcor$val_T1sub0,method='spearman')
    s <- summary(m)
    a <- Anova(m)
    print(a)
    pvals.a <- c(pvals.a,round(s$coefficients[3,4], digits=5))
    pvals.spear <- c(pvals.spear,round(spear$p.value, digits=5))
}
names(pvals.a) <- params
names(pvals.spear) <- params
print(pvals.a)
print(pvals.spear)
# C
params <- c('C_To1_From1','C_To2_From1','C_To3_From1')
pvals.a <- c()
pvals.spear <- c()
for(i in params){
    df.longcor <- df.dcm.c %>%
        filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3',
               par == i) %>%
        select(pseudonym,Timepoint,val,Up3OnBradySum,z_MoCA__total,Age,Gender,YearsSinceDiag,NpsEducYears) %>%
        mutate(Timepoint = if_else(Timepoint=='ses-POMVisit1','T0','T1')) %>%
        pivot_wider(id_cols = c('pseudonym','Age','Gender','YearsSinceDiag','NpsEducYears'),
                    names_from = 'Timepoint',
                    values_from = c('val','Up3OnBradySum')) %>%
        mutate(val_T1sub0 = val_T1-val_T0,
               Up3OnBradySum_T1sub0 = Up3OnBradySum_T1-Up3OnBradySum_T0,
               Gender=factor(Gender)) %>%
        na.omit() %>%
        filter(Up3OnBradySum_T1sub0>-20)
    m <- lm(Up3OnBradySum_T1sub0 ~ + val_T0 + val_T1sub0 + Up3OnBradySum_T0 + Age + Gender + NpsEducYears + YearsSinceDiag, data = df.longcor)
    spear <- cor.test(df.longcor$Up3OnBradySum_T1sub0,df.longcor$val_T1sub0,method='spearman')
    s <- summary(m)
    a <- Anova(m)
    print(a)
    pvals.a <- c(pvals.a,round(s$coefficients[3,4], digits=5))
    pvals.spear <- c(pvals.spear,round(spear$p.value, digits=5))
}
names(pvals.a) <- params
names(pvals.spear) <- params
print(pvals.a)
print(pvals.spear)

# Focused on B_To1_FromC2 and B_To2_From2
df.longcor <- df.dcm.b %>%
    filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-POMVisit3',
           par == 'B_To2_From2') %>%
    select(pseudonym,Timepoint,val,Up3OnBradySum,z_MoCA__total,Age,Gender,YearsSinceDiag,NpsEducYears) %>%
    mutate(Timepoint = if_else(Timepoint=='ses-POMVisit1','T0','T1')) %>%
    pivot_wider(id_cols = c('pseudonym','Age','Gender','YearsSinceDiag','NpsEducYears'),
                names_from = 'Timepoint',
                values_from = c('val','Up3OnBradySum','z_MoCA__total')) %>%
    mutate(val_T1sub0 = val_T1-val_T0,
           Up3OnBradySum_T1sub0 = Up3OnBradySum_T1-Up3OnBradySum_T0,
           z_MoCA__total_T1sub0 = z_MoCA__total_T1-z_MoCA__total_T0,
           Gender=factor(Gender)) %>%
    na.omit() %>%
    filter(Up3OnBradySum_T1sub0>-20)
m <- lm(val_T1sub0 ~ + val_T0 + Up3OnBradySum_T1sub0 + Up3OnBradySum_T0 + Age + Gender + NpsEducYears + YearsSinceDiag, data = df.longcor)
s <- summary(m)
a <- Anova(m)
print(a)

pred <- ggpredict(m, terms='Up3OnBradySum_T1sub0')
g <- plot(pred, add.data = TRUE,color='darkred') + theme_bw() + ggtitle('Dorsal premotor cortex') +
    ylab('Change in selection modulation of PMd>M1 (B)') + xlab('Change in bradykinesia (ON)') +
    annotate('text',y=-3,x=-20,
             label=paste0('N=',length(predict(m)), ', ',
                          'β=',round(s$coefficients[3,1], digits=5), ', ',
                          'SE=',round(s$coefficients[3,2], digits=5), ', ',
                          'P=',round(s$coefficients[3,4], digits=5)), 
             hjust=0) +
    ylim(-3,3) + 
    geom_hline(yintercept = 0, color = 'darkgrey', lty = 2) + geom_vline(xintercept = 0, color = 'darkgrey', lty = 2)
print(g)

df.longcor %>%
    ggplot(aes(y=val_T1sub0,x=Up3OnBradySum_T1sub0)) + 
    geom_point() + 
    geom_smooth(method='lm', color = 'darkred')
cor.test(df.longcor$Up3OnBradySum_T1sub0,df.longcor$val_T1sub0,method='spearman')

# Does B_To1_FromC2 and B_To2_From2 correlate with previous findings of 
read_fmri <- function(fname){
    dat <- read_csv(fname, col_names = F) %>%
        mutate(X1=basename(X1),
               pseudonym = str_sub(X1, 8,31),
               ParticipantType = str_sub(X1, 1,6),
               ParticipantType = if_else(ParticipantType=='PD_POM','Patient','Healthy')) %>%
        relocate(pseudonym,ParticipantType) %>%
        select(-c(X1))
    dat
}
df.PMd_comp <- read_fmri('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/stats/con_0007/vals/rand_delta_clincorr_all_vxlEV_tfce_corrp_tstat2_stats_stats_avg_agg.txt') %>%
    rename(R_PMd_T2sub0=X2,L_PMd_T2sub0=X3) %>%
    left_join(., read_fmri('P:/3024006.02/Analyses/motor_task/Group/Longitudinal/FSL/stats/con_0007/vals/rand_delta_clincorr_all_vxlEV_tfce_corrp_tstat2_stats_BASELINE_stats_avg_agg.txt')) %>%
    rename(R_PMd_T0=X2,L_PMd_T0=X3) %>%
    mutate(PMd_T2sub0 = (R_PMd_T2sub0+L_PMd_T2sub0) / 2,
           PMd_T0 = (R_PMd_T0+L_PMd_T0) / 2,
           PMd_T1 = PMd_T0+PMd_T2sub0)
df.PMd_comp <- df.longcor %>%
    left_join(df.PMd_comp %>% select(!c(ParticipantType)), by = 'pseudonym')
df.PMd_comp %>% 
    select(PMd_T2sub0, val_T1sub0, PMd_T0, PMd_T1, val_T0, val_T1) %>%
    ggpairs(lower = list(continuous = 'smooth'),
        aes(alpha=0.5))
m <- lm(val_T1sub0 ~ PMd_T2sub0 + val_T0 + PMd_T0, data = df.PMd_comp)
s <- summary(m)
a <- Anova(m)
pred <- ggpredict(m, terms='PMd_T2sub0')
g <- plot(pred, add.data = TRUE,color='darkred') + theme_bw() + ggtitle('Correlation between PMd activity and DCM parameter') +
    ylab('Change in selection modulation of B connection') + xlab('Change in selection-related PMd activity') +
    annotate('text',y=-2.5,x=-2.5,
             label=paste0('N=',length(predict(m)), ', ',
                          'β=',round(s$coefficients[2,1], digits=5), ', ',
                          'SE=',round(s$coefficients[2,2], digits=5), ', ',
                          'P=',round(s$coefficients[2,4], digits=5)), 
             hjust=0) +
    ylim(-3,3.5) + 
    geom_hline(yintercept = 0, color = 'darkgrey', lty = 2) + geom_vline(xintercept = 0, color = 'darkgrey', lty = 2)
print(g)
cor.test(df.PMd_comp$PMd_T2sub0,df.PMd_comp$val_T1sub0,method='spearman')
