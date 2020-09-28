source('M:/scripts/Personalized-Parkinson-Project-Motor/R/CombinedDatabase.R')
df <- CombinedDatabase()

##### Libraries #####

library(tidyverse)
library(lme4)
library(lmerTest)
library(lattice)
library(reshape2)

#####

##### BASELINE: Motor task, response time #####

# Data preparation
dat <- df %>%
        filter(timepoint == 'V1') %>%
        select(pseudonym, Condition, Response.Time, Percentage.Correct, Age, Gender, EstDisDurYears, Responding.Hand, PrefHand) %>%
        na.omit %>%
        mutate(Condition=as.factor(Condition),
               Age=scale(Age, scale = FALSE, center = TRUE),
               EstDisDurYears=scale(EstDisDurYears, scale = FALSE, center = TRUE),
               Responding.Hand=relevel(Responding.Hand, ref='Right'),
               RespHandIsDominant = ifelse(as.character(Responding.Hand) == as.character(PrefHand), TRUE, FALSE))
dat$RespHandIsDominant[as.character(dat$PrefHand) == 'NoPref'] <- TRUE

# Set up contrasts
contrasts(dat$Condition) <- cbind(IntVsExt=c(-2,1,1),
                                  Int3VsInt2=c(0,-1,1))
contrasts(dat$Gender) <- cbind(MaleVsFemale=c(1,-1))

# Exclusion
        # Accuracy
cutoff <- 0.25
Excluded.Pseudos <- dat %>%
        mutate(Poor.Task.Performance = if_else(Percentage.Correct <= cutoff, TRUE, FALSE)) %>%
        filter(Poor.Task.Performance == TRUE) %>%
        select(pseudonym) %>%
        unique %>%
        pull
cat('Number of participants who had below 25% accuracy in any of the task conditions:', '\n', length(Excluded.Pseudos), '\n')
dat <- dat %>%
        filter(!(pseudonym %in% Excluded.Pseudos))

# Null model
fm00 <- lmer(log(Response.Time) ~ 1 + (1|pseudonym), data = dat)
summary(fm01)
ggplot(dat, aes(x=Response.Time)) +
        geom_density() +
        facet_grid(. ~ Condition)

# Effect of condition
fm01 <- lmer(log(Response.Time) ~ 1 + Condition + (1|pseudonym), data = dat)
summary(fm01)
ggplot(dat, aes(x=Condition,y=Response.Time)) +
        geom_boxplot()

anova(fm00,fm01)

# Collapse Int2 and Int3
dat2 <- dat %>%
        mutate(Condition = if_else(Condition == 'Ext', 'Ext','Int'))

# Refit effect of condition
fm02 <- lmer(log(Response.Time) ~ 1 + Condition + (1|pseudonym), data = dat2)
summary(fm02)
ggplot(dat2, aes(x=Condition,y=Response.Time)) +
        geom_boxplot()

# Random intercepts of condition
fm02b <- lmer(log(Response.Time) ~ 1 + Condition + (1|pseudonym/Condition), data = dat2)
summary(fm02b)
anova(fm02, fm02b, refit=TRUE) # Not enough power to include in subsequent steps

# Random slope of condition
fm03 <- lmer(log(Response.Time) ~ 1 + Condition + (1 + Condition|pseudonym), data = dat2)
summary(fm03)
ggplot(dat2, aes(x=Condition,y=Response.Time)) +
        geom_point() +
        geom_line(aes(group=pseudonym), alpha=1/2)

# Covariate: Age
fm04 <- lmer(log(Response.Time) ~ 1 + Condition + Age + (1 + Condition|pseudonym), data = dat2)
summary(fm04)
ggplot(dat2, aes(x=Age, y=Response.Time)) +
        geom_point() +
        geom_smooth(method = 'lm') +
        facet_grid(. ~ Condition)
anova(fm03, fm04)

# Covariate: Gender
fm05 <- lmer(log(Response.Time) ~ 1 + Condition + Gender + (1 + Condition|pseudonym), data = dat2)
summary(fm05)
ggplot(dat2, aes(x=Gender, y=Response.Time)) +
        geom_boxplot() +
        facet_grid(. ~ Condition)
anova(fm03, fm05)

# Covariate: Estimated disease duration in years
fm06 <- lmer(log(Response.Time) ~ 1 + Condition + EstDisDurYears + (1 + Condition|pseudonym), data = dat2)
summary(fm06)
ggplot(dat2, aes(x=EstDisDurYears, y=Response.Time)) +
        geom_point() +
        geom_smooth(method = 'lm') +
        facet_grid(. ~ Condition)
anova(fm03, fm06)

