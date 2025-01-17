library(tidyverse)
library(readxl)

datadir='/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/FromRoy'
df.non_andi <- paste0(datadir,'/POM_normative_analyses_T0-T1-T2_(Non-andi-tests).csv') %>%
        read_csv()
df.andi_t0 <- paste0(datadir,'/ANDI_Univariate_Norms_T0_subject_1-520_analyzed_October_2023.xlsx') %>%
        read_excel() %>%
        mutate(TimepointNr=0) %>%
        rename(pseudonym=Patiënt, test_variable=`Test (variabele)`, test_id=`Test ID`) %>%
        relocate(pseudonym,TimepointNr)
df.andi_t1 <- paste0(datadir,'/ANDI_Univariate_Norms_T1_subject_1-438 analyzed_October_2023.xlsx') %>%
        read_excel() %>%
        mutate(TimepointNr=1) %>%
        rename(pseudonym=Patiënt, test_variable=`Test (variabele)`, test_id=`Test ID`) %>%
        relocate(pseudonym,TimepointNr)
df.andi_t2 <- paste0(datadir,'/ANDI_Univariate_Norms_T2_subject_1-487_analyzed_October_2023.xlsx') %>%
        read_excel() %>%
        mutate(TimepointNr=2) %>%
        rename(pseudonym=Patiënt, test_variable=`Test (variabele)`, test_id=`Test ID`) %>%
        relocate(pseudonym,TimepointNr)
df.andi <- bind_rows(df.andi_t0, df.andi_t1, df.andi_t2) %>%
        pivot_wider(id_cols = c('pseudonym','TimepointNr'),
                    values_from = c('Ruw','z'),
                    names_from = 'test_id')
df.andi <- df.andi %>%
        select(-contains('CFT__')) %>%
        mutate(Ruw_SF_Comb = coalesce(Ruw_SF__Animals,Ruw_SF__Occupations),
               z_SF__Comb = coalesce(z_SF__Animals,z_SF__Occupations))
df <- full_join(df.non_andi,df.andi, by=c('pseudonym','TimepointNr')) %>%
        mutate(ParticipantType='PD_POM') %>%
        relocate(pseudonym, ParticipantType)
df <- df %>%
        select(pseudonym,ParticipantType,TimepointNr,Age,Gender,NpsEducation,
               NpsMisModa90,SDMT_ORAL_90_Z_SCORE,NpsMisWaisRude,LetterNumSeq_Z_Score_edu_adjusted,NpsMisBenton,Benton_Z_SCORE,
               Ruw_AVLT__total_1_to_5,z_AVLT__total_1_to_5,Ruw_AVLT__delayed_recall_1_to_5,z_AVLT__delayed_recall_1_to_5,Ruw_AVLT__recognition_1_to_5,z_AVLT__recognition_1_to_5,
               Ruw_SF_Comb,z_SF__Comb,Ruw_LF__letter_1,z_LF__letter_1,Ruw_BSAT__no_errors,z_BSAT__no_errors,Ruw_MoCA__total,z_MoCA__total) %>%
        mutate(z_AVLT__mean = (z_AVLT__total_1_to_5+z_AVLT__delayed_recall_1_to_5+z_AVLT__recognition_1_to_5)/3,
               raw_AVLT__mean = (Ruw_AVLT__total_1_to_5+Ruw_AVLT__delayed_recall_1_to_5+Ruw_AVLT__recognition_1_to_5)/3,
               z_CognitiveComposite = (SDMT_ORAL_90_Z_SCORE+
                                               LetterNumSeq_Z_Score_edu_adjusted+
                                               Benton_Z_SCORE+
                                               z_AVLT__mean+
                                               z_SF__Comb+
                                               z_BSAT__no_errors)/6,
               z_CognitiveComposite2 = (SDMT_ORAL_90_Z_SCORE+
                                                LetterNumSeq_Z_Score_edu_adjusted+
                                                Benton_Z_SCORE+
                                                z_AVLT__mean+
                                                z_SF__Comb+
                                                z_LF__letter_1+
                                                z_BSAT__no_errors)/7,
               raw_CognitiveComposite = (NpsMisModa90+
                                                  NpsMisWaisRude+
                                                  NpsMisBenton+
                                                  raw_AVLT__mean+
                                                  Ruw_SF_Comb+
                                                  Ruw_BSAT__no_errors)/6,
               raw_CognitiveComposite2 = (NpsMisModa90+
                                                 NpsMisWaisRude+
                                                 NpsMisBenton+
                                                 raw_AVLT__mean+
                                                 Ruw_SF_Comb+
                                                 Ruw_LF__letter_1+
                                                 Ruw_BSAT__no_errors)/7)

