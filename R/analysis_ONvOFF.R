source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')

##### Generate person-period data frame #####
# Read files
ON.long <- read_csv('P:/3022026.01/pep/bids/derivatives/motor_task.csv')
ON.long <- ON.long %>%
        filter(Visit == 'ses-Visit1')
OFF.long <- read_csv('P:/3022026.01/pep/bids_PIT/derivatives/motor_task.csv')
OFF.long <- OFF.long %>%
        filter(Visit == 'ses-Visit1')

# Reshape
ON.wide <- ON.long %>%
        select(-c(Button.Press.Mean, Button.Press.Repetitions, Button.Press.Sd)) %>%
        reshape_by_task(lengthen = FALSE)
OFF.wide <- OFF.long %>%
        select(-c(Button.Press.Mean, Button.Press.Repetitions, Button.Press.Sd)) %>%
        reshape_by_task(lengthen = FALSE)

# Exclude
ON.wide <- ON.wide %>%
        filter(Percentage.Correct_Ext > 0.25) %>%
        na.omit
OFF.wide <- OFF.wide %>%
        filter(Percentage.Correct_Ext > 0.25) %>%
        na.omit

# Create subject list containing only subjects with both on- and off-state task measurement
POM_subs <- ON.wide$Subject
PIT_subs <- OFF.wide$Subject
All_subs <- c(POM_subs, PIT_subs)
All_subs_unique <- All_subs[duplicated(All_subs)]

# Create data frame
df <- full_join(ON.wide, OFF.wide) %>%
        filter(Subject %in% All_subs_unique) %>%
        mutate(Medication = if_else(Group == 'PD_POM', 'on', 'off'),
               Medication = as.factor(Medication),
               Responding.Hand = as.factor(Responding.Hand)) %>%
        arrange(Subject) %>%
        reshape_by_task
#####

##### Descriptives #####

# Summary statistics
df %>%
        group_by(Medication, Condition) %>%
        summarise(N = n(),
                  avg.RT = mean(Response.Time), sd.RT = sd(Response.Time),
                  se.RT = sd.RT/sqrt(N), upper.RT = avg.RT+1.96*se.RT, lower.RT = avg.RT-1.96*se.RT,
                  avg.PC = mean(Percentage.Correct), sd.PC = sd(Percentage.Correct),
                  se.PC = sd.PC/sqrt(N), upper.PC = avg.PC+1.96*se.PC, lower.PC = avg.PC-1.96*se.PC)

# Spaghetti plot per condition
df %>%
        ggplot(aes(y=Response.Time, x=Medication, group=Subject)) +
        geom_point() +
        geom_line() +
        facet_wrap(~Condition)

# Box plot
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Medication)) +
        geom_boxplot()

# Density plot
df %>%
        ggplot(aes(x=Response.Time, fill=Medication)) +
        geom_density(aes(color=Medication), alpha = 0.5) +
        facet_wrap(~Condition)

#####

##### Mixed effects modelling #####

library(lme4)

contrasts(df$Condition) <- cbind(IntVsExt=c(-2,1,1),
                                  Int3VsInt2=c(0,-1,1))
fmFull <- lmer(log(Response.Time) ~ 1 + Condition*Medication + (1 + Condition + Medication|Subject), data = df, REML = TRUE)
summary(fmFull)
plot(fmFull)
confint.merMod(fmFull, method = 'boot', boot.type = 'basic', nsim = 5000)

#####










