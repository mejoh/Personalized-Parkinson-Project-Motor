tmp.test <- tmp %>%
    select(pseudonym, response_time, ParticipantType, trial_type, block, Age_Dmean, Gender, RespHandIsDominant) %>%
    na.omit()

# tmp.test.std <- tmp.test %>%
#     mutate(response_time = log(response_time)) %>%
#     as.data.frame() %>%
#     stdize() %>%
#     as_tibble()

# Fit fixed effects
f1 <- 'log(response_time) ~ 1 + (1|pseudonym)'
fit1 <- lmer(f1, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f2 <- 'log(response_time) ~ 1 + ParticipantType + (1|pseudonym)'
fit2 <- lmer(f2, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f3 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + (1|pseudonym)'
fit3 <- lmer(f3, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f4 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + (1|pseudonym)'
fit4 <- lmer(f4, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

anova(fit1,fit2,fit3,fit4)

# Fit random effects
f5 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + (1+trial_type|pseudonym)'
fit5 <- lmer(f5, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f6 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + (1+trial_type+block|pseudonym)'
fit6 <- lmer(f6, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

anova(fit4,fit5,fit6)

# Fit confounders
f7 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + Age_Dmean + (1+trial_type+block|pseudonym)'
fit7 <- lmer(f7, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f8 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + Age_Dmean + Gender + (1+trial_type+block|pseudonym)'
fit8 <- lmer(f8, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

f9 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + Age_Dmean + Gender + RespHandIsDominant + (1+trial_type+block|pseudonym)'
fit9 <- lmer(f9, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

# f10 <- 'log(response_time) ~ 1 + ParticipantType + trial_type + block + Age_Dmean + Gender + RespHandIsDominant + NpsEducYears + (1+trial_type+block|pseudonym)'
# fit10 <- lmer(f10, data=tmp.test, control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = FALSE)

# Model comparisons
anova(fit6, fit7, fit8, fit9)#, fit10)

# Fit interactions: MuMIn-package
fglobal <- 'log(response_time) ~ 1 + ParticipantType*trial_type*block + Age_Dmean + Gender + (1+trial_type+block|pseudonym)'
fitglobal <- lmer(fglobal, data = tmp.test,
            control = lmerControl(optimizer = 'bobyqa', optCtrl=list(maxfun=2e5)), REML = TRUE, na.action = 'na.fail')
ms <- dredge(fitglobal)
par(mar = c(6,8,9,7)+4)
plot(ms, labAsExpr = TRUE) %>% print()
print(ms)[1:20]
# topmod <- get.models(ms, subset=1)[[1]]
# avgmod <- model.avg(ms, subset = delta < 5)
confset.95p <- get.models(ms, cumsum(weight) <= .95)
avgmod.95p <- model.avg(confset.95p)
summary(avgmod)
confint(avgmod.95p)
# confset.95p[[1]]
# topmod <- get.models(ms, subset=1)[[1]]