# Error in files resulted in MoCA == 0 at follow-up. Set these to NA
idx <- df$Ruw_MoCA__total[df$TimepointNr==1] == 0
df$z_MoCA__total[df$TimepointNr==1][idx] <- NA
idx <- df$Ruw_MoCA__total[df$TimepointNr==2] == 0
df$z_MoCA__total[df$TimepointNr==2][idx] <- NA

df <- df %>%
        mutate(imp_SDMT_ORAL_90_Z_SCORE = if_else(SDMT_ORAL_90_Z_SCORE < -1.5,'Y','N'),
               imp_LetterNumSeq_Z_Score_edu_adjusted = if_else(LetterNumSeq_Z_Score_edu_adjusted < -1.5,'Y','N'),
               imp_Benton_Z_SCORE = if_else(Benton_Z_SCORE < -1.5,'Y','N'),
               imp_z_AVLT__total_1_to_5 = if_else(z_AVLT__total_1_to_5 < -1.5,'Y','N'),
               imp_z_AVLT__delayed_recall_1_to_5 = if_else(z_AVLT__delayed_recall_1_to_5 < -1.5,'Y','N'),
               imp_z_AVLT__recognition_1_to_5 = if_else(z_AVLT__recognition_1_to_5 < -1.5,'Y','N'),
               imp_z_SF__Comb = if_else(z_SF__Comb < -1.5,'Y','N'),
               imp_z_LF__letter_1 = if_else(z_LF__letter_1 < -1.5,'Y','N'),
               imp_z_BSAT__no_errors = if_else(z_BSAT__no_errors < -1.5,'Y','N'),
               imp_z_MoCA__total = if_else(z_MoCA__total < -1.5,'Y','N'),
               imp_z_AVLT__mean = if_else(z_AVLT__mean < -1.5,'Y','N'),
               imp_z_CognitiveComposite = if_else(z_CognitiveComposite < -1.5,'Y','N'),
               imp_z_CognitiveComposite2 = if_else(z_CognitiveComposite2 < -1.5,'Y','N'))

write_csv(df, file = '/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/adj_neuropsych_scores.csv')
df_spss <- df %>%
        filter(TimepointNr != 1) %>%
        pivot_wider(id_cols = c('pseudonym','ParticipantType'),
                    values_from = colnames(df[7:32]),
                    names_from = 'TimepointNr',
                    names_prefix = 'T')
write_csv(df_spss, file = '/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/adj_neuropsych_scores_spss.csv')

# Summary stats
library(vtable)
df %>%
        select(-c(ParticipantType,Age,Gender,NpsEducation)) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        st(., group = 'TimepointNr', 
           group.long = T,
           summ = c('notNA(x)','mean(x)','sd(x)','sd(x)/sqrt(length(x))','min(x)','max(x)'),
           summ.names = c('N','Mean','SD','SE','Min','Max'),
           title = 'Adjusted neuropsych scores',
           file = '/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/adj_neuropsych_scores')
# Longitudinal change
df %>%
        select(-c(ParticipantType,Age,Gender,NpsEducation)) %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        st(., group = 'TimepointNr', 
           group.long = F,
           group.test = T,
           title = 'Adjusted neuropsych scores')