# Covariate: Whether the responding hand was the dominant one or not
fm07 <- lmer(log(Response.Time) ~ 1 + Condition + RespHandIsDominant + (1 + Condition|pseudonym), data = dat2)
summary(fm07)
ggplot(dat2, aes(x=RespHandIsDominant, y=Response.Time)) +
        geom_boxplot() +
        facet_grid(. ~ Condition)
anova(fm03, fm07)

# Full covariate model
fm08 <- lmer(log(Response.Time) ~ 1 + Condition + Age + Gender + EstDisDurYears + RespHandIsDominant + (1 + Condition|pseudonym), data = dat2)
summary(fm08)
anova(fm03, fm08)

# Reduced covariate model
fm09 <- lmer(log(Response.Time) ~ 1 + Condition + Age + EstDisDurYears + (1 + Condition|pseudonym), data = dat2)
summary(fm09)
anova(fm03, fm09)

WinningModel <- fm09

#####

##### 1-year disease progression #####

# Data preparation

        # Unbalanced: MultipleSessions == 'No'
#dat <- df %>%
#        filter(timepoint == 'V1' | timepoint == 'V2') %>%
#        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Gender, Age, EstDisDurYears) %>%
#        melt(id.vars = c('pseudonym', 'Gender', 'Age', 'timepoint', 'EstDisDurYears'), variable.name = 'Medication', value.name = 'y') %>%
#        tibble %>%
#        mutate(pseudonym = as.factor(pseudonym)) %>%
#        arrange(pseudonym, timepoint)

        # Balanced: MultipleSession=='Yes'
dat <- df %>%
        filter(MultipleSessions=='Yes') %>%
        filter(timepoint == 'V1' | timepoint == 'V2') %>%
        filter(Condition == 'Ext') %>%
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Gender, Age, EstDisDurYears) %>%
        melt(id.vars = c('pseudonym', 'Gender', 'Age', 'timepoint', 'EstDisDurYears'), variable.name = 'Medication', value.name = 'y') %>%
        tibble %>%
        mutate(pseudonym = as.factor(pseudonym)) %>%
        arrange(pseudonym, timepoint) %>%
        na.omit

dat$timepoint <- factor(dat$timepoint)
dat$Age <- scale(dat$Age, scale=FALSE, center=TRUE)
dat$EstDisDurYears <- scale(dat$EstDisDurYears, scale=FALSE, center=TRUE)
levels(dat$Medication) <- c('Off','On')

# Set up contrasts

contrasts(dat$Gender) <- cbind(MaleVsFemale=c(1,-1))
contrasts(dat$timepoint) <- cbind(V2VsV1=c(-1,1))
contrasts(dat$Medication) <- cbind(OffVsOn=c(1,-1))

# Exlusion

# Null model
fm00 <- lmer(y ~ 1 + (1|pseudonym), data = dat, REML = TRUE)
summary(fm00)
ggplot(dat, aes(x=y)) +
        geom_density() +
        facet_grid(. ~ timepoint)

# Effect of time
fm01 <- lmer(y ~ 1 + timepoint + (1|pseudonym), data = dat, REML = TRUE)
summary(fm01)
ggplot(dat, aes(x=timepoint, y=y)) +
        geom_boxplot()
anova(fm00, fm01, refit = TRUE)

# Random slopes of time
fm02 <- lmer(y ~ 1 + timepoint + (1 + timepoint|pseudonym), data = dat, REML = TRUE)
summary(fm02)
ggplot(dat, aes(x=timepoint, y=y)) +
        geom_point() +
        geom_line(aes(group=pseudonym), alpha = 1/2)
anova(fm01, fm02, refit = TRUE)

# Effect of medication
fm03 <- lmer(y ~ 1 + timepoint + Medication + (1 + timepoint|pseudonym), data = dat, REML = TRUE)
summary(fm03)
ggplot(dat, aes(x=Medication, y=y)) +
        geom_boxplot() +
        facet_grid(. ~ timepoint)
anova(fm02, fm03, refit = TRUE)

# Random slopes of medication
fm04 <- lmer(y ~ 1 + timepoint + Medication + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm04)
ggplot(dat, aes(x=Medication, y=y)) +
        geom_point() +
        geom_line(aes(group=pseudonym), alpha = 1/2) +
        facet_grid(. ~ timepoint)
anova(fm03, fm04, refit = TRUE)

# Covariate: Age
fm05 <- lmer(y ~ 1 + timepoint + Medication + Age + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm05)
ggplot(dat, aes(x=Age, y=y)) +
        geom_point() +
        geom_smooth(method='lm', color='blue') +
        geom_smooth(method='lm', formula = y ~ poly(x,2), color='red') +
        facet_grid(. ~ timepoint)
anova(fm04, fm05, refit = TRUE)

        # Second-order polynomial
fm05b <- lmer(y ~ 1 + timepoint + Medication + poly(Age, 2) + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm05b)

