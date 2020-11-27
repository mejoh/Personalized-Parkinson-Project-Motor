source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
df <- CombinedDatabase()

##### Libraries #####

library(tidyverse)
library(lme4)
library(lmerTest)
library(lattice)
library(reshape2)
library(splines)

#####

##### BASELINE: Motor task, response time #####

# Data preparation
dat <- reshape_by_task(df, lengthen=TRUE)
dat <- dat %>%
        filter(timepoint == 'V1') %>%
        select(pseudonym, Condition, Response.Time, Percentage.Correct, Age, Gender, EstDisDurYears, Responding.Hand,
               PrefHand, TremorDominant.cutoff1) %>%
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
summary(fm00)
ggplot(dat, aes(x=Response.Time)) +
        geom_density() +
        facet_grid(. ~ Condition)
ggplot(dat, aes(x=log(Response.Time))) +
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

dat <- df %>%
        select(pseudonym, timepoint, Gender, Age, EstDisDurYears, MultipleSessions,
               Up3OfTotal, Up3OnTotal, Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta,
               Up3OfBradySum, Up3OnBradySum, Up3OfBradySum.1YearDelta, Up3OnBradySum.1YearDelta,
               Up3OfRestTremAmpSum, Up3OnRestTremAmpSum, Up3OfRestTremAmpSum.1YearDelta, Up3OnRestTremAmpSum.1YearDelta,
               Up3OfRigiditySum, Up3OnRigiditySum, Up3OfRigiditySum.1YearDelta, Up3OnRigiditySum.1YearDelta)

dat <- reshape_by_medication(dat, lengthen = TRUE)
dat <- dat %>% pivot_wider(names_from='Subscore',
                     names_prefix='Up3',
                     values_from = 'Severity')

dat <- dat %>%
        filter(MultipleSessions=='Yes') %>%
        mutate(pseudonym=as.factor(pseudonym),
               y=Up3Total) %>%
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
        geom_smooth(method='lm', formula = y ~ bs(x, degree=2), color='red') +
        geom_smooth(method='lm', formula = y ~ bs(x, degree=3), color='green') +
        facet_grid(. ~ timepoint)
anova(fm04, fm07, refit = TRUE)

        # Second-order polynomial
fm07b <- lmer(y ~ 1 + timepoint + Medication + bs(EstDisDurYears, degree = 2) + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm07b)
anova(fm07, fm07b, refit = TRUE)

# Full covariate model
fm08 <- lmer(scale(y) ~ 1 + timepoint + Medication + poly(Age, 2) + Gender + EstDisDurYears + (1 + timepoint + Medication|pseudonym), data = dat, REML = TRUE)
summary(fm08)
anova(fm04,fm08, refit = TRUE)

WinningModel <- fm08

#####

##### Estimating the relationship between task performance and symptom severity #####

# Data preparation
dat <- df %>%
        filter(timepoint == 'V1' & MultipleSessions == 'Yes') %>%
        select(pseudonym, Age, Gender, EstDisDurYears,
               starts_with('Response.Time'), starts_with('Percentage.Correct'),
               Up3OfTotal, Up3OfTotal.1YearDelta, Up3OnTotal, Up3OnTotal.1YearDelta) %>%
        na.omit

dat <- reshape_by_medication(dat, lengthen = TRUE)
dat <- reshape_by_task(dat, lengthen = TRUE)
dat <- dat %>% pivot_wider(names_from='Subscore',
                           names_prefix='Up3',
                           values_from = 'Severity')