df %>% 
        select(TimepointNr, raw_CognitiveComposite, z_CognitiveComposite,
               Ruw_MoCA__total, z_MoCA__total) %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        st(., group = 'TimepointNr', 
           group.long = F,
           group.test = T,
           title = 'Adjusted neuropsych scores')
df %>% 
        select(pseudonym, TimepointNr, raw_CognitiveComposite, Ruw_MoCA__total) %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        pivot_longer(cols = c('raw_CognitiveComposite', 'Ruw_MoCA__total'),
                     values_to = 'Value',
                     names_to = 'Score') %>%
        arrange(pseudonym) %>%
        ggplot(aes(y=Value,fill=TimepointNr)) + 
        geom_boxplot() + 
        facet_grid(~Score)
df %>% 
        select(pseudonym, TimepointNr,
               z_MoCA__total, z_CognitiveComposite) %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        pivot_longer(cols = c('z_MoCA__total', 'z_CognitiveComposite'),
                     values_to = 'Value',
                     names_to = 'Score') %>%
        arrange(pseudonym) %>%
        ggplot(aes(y=Value,fill=TimepointNr)) + 
        geom_boxplot() + 
        facet_grid(~Score)
        # Raw
df.cogcom_raw <- df %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        select(pseudonym, TimepointNr, NpsMisModa90, NpsMisWaisRude, NpsMisBenton, 
               Ruw_AVLT__total_1_to_5, Ruw_AVLT__delayed_recall_1_to_5, Ruw_AVLT__recognition_1_to_5,
               raw_AVLT__mean, Ruw_SF_Comb, Ruw_LF__letter_1, Ruw_BSAT__no_errors, Ruw_MoCA__total, raw_CognitiveComposite, raw_CognitiveComposite2)
df.cogcom_raw %>%
        pivot_longer(cols = where(is.numeric),
                     names_to = 'Score',
                     values_to = 'Value') %>%
        ggplot(aes(x=Score,y=Value,color=TimepointNr)) + 
        geom_boxplot()+ theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
        # Z
df.cogcom_z<- df %>%
        filter(TimepointNr != 1) %>%
        mutate(TimepointNr=factor(TimepointNr)) %>%
        select(pseudonym, TimepointNr,SDMT_ORAL_90_Z_SCORE,LetterNumSeq_Z_Score_edu_adjusted,Benton_Z_SCORE,
               z_AVLT__total_1_to_5,z_AVLT__delayed_recall_1_to_5,z_AVLT__recognition_1_to_5,z_AVLT__mean,
               z_SF__Comb,z_LF__letter_1,z_BSAT__no_errors,z_MoCA__total,z_CognitiveComposite, z_CognitiveComposite2)
df.cogcom_z %>%
        pivot_longer(cols = where(is.numeric),
                     names_to = 'Score',
                     values_to = 'Value') %>%
        ggplot(aes(x=Score,y=Value,color=TimepointNr)) + 
        geom_boxplot()+ theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
        # Moca vs Composite
df.cogcom_raw %>%
        ggplot(aes(x=raw_CognitiveComposite,y=Ruw_MoCA__total)) + 
        geom_point() + geom_smooth(method='lm') +
        facet_grid(~TimepointNr)
df.cogcom_raw_delta <- df.cogcom_raw %>%
        pivot_wider(id_cols = 'pseudonym',
                    values_from = c('Ruw_MoCA__total','raw_CognitiveComposite2'),
                    names_from = 'TimepointNr',
                    names_prefix = 'T') %>%
        mutate(d_MoCA = Ruw_MoCA__total_T2 - Ruw_MoCA__total_T0,
               d_CognitiveComposite2 = raw_CognitiveComposite2_T2 - raw_CognitiveComposite2_T0)
df.cogcom_raw_delta %>%
        ggplot(aes(x=d_MoCA,y=d_CognitiveComposite2)) + 
        geom_point() + 
        geom_smooth(method='lm')
df.cogcom_z %>%
        ggplot(aes(x=z_CognitiveComposite,y=z_MoCA__total)) + 
        geom_point() + geom_smooth(method='lm') +
        facet_grid(~TimepointNr)
