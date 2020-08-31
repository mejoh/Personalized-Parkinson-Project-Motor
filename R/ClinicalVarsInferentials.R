source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
df2 <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

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

modelRI2 <- lmer(TotalUpdrs3 ~ 1 + TimeToFUYears + Medication + (1|pseudonym), data = dat)
summary(modelRI2)

modelRI3 <- lmer(TotalUpdrs3 ~ 1 + TimeToFUYears + Medication + Gender + Age + (1|pseudonym), data = dat)
summary(modelRI3)
#####