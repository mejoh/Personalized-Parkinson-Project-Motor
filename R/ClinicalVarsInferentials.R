##### Generate data frame ####

#source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsDatabase.R')
#df_v1 <- ClinicalVarsDatabase('Castor.Visit1')
#df_v2 <- ClinicalVarsDatabase('Castor.Visit2')
#df_hq1 <- ClinicalVarsDatabase('Castor.HomeQuestionnaires1')
#save.image("M:/scripts/Personalized-Parkinson-Project-Motor/R/visit1_visit2_environment2.RData")

load("M:/scripts/Personalized-Parkinson-Project-Motor/R/visit1_visit2_environment2.RData")
#####

##### Preprocess data frame #####
# Sort data frame
library(tidyverse)
df2_v1 <- df_v1 %>%
        arrange(pseudonym, timepoint)

df2_v2 <- df_v2 %>%
        arrange(pseudonym, timepoint)


df2_hq1 <- df_hq1 %>%
        arrange(pseudonym, timepoint)

# Merge data frames
df2 <- full_join(df2_v1, df2_v2) %>%
        arrange(pseudonym, timepoint)

df2 <- full_join(df2, df2_hq1) %>%
        arrange(pseudonym, timepoint)

# Select vars and generate additional ones
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsPreprocessing.R')
df2 <- ClinicalVarsPreprocessing(df2)
##### 

##### Subset #####
df2 <- df2 %>%
        filter(MriNeuroPsychTask == 'Motor')
#####

dat <- df2 %>%
        filter(timepoint == 'V1' | timepoint == 'V2') %>%
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Gender, Age, EstDisDurYears, TimeToFUYears) %>%
        melt(id.vars = c('pseudonym', 'Gender', 'Age', 'TimeToFUYears'), variable.name = 'Medication', value.name = 'TotalUpdrs3') %>%
        tibble %>%
        arrange(pseudonym, timepoint)


##### Linear mixed effects modelling #####
library(lme4)
library(lmerTest)

modelIonly <- lmer(TotalUpdrs3 ~ 1 + (1|pseudonym), data = dat)
summary(modelIonly)

modelRI1 <- lmer(TotalUpdrs3 ~ 1 + TimeToFUYears + (1|pseudonym), data = dat)
summary(modelRI1)

modelRI2 <- lmer(TotalUpdrs3 ~ 1 + TimeToFUYears + Gender + Age + (1|pseudonym), data = dat)
summary(modelRI2)

modelRI3 <- lmer(TotalUpdrs3 ~ 1 + TimeToFUYears + Medication + Gender + Age + (1|pseudonym), data = dat)
summary(modelRI3)
#####