levels(dat$Medication) <- c('Off','On')
dat <- dat %>%
        filter(Medication == 'On') %>%
        mutate(Condition = if_else(Condition == 'Ext', 'Ext','Int'),
               Condition = as.factor(Condition)) %>%
        mutate(Age=scale(Age, scale = FALSE, center = TRUE),
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

# Modelling

fm00 <- lmer(Response.Time ~ 1 + (1|pseudonym), data = dat, REML = TRUE)
summary(fm00)

fm01 <- lmer(Response.Time ~ 1 + Condition + (1|pseudonym), data = dat, REML = TRUE)
summary(fm01)
anova(fm00, fm01, refit=TRUE)

fm02 <- lmer(Response.Time ~ 1 + Condition + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm02)
anova(fm01, fm02, refit=TRUE)

fm03 <- lmer(Response.Time ~ 1 + Condition + Age + Gender + EstDisDurYears + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm03)
anova(fm02, fm03, refit=TRUE)

fm03b <- lmer(Response.Time ~ 1 + Condition + Age + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm03)
anova(fm02, fm03b, refit=TRUE)

fm04 <- lmer(Response.Time ~ 1 + Condition + Up3OfTotal + Age + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm04)
anova(fm03, fm04, refit=TRUE)

fm04b <- lmer(Response.Time ~ 1 + Condition + Up3OnTotal + Age + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm04)
anova(fm04, fm04b, refit=TRUE)

fm05 <- lmer(Response.Time ~ 1 + Condition*Up3Total.1YearDelta + Age + (1 + Condition|pseudonym), data = dat, REML = TRUE)
summary(fm05)
ggplot(dat, aes(x=Up3OnTotal.1YearProg, y=Response.Time, color=Condition)) +
        geom_point() +
        geom_smooth(method='lm')
anova(fm04, fm05, refit=TRUE)

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

##### Multivariate MCMCglmm #####

library(MCMCglmm)
library(lme4)
library(brms)
library(tidyverse)
library(corrplot)
library(broom.mixed)
library(dotwhisker)
library(lattice)
library(splines)

# Load data
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
tb <- CombinedDatabase()

# Subset data
tb2 <- tb %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        filter(ParkinMedUser == 'Yes') %>%
        filter(MultipleSessions == 'Yes') %>%
        select(pseudonym, Gender, Age, EstDisDurYears, timepoint, TimeToFUYears,
               Up3OfTotal, Up3OnTotal,
               Up3OfBradySum, Up3OnBradySum,
               Up3OfRigiditySum, Up3OnRigiditySum,
               Up3OfRestTremAmpSum, Up3OnRestTremAmpSum,
               Up3OfActionTremorSum, Up3OnActionTremorSum,
               Up3OfPIGDSum, Up3OnPIGDSum,
               Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta) %>%
        mutate(pseudonym=as.factor(pseudonym)) %>%
        na.omit

# Scale confounding variables (DO THIS WITHIN THE MODEL INSTEAD FOR CLARITY)
#scale.vars <- c('Age', 'EstDisDurYears')
#for (i in 1:length(scale.vars)){
#        scaled_var <- tb.reduced %>%
#                select(one_of(scale.vars[i])) %>%
#                scale(center = TRUE, scale = TRUE)
#        scaled_var <- c(scaled_var)
#        tb.reduced <- tb.reduced %>%
#                mutate('{scale.vars[i]}_sc' := scaled_var)
#}
#tb.reduced_sc  <- tb.reduced %>%
#        select(-c(any_of(scale.vars)))

# Lengthen by medication
tb2.long <- tb2 %>%
        pivot_longer(cols = starts_with('Up3'), names_to = c('Medication', '.value'), names_sep = 5) %>%
        mutate(Medication = if_else(Medication == 'Up3Of', 'Off', 'On'),
               Medication = as.factor(Medication))

# Set levels of factor so that 0 is clear
tb3.long <- tb2.long %>%
        mutate(Gender = if_else(Gender == 'Male',0,1),
               Medication = if_else(Medication == 'Off',0,1),
               timepoint = if_else(timepoint == 'V1',0,1))

# Set prior (weak)
prior1 = list(R = list(V = diag(2)/2, nu = 0.002),
              G = list(G1 = list(V = diag(3)/3,
                                 nu = 0.002,
                                 alpha.mu = rep(0,3),
                                 alpha.V = diag(3)/3)))

# Estimate primary model
FitModel <- function(){
        m <- MCMCglmm(cbind(scale(Total), scale(BradySum)) ~ 0 + trait +
                              trait:scale(Age) +
                              trait:scale(EstDisDurYears) + 
                              trait:Gender +
                              trait:Medication + 
                              trait:timepoint,
                      random = ~us(trait + timepoint):pseudonym,
                      rcov = ~us(trait):units,
                      prior = prior1,
                      family = c('gaussian', 'gaussian'),
                      nitt = 90000,
                      burnin = 40000,
                      thin = 50,
                      data = as.data.frame(tb3.long),
                      verbose = TRUE) 
        return(m)
}
mcmc1 <- FitModel()
summary(mcmc1)

# Fit the model again to enable usage of the Gelman diagnostic
#mcmc2 <- FitModel()
#mcmc3 <- FitModel()
#mcmc4 <- FitModel()

# Diagnostics
pairs(tb3.long)
# Correlation plots for random effects (not sure if this works properly)
VarCorr.MCMCglmm <- function(object, ...) {
        s <- summary(object$VCV)$statistics[,"Mean"]
        grps <- gsub("^[^.]+\\.([[:alnum:]]+)$","\\1",names(s))
        ss <- split(s,grps)
        getVC <- function(x) {
                nms <- gsub("^([^.]+)\\.[[:alnum:]]+$","\\1",names(x))
                n <- length(nms)
                L <- round(sqrt(n))
                dimnms <- gsub("^([^:]+):.*$","\\1",nms[1:L])
                return(matrix(x,dimnames=list(dimnms,dimnms),
                              nrow=L))
        }
        r <- setNames(lapply(ss,getVC),unique(grps))
        return(r)
}
vv <- VarCorr(mcmc1)
corrplot.mixed(cov2cor(vv$pseudonym),upper="ellipse")
corrplot.mixed(cov2cor(vv$units),upper="ellipse")
# Fixed effects
tt <- tidy(mcmc1)
tt <- bind_rows(MCMCglmm=tt,.id="model") %>%
        filter(effect=="fixed")
dwplot(tt)+geom_vline(xintercept=0,lty=2)
# QQplot

# Mixing, burn-in
plot(mcmc1)
# Autocorrelation
acSol <- autocorr(mcmc1$Sol)    # Fixed effects
view(acSol)
acVCV <- autocorr(mcmc1$VCV)    # Random effects
view(acVCV)
autocorr.plot(mcmc1$Sol)       # acf() also works
autocorr.plot(mcmc1$VCV)
# Model convergence
geweke.plot(mcmc1$Sol)    # Fixed effects
gelman.plot(mcmc.list(mcmc1$Sol, mcmc2$Sol))
geweke.plot(mcmc1$VCV)    # Random effects
gelman.plot(mcmc.list(mcmc1$VCV, mcmc2$VCV))
# Robustness to different priors
mcmc1_DefPrior <- MCMCglmm(cbind(scale(BradySum), scale(RigiditySum), scale(RestTremAmpSum)) ~ 0 + trait +
                                   trait:scale(Age) +
                                   trait:scale(EstDisDurYears) + 
                                   trait:Gender +
                                   trait:Medication + 
                                   trait:timepoint,
                           random = ~us(trait + timepoint):pseudonym,
                           rcov = ~us(trait):units,
                           family = c('gaussian', 'gaussian', 'gaussian'),
                           nitt = 75000,
                           burnin = 50000,
                           thin = 50,
                           data = as.data.frame(tb3.long),
                           verbose = TRUE)
summary(mcmc1_DefPrior)
# In progress
# Default prior?
# Stronger prio?
# Is there a prior which makes sense for us?


# Correlate individual differences
#cor_intslope <- posterior.mode(posterior.cor(mcmc1$VCV[,c(1,4,13,16)]))[2]
#HPDinterval(posterior.cor(mcmc1$VCV[,c(1,4,13,16)]))[2,]
cor_intslope <- mcmc1$VCV[,'timepoint:traitBradySum.pseudonym']/
        (sqrt(mcmc1$VCV[,'traitBradySum:traitBradySum.pseudonym'])* 
                 sqrt(mcmc1$VCV[,'timepoint:timepoint.pseudonym']))
posterior.mode(cor_intslope)
HPDinterval(cor_intslope)
plot(cor_intslope)

#####

##### Multivariate lme4 #####

tb2 <- df %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        filter(ParkinMedUser == 'Yes') %>%
        filter(timepoint == 'V1') %>%
        select(pseudonym, Gender, Age, EstDisDurYears, TimeToFUYears,
               Up3OfTotal, Up3OnTotal,
               Up3OfBradySum, Up3OnBradySum) %>%
        mutate(pseudonym=as.factor(pseudonym))

# Lengthen by medication
tb2.long <- tb2 %>%
        pivot_longer(cols = starts_with('Up3'), names_to = c('Medication', '.value'), names_sep = 5) %>%
        mutate(Medication = if_else(Medication == 'Up3Of', 'Off', 'On'),
               Medication = as.factor(Medication))

# Set levels of factor so that 0 is clear
tb3.long <- tb2.long %>%
        mutate(Gender = if_else(Gender == 'Male',0,1),
               Medication = if_else(Medication == 'Off',0,1))

# Turn variable names to levels in a single factor to enable multivariate lme4
tb3.longer <- tb3.long %>%
        pivot_longer(c('Total', 'BradySum'), names_to='Score', values_to='Severity') %>%
        mutate(Score=as.factor(Score))

# Fit multivariate lme4
lmer01 <- lmer(Severity ~ 0 + Score +
                       Score:Medication + 
                       Score:scale(Age, scale=FALSE) + 
                       Score:Gender + 
                       Score:scale(EstDisDurYears, scale=FALSE) +
                       (0 + Score|pseudonym), data = na.omit(tb3.longer))
summary(lmer01)
VarCorr(lmer01)
cov2cor(vcov(lmer01))

#####


##### Test of delta #####
tb2 <- df %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        filter(ParkinMedUser == 'Yes') %>%
        filter(timepoint == 'V2') %>%
        select(pseudonym, Gender, Age, EstDisDurYears, TimeToFUYears,
               Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta,
               Up3OfTotal.1YearROC, Up3OnTotal.1YearROC) %>%
        mutate(pseudonym=as.factor(pseudonym))

# Lengthen by medication
tb2.long <- tb2 %>%
        pivot_longer(cols = starts_with('Up3'), names_to = c('Medication', '.value'), names_sep = 5) %>%
        mutate(Medication = if_else(Medication == 'Up3Of', 'Off', 'On'),
               Medication = as.factor(Medication))

# Set levels of factor so that 0 is clear
tb3.long <- tb2.long %>%
        mutate(Gender = if_else(Gender == 'Male',0,1),
               Medication = if_else(Medication == 'Off',0,1))

#
lm_d1 <- lmer(Total.1YearDelta ~ Medication +
                      Gender +
                      scale(Age, scale=FALSE) +
                      scale(EstDisDurYears, scale=FALSE) +
                      scale(TimeToFUYears, scale=FALSE) + 
                      (1 | pseudonym),
              data = na.omit(tb3.long))
summary(lm_d1)




