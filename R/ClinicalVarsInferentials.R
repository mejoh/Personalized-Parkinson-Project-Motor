source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
df2 <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

library(reshape2)
# Unbalanced: MultipleSessions == 'No'
dat <- df2 %>%
        filter(timepoint == 'V1' | timepoint == 'V2') %>%
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Gender, Age) %>%
        melt(id.vars = c('pseudonym', 'Gender', 'Age', 'timepoint'), variable.name = 'Medication', value.name = 'y') %>%
        tibble %>%
        mutate(pseudonym = as.factor(pseudonym)) %>%
        arrange(pseudonym, timepoint)

# Balanced: MultipleSession=='Yes'
dat <- df2 %>%
        filter(MultipleSessions=='Yes') %>%
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Gender, Age) %>%
        melt(id.vars = c('pseudonym', 'Gender', 'Age', 'timepoint'), variable.name = 'Medication', value.name = 'y') %>%
        tibble %>%
        mutate(pseudonym = as.factor(pseudonym)) %>%
        arrange(pseudonym, timepoint)

levels(dat$Medication) <- c('Off','On')

#####

##### Linear mixed effects modelling #####
library(lme4)
library(lmerTest)
library(lattice)
library(bbmle)

contrasts(dat$Gender) <- cbind(m_vs_f=c(1,-1))
contrasts(dat$timepoint) <- cbind(v1_vs_v2=c(1,-1))
contrasts(dat$Medication) <- cbind(off_vs_on=c(1,-1))

# Test random intercepts for subjects
fm00 <- lm(y ~ 1, data = dat)
summary(fm00)
fm01 <- lmer(y ~ 1 + (1|pseudonym), data=dat, REML=FALSE)
summary(fm01)
dev1 <- -2*logLik(fm01)
dev0 <- -2*logLik(fm00)
devdiff <- as.numeric(dev0-dev1); devdiff
dfdiff <- attr(dev1,'df') - attr(dev0,'df'); dfdiff
cat('Chi-square =', devdiff, '(df=', dfdiff,'), p = ', pchisq(devdiff,dfdiff,lower.tail = FALSE))
AIC(fm00, fm01)
AICtab(fm00, fm01)

# Gender
fm02 <- lmer(y ~ 1 + Gender + (1 | pseudonym), data=dat, REML=FALSE)
summary(fm02)
anova(fm01,fm02,refit=FALSE)

# Age
fm03 <- lmer(y ~ 1 + Gender + I(scale(Age, center = TRUE, scale = FALSE)) + (1 | pseudonym), data = dat, REML=FALSE)
summary(fm03)
anova(fm02,fm03,refit=FALSE)

# Medication
fm04 <- lmer(y ~ 1 + Gender + I(scale(Age, center = TRUE, scale = FALSE)) + Medication + (1 | pseudonym), data = dat, REML=FALSE)
summary(fm04)
anova(fm03,fm04,refit=FALSE)

# Time
fm05 <- lmer(y ~ 1 + Gender + I(scale(Age, center = TRUE, scale = FALSE)) + Medication + timepoint + (1 | pseudonym), data = dat, REML = FALSE)
summary(fm05)
anova(fm04,fm05,refit=FALSE)

# Random slope: Time
fm06 <- lmer(y ~ 1 + Gender + I(scale(Age, center = TRUE, scale = FALSE)) + Medication + timepoint + (1 + timepoint | pseudonym), data = dat, REML = FALSE)
summary(fm06)
anova(fm05,fm06,refit=FALSE)

pr06 <- profile(fm06)
xyplot(pr06)

# Random slope: Medication
fm07 <- lmer(y ~ 1 + Gender + I(scale(Age, center = TRUE, scale = FALSE)) + Medication + timepoint + (1 + timepoint + Medication | pseudonym), data = dat, REML = FALSE)
summary(fm07)
anova(fm06,fm07,refit=FALSE)



xyplot(profile(fm07))
splom(profile(m1))
confint(profile(m1))
fixef()
ranef()
coef()
AIC()
AICtab()
-2*logLik(x)
deviance()
anova(m1,m2, refit = FALSE)












#####