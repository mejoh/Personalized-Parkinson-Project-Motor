library(multcomp)

datfile <- 'P:/3024006.02/Data/matlab/TaskTremCorr_TaskTremPower.csv'
dat <- read_csv(datfile) %>%
        rename(pseudonym = sub_corrtrem)
dat <- dat %>%
        mutate(log_ext_power = log(ext_power),
               log_int2_power = log(int2_power),
               log_int3_power = log(int3_power),
               log_catch_power = log(catch_power),
               log_baseline_power = log(baseline_power),
               log_task_power = log(task_power),
               log_ext_power_v_baseline = log_ext_power - log_baseline_power,
               log_int2_power_v_baseline = log_int2_power - log_baseline_power,
               log_int3_power_v_baseline = log_int3_power - log_baseline_power,
               log_catch_power_v_baseline = log_catch_power - log_baseline_power,
               log_task_power_v_baseline = log_task_power - log_baseline_power)
dat.long <- dat %>%
        pivot_longer(cols = ends_with(c('corrtrem','power')),
                     names_to = 'condition',
                     values_to = 'val')

# Heat map 

heatmap(as.matrix(dat[ , c(2:6)]), scale = 'none', margins = c(10,10))                # task-tremor correlation
heatmap(as.matrix(dat[ , c(2:6)]), scale = 'row', margins = c(10,10))                # Row scaled (default) task-tremor correlation
heatmap(as.matrix(dat[ , c(2:6)]), scale = 'column', margins = c(10,10))                # Column scaled (default) task-tremor correlation
heatmap(na.omit(as.matrix(dat[ , c(13:17)])), scale = 'none', margins = c(10,10))        # log power
heatmap(na.omit(as.matrix(dat[ , c(13:17)])), scale = 'row', margins = c(10,10))        # Row scaled (default) log power
heatmap(na.omit(as.matrix(dat[ , c(13:17)])), scale = 'column', margins = c(10,10))     # Column scaled log power

# Correlations between task and tremor regressors

df <- dat.long %>%
        filter(condition == 'ext_corrtrem' | condition == 'int2_corrtrem' | condition == 'int3_corrtrem' | condition == 'catch_corrtrem' | condition == 'bp_corrtrem') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))

        # Example subjects
sublist.pos <- c('sub-POMU76C145E4A8272745', 'sub-POMU76C186E43AFC583D', 'sub-POMU94BBDCE4059E40BB')
sublist.neg <- c('sub-POMUC8CFC2E862084B0E', 'sub-POMUE88704140034927E', 'sub-POMU2E602750DF4453AB', 'sub-POMU020A9277DF9F5A83')
df %>%
        filter(pseudonym %in% sublist.pos)
df %>%
        filter(pseudonym %in% sublist.neg)


# Power during task and baseline

df <- dat.long %>%
        filter(condition == 'log_task_power' | condition == 'log_baseline_power') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))


# Power during conditions relative to baseline

df <- dat.long %>%
        filter(condition == 'log_catch_power' | condition == 'log_ext_power' | condition == 'log_int2_power' | condition == 'log_int3_power' | condition == 'log_baseline_power') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))


# Plot

df %>%
        na.omit %>%
        group_by(condition) %>%
        summarise(n = n(), mean = mean(val), median = median(val), sd = sd(val), se = sd / sqrt(n), lCI = mean - 1.96*se, uCI = mean + 1.96*se)

df %>%
        na.omit %>%
        ggplot(., aes(y = val, x = condition)) + 
        geom_point() + 
        geom_line(aes(group = pseudonym))

df %>%
        na.omit %>%
        ggplot(., aes(y = val, x = condition)) + 
        geom_boxplot()

df %>%
        na.omit %>%
        ggplot(., aes(x =val)) +
        geom_density() + 
        facet_grid(.~condition)

# Infer

df1 <- dat.long %>%
        filter(condition == 'ext_corrtrem' | condition == 'int2_corrtrem' | condition == 'int3_corrtrem' | condition == 'catch_corrtrem' | condition == 'bp_corrtrem') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))
df1 <- dat.long %>%
        filter(condition == 'log_ext_power' | condition == 'log_int2_power' | condition == 'log_int3_power' | condition == 'log_catch_power' | condition == 'log_baseline_power') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))
df1 <- dat.long %>%
        filter(condition == 'log_task_power' | condition == 'log_baseline_power') %>%
        select(pseudonym, condition, val) %>%
        mutate(condition = as.factor(condition))

m1 <- lmer(val ~ 1 + condition + (1|pseudonym), data = df1, REML = FALSE)

summary(m1)
anova(m1)
confint(m1)
summary(glht(m1, linfct = mcp(condition = "Tukey")), test = adjusted("holm"))