df.cogcom_z_delta <- df.cogcom_z %>%
        pivot_wider(id_cols = 'pseudonym',
                    values_from = c('z_MoCA__total','z_CognitiveComposite2'),
                    names_from = 'TimepointNr',
                    names_prefix = 'T') %>%
        mutate(d_MoCA = z_MoCA__total_T2 - z_MoCA__total_T0,
               d_CognitiveComposite2 = z_CognitiveComposite2_T2 - z_CognitiveComposite2_T0)
df.cogcom_z_delta %>%
        ggplot(aes(x=d_MoCA,y=d_CognitiveComposite2)) + 
        geom_point() + 
        geom_smooth(method='lm')

# Compare against old
old <- read_csv('/project/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-28.csv',
                col_select = c('pseudonym','ParticipantType','TimepointNr','CognitiveComposite',
                               'NpsMisModa90', 'NpsMisWaisRude', 'NpsMisBenton',
                               'NpsMis15wRigTot','NpsMis15WrdDelRec','NpsMis15WrdRecognition',
                               'NpsMisSemFlu','NpsMocPhoFlu','NpsMisBrixton','NpsMocTotAns')) %>%
        filter(TimepointNr==0 | TimepointNr==2) %>%
        filter(ParticipantType=='PD_POM')
new.s <- df %>%
        select(pseudonym,ParticipantType,TimepointNr,z_CognitiveComposite,
               NpsMisModa90,NpsMisWaisRude,NpsMisBenton,Ruw_AVLT__total_1_to_5,
               Ruw_AVLT__delayed_recall_1_to_5,Ruw_AVLT__recognition_1_to_5,Ruw_SF_Comb,
               Ruw_LF__letter_1,Ruw_BSAT__no_errors,Ruw_MoCA__total) %>%
        rename(NpsMis15wRigTot=Ruw_AVLT__total_1_to_5,
               NpsMis15WrdDelRec=Ruw_AVLT__delayed_recall_1_to_5,
               NpsMis15WrdRecognition=Ruw_AVLT__recognition_1_to_5,
               NpsMisSemFlu=Ruw_SF_Comb,NpsMocPhoFlu=Ruw_LF__letter_1,
               NpsMisBrixton=Ruw_BSAT__no_errors,NpsMocTotAns=Ruw_MoCA__total) %>%
        arrange(pseudonym) %>%
        filter(TimepointNr==0 | TimepointNr==2)

df.old_new <- full_join(old,new.s,by = c('pseudonym','ParticipantType','TimepointNr')) 
new_order <- sort(colnames(df.old_new))
df.old_new <- df.old_new[,new_order]

# Cognitive composite
old.s <- old %>%
        filter(ParticipantType=='PD_POM',
               TimepointNr==0) %>%
        select(pseudonym,CognitiveComposite)
new.s <- df %>%
        filter(TimepointNr==0) %>%
        select(pseudonym,z_CognitiveComposite,z_CognitiveComposite2)
comb <- full_join(old.s,new.s)
cor.test(comb$CognitiveComposite,comb$z_CognitiveComposite)
cor.test(comb$CognitiveComposite,comb$z_CognitiveComposite2)
library(GGally)
ggpairs(comb[,4:6], progress = F, lower = list(continuous = 'smooth')) %>% print()
comb.long <- comb %>%
        pivot_longer(cols = c('CognitiveComposite','z_CognitiveComposite','z_CognitiveComposite2'),
                     names_to = 'Score',
                     values_to = 'Value')
library(lme4)
m <- lmer(Value ~ factor(Score) + (1|pseudonym), data = comb.long)
summary(m) %>% print()
comb.long %>%
        ggplot(aes(x=as.numeric(factor(Score)),y=Value)) + 
        geom_point() + 
        geom_line(aes(group=pseudonym),alpha=0.3) + 
        geom_smooth(method='lm',color='darkred')
library(psych)
ICC(comb[,4:6])


