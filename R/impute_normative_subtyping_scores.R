library(tidyverse)
library(readxl)
library(mice)
library(miceadds)

# df <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_2022-07-27.csv')
df <- read_csv('P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-21.csv') %>%
  mutate(NpsMis15WrdRecog=NpsMis15WrdHits+(15-NpsMis15WrdFals))
# df %>%
#   filter(TimepointNr==0,
#          ParticipantType=='PD_POM') %>%
#   mutate(AVLT__total_1_to_5=NpsMis15wRigTot,
#          AVLT__delayed_recall_1_to_5=NpsMis15WrdDelRec,
#          AVLT__recognition_1_to_5=NpsMis15WrdHits+(15-NpsMis15WrdFals),
#          SF__Animals = NpsMisSemFlu,
#          BSAT__no_errors = NpsMisBrixton,
#          SDMT_ORAL_90 = NpsMisModa90,
#          Benton_JLO = NpsMisBenton,
#          WAIS_IV_LetterNumSeq = NpsMisWaisRude) %>%
#   select(pseudonym, Age, Gender, NpsEducYears, AVLT__total_1_to_5, AVLT__delayed_recall_1_to_5, AVLT__recognition_1_to_5, SF__Animals, BSAT__no_errors,
#          SDMT_ORAL_90, Benton_JLO, WAIS_IV_LetterNumSeq) %>% view()

#File 1
ANDI_scores <- read_excel('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/ANDI_stacked_1-471.xlsx')
colnames(ANDI_scores)[1:3] <- c('pseudonym', 'FullName', 'Variable')
ANDI_z_scores <- ANDI_scores %>%
  select(pseudonym, Variable, z) %>%
  pivot_wider(names_from = Variable,
              values_from = z)
colnames(ANDI_z_scores)[2:6] <- c('AVLT.Total_1to5','AVLT.DelayedRecall_1to5','AVLT.Recognition_1to5','SemanticFluency','Brixton')
#File 2
SDMT_Benton_WAIS_scores <- read_csv('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/POM_dataset SDMT and Benton JULO and WAIS-IV LNS z-norms.csv')
SDMT_Benton_WAIS_z_scores <- SDMT_Benton_WAIS_scores %>%
  select(pseudonym, SDMT_ORAL_90_Z_SCORE, Benton_Z_SCORE, LetterNumSeq_Z_Score_age_and_edu_adjusted)
colnames(SDMT_Benton_WAIS_z_scores)[2:4] <- c('SymbolDigit', 'Benton', 'LetterNumberSeq')

# Neuropsych_z_scores <- full_join(ANDI_z_scores, SDMT_Benton_WAIS_z_scores, by = 'pseudonym') %>%
#   na.omit() %>%
#   mutate(AVLT.avg = (AVLT.Total_1to5 + AVLT.DelayedRecall_1to5 + AVLT.Recognition_1to5)/3,
#          CognitiveComposite = (SemanticFluency + Brixton + SymbolDigit + Benton + LetterNumberSeq + AVLT.avg) / 6)

c <- colnames(SDMT_Benton_WAIS_scores)[1:21]
c <- c(c, 'NpsMis15WrdRecog')
df.raw <- df %>%
  filter(TimepointNr==0,
         ParticipantType=='PD_POM') %>%
  select(all_of(c))
df.add <- left_join(df.raw, ANDI_z_scores)
df.add <- left_join(df.add, SDMT_Benton_WAIS_z_scores)