# Covariate: Gender
fm06 <- lmer(y ~ 1 + timepoint + Medication + Gender + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm06)
ggplot(dat, aes(x=Gender, y=y)) +
        geom_boxplot() +
        facet_grid(. ~ timepoint)
anova(fm04, fm06, refit = TRUE)

# Covariate: Estimated disease duration in years
fm07 <- lmer(y ~ 1 + timepoint + Medication + EstDisDurYears + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm07)
ggplot(dat, aes(x=EstDisDurYears, y=y)) +
        geom_point() +
        geom_smooth(method='lm', color='blue') +
        geom_smooth(method='lm', formula = y ~ poly(x, 2), color='red') +
        geom_smooth(method='lm', formula = y ~ poly(x, 3), color='green') +
        facet_grid(. ~ timepoint)
anova(fm04, fm07, refit = TRUE)

        # Second-order polynomial
fm07b <- lmer(y ~ 1 + timepoint + Medication + poly(EstDisDurYears, 2) + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm07b)
anova(fm07, fm07b, refit = TRUE)

# Full covariate model
fm08 <- lmer(y ~ 1 + timepoint + Medication + poly(Age, 2) + Gender + EstDisDurYears + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm08)
anova(fm04,fm08, refit = TRUE)

WinningModel <- fm08

#####

##### Estimating the relationship between task performance and symptom severity #####

# Data preparation
dat <- df %>%
        filter(timepoint == 'V1') %>%
        select(pseudonym, Condition, Response.Time, Up3OfTotal, Up3OfTotal.1YearProg, Percentage.Correct, Age, Gender, EstDisDurYears) %>%
        na.omit %>%
        mutate(Condition = if_else(Condition == 'Ext', 'Ext','Int'),
               Condition=as.factor(Condition),
               Age=scale(Age, scale = FALSE, center = TRUE),
               EstDisDurYears=scale(EstDisDurYears, scale = FALSE, center = TRUE))

# Set up contrasts
contrasts(dat$Condition) <- cbind(IntVsExt=c(-1,1))
contrasts(dat$Gender) <- cbind(MaleVsFemale=c(1,-1))

# Exclusion
# Accuracy
cutoff <- 0.25
Excluded.Pseudos <- dat %>%
        mutate(Poor.Task.Performance = if_else(Percentage.Correct <= cutoff, TRUE, FALSE)) %>%
        filter(Poor.Task.Performance == TRUE) %>%
        select(pseudonym) %>%
        unique %>%
        pull
cat('Number of participants who had below 25% accuracy in any of the task conditions:', '\n', length(Excluded.Pseudos), '\n')
dat <- dat %>%
        filter(!(pseudonym %in% Excluded.Pseudos))

fm00 <- lmer(Response.Time ~ 1 + (1|pseudonym), data = dat, REML = TRUE)
summary(fm00)

fm00b <- lmer(Response.Time ~ 1 + (1|pseudonym/Condition), data = dat, REML = TRUE)
summary(fm00b)
anova(fm00, fm00b, refit=TRUE)

fm01 <- lmer(Response.Time ~ 1 + Condition + (1|pseudonym), data = dat, REML = TRUE)
summary(fm01)
anova(fm00b, fm01, refit=TRUE)

fm01b <- lmer(Response.Time ~ 1 + Condition + (1|pseudonym), data = dat, REML = TRUE)
summary(fm01b)
anova(fm01, fm01b, refit=TRUE)

fm02 <- lmer(Response.Time ~ 1 + Condition + Up3OfTotal + Up3OfTotal.1YearProg + Age + Gender + EstDisDurYears + (1|pseudonym), data = dat, REML = TRUE)
summary(fm02)
ggplot(dat, aes(x=Response.Time, y=Up3OfTotal)) + 
        geom_point() +
        geom_smooth(method='lm') +
        facet_grid(.~Condition)
ggplot(dat, aes(x=Response.Time, y=Up3OfTotal.1YearProg)) + 
        geom_point() +
        geom_smooth(method='lm') +
        facet_grid(.~Condition)
anova(fm01b, fm02, refit=TRUE)

#####

##### Diagnostics #####

qqmath(WinningModel)
plot(WinningModel)
pWinningModel <- profile(WinningModel)
xyplot(pWinningModel)
splom(pWinningModel)
refs <- ranef(WinningModel, condVar = TRUE); dd <- as.data.frame(refs)
dotplot(refs, scales = list(x=list(relation='free')))[["pseudonym"]]
qqmath(refs)
ggplot(dd, aes(y=grp,x=condval)) +
        geom_point() + facet_wrap(~term,scales='free_x') +
        geom_errorbarh(aes(xmin=condval -2*condsd,
                       xmax=condval +2*condsd), height=0)

#####

##### Confidence intervals #####

confint.merMod(WinningModel, method = c('boot'), boot.type = c('basic'))

#####