# Each age/sex/education-adjusted score is subjected predictive mean matching imputation
# Specifically, NA z-scores are predicted based on age, sex, education, and the raw score
# Predicted scores are not as exact as real normative ones given that we only have 
# limited data available on the many many combinations of predictor values.
# But overall, the predicted values seem to correspond pretty well with real z-scores
# from participants with similar characteristics.
impute_variable <- function(df, rawvar='NpsMis15wRigTot', zvar='AVLT.Total_1to5'){
  
  # Define the data 
  df1 <- df.add
  df.pre_imputation <- df1 %>% select(pseudonym, Age, Gender, NpsEducation, any_of(c(rawvar, zvar))) %>%
    filter(!is.na(!!as.name(rawvar))) %>%
    mutate(Gender = factor(Gender),
           NpsEducation = factor(NpsEducation))
  md.pattern(df.pre_imputation)
  df.imputed <- mice(df.pre_imputation, method = 'pmm', m = 5, maxit = 50, seed=157)
  df.imputed1 <- complete(df.imputed, 1) %>% as_tibble() %>% rename(v1 = !!as.name(zvar)) %>% select(v1)
  df.imputed2 <- complete(df.imputed, 2) %>% as_tibble() %>% rename(v2 = !!as.name(zvar)) %>% select(v2)
  df.imputed3 <- complete(df.imputed, 3) %>% as_tibble() %>% rename(v3 = !!as.name(zvar)) %>% select(v3)
  df.imputed4 <- complete(df.imputed, 4) %>% as_tibble() %>% rename(v4 = !!as.name(zvar)) %>% select(v4)
  df.imputed5 <- complete(df.imputed, 5) %>% as_tibble() %>% rename(v5 = !!as.name(zvar)) %>% select(v5)
  df.complete <- bind_cols(df.pre_imputation, df.imputed1, df.imputed2, df.imputed3 ,df.imputed4, df.imputed5) %>%
    group_by(pseudonym) %>%
    mutate(imputed_zvar = median(c(v1,v2,v3,v4,v5))) %>%
    ungroup() %>%
    select(-c(v1,v2,v3,v4,v5))
  imputed_zvar <- df.complete %>% select(pseudonym, imputed_zvar)
  
  # Check the relationship between imputed missing and complete data over raw values.
  # You should see that the imputed values are on the diagonal
  # df.complete %>% filter(Age==69, Gender=='Female', NpsEducation==5)
  g <- df.complete %>%
    mutate(na = if_else(is.na(!!as.name(zvar)),'Yes','No')) %>%
    ggplot(aes(y = imputed_zvar, x=!!as.name(rawvar), color=na)) +
    geom_point(alpha=0.5) + 
    facet_wrap(Gender~NpsEducation) +
    ggtitle(zvar)
  print(g)
  
  imputed_zvar
  
}

# AVLT.Total_1to5
df.AVLT.Total_1to5 <- impute_variable(df.add, rawvar = 'NpsMis15wRigTot', zvar = 'AVLT.Total_1to5') %>%
  rename(AVLT.Total_1to5.imp = imputed_zvar)
# AVLT.DelayedRecall_1to5
df.AVLT.DelayedRecall_1to5 <- impute_variable(df.add, rawvar = 'NpsMis15WrdDelRec', zvar = 'AVLT.DelayedRecall_1to5') %>%
  rename(AVLT.DelayedRecall_1to5.imp = imputed_zvar)
# AVLT.Recognition_1to5
df.AVLT.Recognition_1to5 <- impute_variable(df.add, rawvar = 'NpsMis15WrdRecog', zvar = 'AVLT.Recognition_1to5') %>%
  rename(AVLT.Recognition_1to5.imp = imputed_zvar)
# SemanticFluency
df.SemanticFluency <- impute_variable(df.add, rawvar = 'NpsMisSemFlu', zvar = 'SemanticFluency') %>%
  rename(SemanticFluency.imp = imputed_zvar)
# Brixton
df.Brixton <- impute_variable(df.add, rawvar = 'NpsMisBrixton', zvar = 'Brixton') %>%
  rename(Brixton.imp = imputed_zvar)
# Symbol digit
df.SymbolDigit <- impute_variable(df.add, rawvar = 'NpsMisModa90', zvar = 'SymbolDigit') %>%
  rename(SymbolDigit.imp = imputed_zvar)
# Benton
df.Benton <- impute_variable(df.add, rawvar = 'NpsMisBenton', zvar = 'Benton') %>%
  rename(Benton.imp = imputed_zvar)
# LetterNumberSeq
df.LetterNumberSeq <- impute_variable(df.add, rawvar = 'NpsMisWaisLcln', zvar = 'LetterNumberSeq') %>%
  rename(LetterNumberSeq.imp = imputed_zvar)

df.complete <- df.add %>% 
  left_join(.,df.AVLT.Total_1to5) %>%
  left_join(.,df.AVLT.DelayedRecall_1to5) %>%
  left_join(.,df.AVLT.Recognition_1to5) %>%
  left_join(.,df.SemanticFluency) %>%
  left_join(.,df.Brixton) %>%
  left_join(.,df.SymbolDigit) %>%
  left_join(.,df.Benton) %>%
  left_join(.,df.LetterNumberSeq) %>%
  mutate(AVLT.avg.imp = (AVLT.Total_1to5.imp + AVLT.DelayedRecall_1to5.imp + AVLT.Recognition_1to5.imp)/3,
         CognitiveComposite.imp = (SemanticFluency.imp + Brixton.imp + SymbolDigit.imp + 
                                 Benton.imp + LetterNumberSeq.imp + AVLT.avg.imp) / 6)

write_csv(df.complete, 'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/NormativeScores.csv')
  

