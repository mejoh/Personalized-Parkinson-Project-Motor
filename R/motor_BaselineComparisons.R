source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
library(tidyverse)
library(lme4)
library(lmerTest)

##### Load data #####
# Write csv files
bidsdir_clin <- 'P:/3022026.01/pep/ClinVars/'
bidsdir_POM <- 'P:/3022026.01/pep/bids/'
bidsdir_PIT <- 'P:/3022026.01/pep/bids_PIT/'
#generate_castor_csv(bidsdir_clin)
#generate_motor_task_csv(bidsdir_POM)
#generate_motor_task_csv(bidsdir_PIT)

# Import data
        # Clin vars for POM
df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-02-23.csv')
        # Add LEDD, remove non-medusers
df.ledd <- read_csv('P:/3024006.02/Data/LEDD/MedicationTable.csv')
df.clin.pom <- left_join(df.clin.pom, df.ledd, by = c('pseudonym', 'Timepoint')) %>%
        filter(ParkinMedUser == 'Yes')
        # Add subtypes
df.subtypes <- read_csv('P:/3024006.02/Data/Subtyping/Subtypes.csv')
df.clin.pom <- left_join(df.clin.pom, df.subtypes, by = 'pseudonym')
        # Task data for PIT
df.task.pit <- read_csv('P:/3022026.01/pep/bids_PIT/derivatives/database_motor_task.csv')
        # Temporary fix of groupings, remove once re-BIDScoining has been completed
for(n in 1:length(df.task.pit$Group)){
        d <- paste(bidsdir_PIT, df.task.pit$pseudonym[n], '/', df.task.pit$Timepoint[n], '/dwi', sep = '')
        if(dir.exists(d)){
                df.task.pit$Group[n] <- 'HC_PIT'
        }
}
        # Task data for POM
df.task.pom <- read_csv('P:/3022026.01/pep/bids/derivatives/database_motor_task.csv')
        # Bind everything together
df.task <- full_join(df.task.pit, df.task.pom)
#####

##### Analysis of motor task behavioral data #####
# Display summary statistics, visualization, and carry out ANCOVAs for the following...
# 1. HcOn x ExtInt2Int3
# 2. HcOff x ExtInt2Int3
# 3. OffOn x ExtInt2Int3

# Response times
# HcOn x ExtInt2Int3
        # Data
df <- df.task %>%
        filter(Timepoint == 'ses-Visit1') %>%
        filter(Group == 'HC_PIT' | Group == 'PD_POM') %>%
        select(-c(Button.Press.Mean,Button.Press.Sd,Button.Press.Repetitions)) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Percentage.Correct, Response.Time)) %>%
        filter(Percentage.Correct_Ext > 0.25) %>%
        reshape_by_task %>%
        mutate(Response.Time_log = log(Response.Time),
               Group = as.factor(Group)) %>%
        arrange(pseudonym)
        # Descriptives
df %>%
        group_by(Group, Condition) %>%
        summarise(N = n(), Mean=mean(Response.Time), SD = sd(Response.Time), SE = SD/sqrt(N), lower = Mean-1.96*SE, upper = Mean+1.96*SE)
df %>%
        ggplot(aes(y=Response.Time, x=Group, group=pseudonym)) +
        geom_point(alpha=0.3) +
        facet_wrap(~Condition)
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Group)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Response.Time, fill=Group)) +
        geom_density(aes(color=Group), alpha = 0.5) +
        facet_wrap(~Condition)
        # Inferences
contrasts(df$Condition) <- contr.helmert(3)[c(3:1), 2:1]
contrasts(df$Group) <- contr.helmert(2)
m1 <- lmer(Response.Time_log ~ 1 + Condition*Group + (1|pseudonym), data = df, REML = TRUE)
summary(m1)
plot(m1)
confint.merMod(m1, method = 'boot', boot.type = 'basic', nsim = 5000)


# HcOff x ExtInt2Int3
        # Data
df <- df.task %>%
        filter(Timepoint == 'ses-Visit1') %>%
        filter(Group == 'HC_PIT' | Group == 'PD_PIT') %>%
        select(-c(Button.Press.Mean,Button.Press.Sd,Button.Press.Repetitions)) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Percentage.Correct, Response.Time)) %>%
        filter(Percentage.Correct_Ext > 0.25) %>%
        reshape_by_task %>%
        mutate(Response.Time_log = log(Response.Time),
               Group = as.factor(Group)) %>%
        arrange(pseudonym)
        # Descriptives
df %>%
        group_by(Group, Condition) %>%
        summarise(N = n(), Mean=mean(Response.Time), SD = sd(Response.Time), SE = SD/sqrt(N), lower = Mean-1.96*SE, upper = Mean+1.96*SE)
df %>%
        ggplot(aes(y=Response.Time, x=Group, group=pseudonym)) +
        geom_point(alpha=0.3) +
        facet_wrap(~Condition)
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Group)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Response.Time, fill=Group)) +
        geom_density(aes(color=Group), alpha = 0.5) +
        facet_wrap(~Condition)
        # Inferences
contrasts(df$Condition) <- contr.helmert(3)[c(3:1), 2:1]
contrasts(df$Group) <- contr.helmert(2)*-1
m1 <- lmer(Response.Time_log ~ 1 + Condition*Group + (1|pseudonym), data = df, REML = TRUE)
summary(m1)
plot(m1)
confint.merMod(m1, method = 'boot', boot.type = 'basic', nsim = 5000)


# OffOn x ExtInt2Int3
        # Data
df <- df.task %>%
        filter(Timepoint == 'ses-Visit1') %>%
        filter(Group == 'PD_PIT' | Group == 'PD_POM') %>%
        select(-c(Button.Press.Mean,Button.Press.Sd,Button.Press.Repetitions)) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Percentage.Correct, Response.Time)) %>%
                filter(Percentage.Correct_Ext > 0.25)
POM_subs <- df %>% filter(Group == 'PD_POM') %>% select(pseudonym)
PIT_subs <- df %>% filter(Group == 'PD_PIT') %>% select(pseudonym)
All_subs <- c(POM_subs$pseudonym, PIT_subs$pseudonym)
All_subs_unique <- All_subs[duplicated(All_subs)]
df <- df %>%
        filter(pseudonym %in% All_subs_unique) %>%
        reshape_by_task %>%
        mutate(Response.Time_log = log(Response.Time),
               Group = as.factor(Group)) %>%
        arrange(pseudonym)

        # Descriptives
df.table <- df %>%
        group_by(Group, Condition) %>%
        summarise(N = n(), Mean=mean(Response.Time), SD = sd(Response.Time), SE = SD/sqrt(N), lower = Mean-1.96*SE, upper = Mean+1.96*SE)
df %>%
        ggplot(aes(y=Response.Time, x=Group, group=pseudonym)) +
        geom_point() +
        geom_line() +
        facet_wrap(~Condition)
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Group)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Response.Time, fill=Group)) +
        geom_density(aes(color=Group), alpha = 0.5) +
        facet_wrap(~Condition)
        # Inferences
#df <- df %>%
 #       mutate(Condition = as.factor(if_else(Condition == 'Ext', 'Ext', 'Int')))
contrasts(df$Condition) <- contr.helmert(3)[c(3:1), 2:1]
contrasts(df$Group) <- contr.helmert(2)
m1 <- lmer(Response.Time_log ~ 1 + Condition*Group + (1 + Group|pseudonym), data = df, REML = TRUE)
summary(m1)
plot(m1)
confint.merMod(m1, method = 'boot', boot.type = 'basic', nsim = 500)

#####

##### Analysis of clinical data (POM only) #####
# Display summary statistics, visualizations, and carry out ANCOVAs for the following...
# 1. MDS-UPDRS III Total: Time x Medication
# 2. MDS-UPDRS III Bradykinesia: Time x Medication
# 3. MDS-UPDRS III Rigidity: Time x Medication
# 4. MDS-UPDRS III Resting tremor: Time x Medication
# 5. MDS-UPDRS III PIGD: Time x Medication (not yet available!)

# UPDRS Total, Time x Medication
        # Data
df <- df.clin.pom %>%
        filter((Timepoint == 'ses-Visit1' | Timepoint == 'ses-Visit2') & MultipleSessions == 'Yes' & MriNeuroPsychTask == 'Motor') %>%
        select(pseudonym, Age, Gender, EstDisDurYears, Timepoint, TimeToFUYears, LEDD,
               Up3OfTotal, Up3OnTotal, Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta) %>%
        na.omit

df <- reshape_by_medication(df, lengthen = TRUE)
df <- df %>% pivot_wider(names_from='Subscore',
                           names_prefix='Up3',
                           values_from = 'Severity')
levels(df$Medication) <- c('Off','On')

df <- df %>%
        mutate(Gender = as.factor(Gender),
               Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE),
               LEDD_c = scale(LEDD, center = TRUE, scale = FALSE))
        # Descriptives
df %>%
        group_by(Timepoint, Medication) %>%
        summarise(N = n(), Mean=mean(Up3Total), SD = sd(Up3Total), SE = SD/sqrt(N), lower = Mean-1.96*SE, upper = Mean+1.96*SE)
df %>%
        ggplot(aes(y=Up3Total, x=Medication, group=pseudonym)) +
        geom_point() +
        geom_line(alpha = .4) +
        facet_wrap(~Timepoint)
df %>%
        ggplot(aes(y=Up3Total, x=Timepoint, group=pseudonym)) +
        geom_point() +
        geom_line(aes(color=Up3Total.1YearDelta), alpha = .7, lwd = 0.9) +
        scale_color_gradient2(low = 'blue', high = 'red') +
        facet_wrap(~Medication)
df %>%
        ggplot(aes(y=Up3Total, x=Medication, color=Timepoint)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Up3Total, fill=Timepoint)) +
        geom_density(aes(color=Timepoint), alpha = 0.5) +
        facet_wrap(~Medication)
        # Inferences
contrasts(df$Gender) <- contr.helmert(2)
contrasts(df$Medication) <- contr.helmert(2)

m1 <- lmer(Up3Total ~ 1 + TimeToFUYears*Medication + Gender + Age_c + (1 + TimeToFUYears + Medication|pseudonym), data = df, REML = TRUE)
summary(m1)
plot(m1)

#####

##### Correlations: Severity / Progression ~ Behavioral performance #####

# Data
        # Assemble and prepare data frames
df.BA_Severity <- df.clin.pom %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Up3OfTotal, Up3OnTotal, Age, Gender, EstDisDurYears) %>%
        na.omit
df.Prog <- df.clin.pom %>%
        filter(MriNeuroPsychTask == 'Motor') %>%
        filter(MultipleSessions == 'Yes') %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Up3OfTotal, Up3OnTotal, Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta, Age, Gender, EstDisDurYears) %>%
        na.omit
df.RTs <- df.task.pom %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Condition, Response.Time, Percentage.Correct) %>%
        mutate(Response.Time = round(Response.Time, 3)) %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct)) %>%
        filter(Percentage.Correct_Ext > 0.25) %>%
        select(-c(Percentage.Correct_Ext, Percentage.Correct_Int2, Percentage.Correct_Int3)) %>%
        na.omit
        # Join clinical and behavioral performance data
df1 <- left_join(df.BA_Severity, df.RTs, by = "pseudonym") %>%
        na.omit %>%
        mutate(Response.Time_Int = (Response.Time_Int2 + Response.Time_Int3)/2,
               Response.Time_ExtInt = (Response.Time_Ext + Response.Time_Int2 + Response.Time_Int3)/3,
               Response.Time_DeltaIntExt = ((Response.Time_Int2 + Response.Time_Int3)/2) - Response.Time_Ext) %>%
        select(-c(Response.Time_Int2, Response.Time_Int3)) %>%
        pivot_longer(cols = c(Response.Time_Ext, Response.Time_Int, Response.Time_ExtInt, Response.Time_DeltaIntExt),
                     names_prefix = 'Response.Time_',
                     names_to = 'Condition',
                     values_to = 'Response.Time') %>%
        reshape_by_medication %>%
        mutate(Medication = if_else(Medication == 'Up3Of', 'Off', 'On'),
               Subscore = 'BA') %>%
        pivot_wider(names_from = Subscore,
                    values_from = Severity)
df2 <- left_join(df.Prog, df.RTs, by = "pseudonym") %>%
        na.omit %>%
        mutate(Response.Time_Int = (Response.Time_Int2 + Response.Time_Int3)/2,
               Response.Time_ExtInt = (Response.Time_Ext + Response.Time_Int2 + Response.Time_Int3)/3,
               Response.Time_DeltaIntExt = ((Response.Time_Int2 + Response.Time_Int3)/2) - Response.Time_Ext) %>%
        select(-c(Response.Time_Int2, Response.Time_Int3)) %>%
        pivot_longer(cols = c(Response.Time_Ext, Response.Time_Int, Response.Time_ExtInt, Response.Time_DeltaIntExt),
                     names_prefix = 'Response.Time_',
                     names_to = 'Condition',
                     values_to = 'Response.Time') %>%
        reshape_by_medication %>%
        mutate(Medication = if_else(Medication == 'Up3Of', 'Off', 'On'),
               Subscore = if_else(grepl('1YearDelta', Subscore),'Prog','BA')) %>%
        pivot_wider(names_from = Subscore,
                    values_from = Severity)

# Descriptives

df1 %>% 
        ggplot(aes(y=BA, x=Response.Time, color = Medication, group = Medication)) +
        geom_point(alpha = .5) +
        geom_smooth(method='lm') +
        facet_wrap(~Condition) +
        labs(title = 'Baseline severity') + xlab('Response time') + ylab('MDS-UPDRS III Total (baseline)')
df2 %>%
        ggplot(aes(y=Prog, x=Response.Time, color = Medication, group = Medication)) +
        geom_point(alpha = .5) +
        geom_smooth(method='lm') +
        facet_wrap(~Condition) +
        labs(title = 'Progression') + xlab('Response time') + ylab('MDS-UPDRS III Total (1-year progression)')

# Inferences

        # Baseline severity (off) ~ Mean(ExtInt) RTs
df_extint <- df1 %>%
        filter(Condition == 'ExtInt') %>%
        filter(Medication == 'Off')
m1 <- lm(BA ~ 1 + 
                   log(Response.Time) + 
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_extint)
summary(m1)
anova(m1)
plot(m1)
        # Baseline severity (off) ~ Ext RTs
df_ext <- df1 %>%
        filter(Condition == 'Ext') %>%
        filter(Medication == 'Off')
m1 <- lm(BA ~ 1 + 
                   log(Response.Time) + 
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_ext)
summary(m1)
anova(m1)
plot(m1)
        # Baseline severity (off) ~ Int RTs
df_int <- df1 %>%
        filter(Condition == 'Int') %>%
        filter(Medication == 'Off')
m1 <- lm(BA ~ 1 + 
                   log(Response.Time) +
                   scale(Age, center=TRUE, scale =FALSE) +
                   Gender, data = df_int)
summary(m1)
anova(m1)
plot(m1)
        # Baseline severity (off) ~ Int-Ext RTs
df_extint <- df1 %>%
        filter(Condition == 'DeltaIntExt') %>%
        filter(Medication == 'Off')
m1 <- lm(BA ~ 1 + 
                 Response.Time + 
                 scale(Age, center=TRUE, scale=FALSE) +
                 Gender, data = df_extint)
summary(m1)
anova(m1)
plot(m1)

        # Progression (off) ~ Mean(ExtInt) RTs
df_extint <- df2 %>%
        filter(Condition == 'ExtInt') %>%
        filter(Medication == 'Off')
m1 <- lm(Prog ~ 1 + 
                   log(Response.Time) +
                   scale(BA, center=TRUE, scale=FALSE) + 
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_extint)
summary(m1)
anova(m1)
plot(m1)
        # Progression (off) ~ Ext RTs
df_ext <- df2 %>%
        filter(Condition == 'Ext') %>%
        filter(Medication == 'Off')
m1 <- lm(Prog ~ 1 + 
                   log(Response.Time) +
                   scale(BA, center=TRUE, scale=FALSE) + 
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_ext)
summary(m1)
anova(m1)
plot(m1)
        # Progression (off) ~ Int RTs
df_int <- df2 %>%
        filter(Condition == 'Int') %>%
        filter(Medication == 'Off')
m1 <- lm(Prog ~ 1 + 
                   log(Response.Time) +
                   scale(BA, center=TRUE, scale=FALSE) +
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_int)
summary(m1)
anova(m1)
plot(m1)
        # Progression (off) ~ Int-Ext RTs
df_extint <- df2 %>%
        filter(Condition == 'DeltaIntExt') %>%
        filter(Medication == 'Off')
m1 <- lm(Prog ~ 1 + 
                   Response.Time +
                   scale(BA, center=TRUE, scale=FALSE) + 
                   scale(Age, center=TRUE, scale=FALSE) +
                   Gender, data = df_extint)
summary(m1)
anova(m1)
plot(m1)


#confint.merMod(m1, method = 'boot', boot.type = 'basic', nsim = 5000)

#####

##### Write files for analyses: Severity / Progression ~ VOI #####
# The purpose of this section is to put together a 
# data set that can be load into JASP for bayesian
# regression analysis. This section can later be 
# expanded to include bayesian regression in R's 
# implementation (using brms)

# Before running this section, go through the following steps:
# 1. Run group analysis
# 2. Extract VOIs from significant clusters
# 3. Run 'motor_extractvoi.m' to clean up the VOIs
# The code below will attach clinical vars to the 
# csv files that were generated in step 3 for each 
# cluster. All these csv files will then be put together
# according to the imaging group result they belong to

# Prepare clinical data
df.clin_corr <- df.clin.pom %>%
        filter(MriNeuroPsychTask == 'Motor',
               Timepoint == 'ses-Visit1',
               EstDisDurYears > 0) %>%
        select(pseudonym, Age, Gender, EstDisDurYears,
               Up3OfTotal, Up3OfTotal.1YearDelta,
               Up3OfBradySum, Up3OfBradySum.1YearDelta,
               Up3OfRestTremAmpSum, Up3OfRestTremAmpSum.1YearDelta,
               Up3OfRigiditySum, Up3OfRigiditySum.1YearDelta,
               Up3OfPIGDSum, Up3OfPIGDSum.1YearDelta) %>%
        mutate(Gender = if_else(Gender == 'Male', 1, 0))

# Prepare task data
df.task_corr <- df.task.pom %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Condition, Response.Time) %>%
        pivot_wider(names_from = Condition,
                    values_from = Response.Time) %>%
        mutate(RT.Ext = Ext,
               RT.Int2 = Int2,
               RT.Int3 = Int3,
               RT.Int = (Int2 + Int3) / 2,
               RT.ExtInt = (Ext + ((Int2 + Int3) / 2)) / 2,
               RT.DeltaIntExt = RT.Int-RT.Ext) %>%
        select(-c(Ext,Int2,Int3))

# Prepare VOIs
dVOI <- 'P:/3024006.02/Analyses/VOIs'
fVOI <- dir(dVOI, 'VOI.*.csv', full.names = TRUE)
fVOI <- fVOI[!mapply(grepl, 'ClinVars', fVOI)]

# Write clinical variables, brain activity, and behavioral performance into wide-format csv files
for(f in 1:length(fVOI)){
        datVOI <- read_csv(fVOI[f])  %>%
                filter(Group == 'Patient') %>%
                pivot_wider(names_from = Cond,
                        values_from = Vals) %>%
                mutate(Brain.Ext = Ext,
                       Brain.Int = (Int2 + Int3)/2,
                       Brain.ExtInt = (Ext + Int2 + Int3)/3,
                       Brain.DeltaIntExt = Brain.Int - Brain.Ext) %>%
                select(-c(Ext, Int2, Int3, Group))

        df <- inner_join(df.clin_corr, datVOI, by = 'pseudonym')
        df <- inner_join(df, df.task_corr, by = 'pseudonym')
        fOutput <- paste(tools::file_path_sans_ext(fVOI[f]),'_ClinVars.csv',sep='')
        write_csv(df, fOutput)
}

# Write csv file in wide-format by brain region to enable clustering
# Analysis: HC>ON Mean(ExtInt), ROI=Whole-brain
        # Data files
fDat_ROI.Whole_Mean <- c('P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_Mean_LeftM1_ClinVars.csv',
                    'P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_Mean_LeftPutamen_ClinVars.csv',
                    'P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_Mean_RightCB_ClinVars.csv',
                    'P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_Mean_RightM1_ClinVars.csv',
                    'P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_Mean_SMA_ClinVars.csv')

        # Generate data frame
df.Whole_Mean <- read_csv(fDat_ROI.Whole_Mean[1])
for(f in 2:length(fDat_ROI.Whole_Mean)){
        dat <- read_csv(fDat_ROI.Whole_Mean[f])
        df.Whole_Mean <- full_join(df.Whole_Mean, dat)
}

        # Transformations
df.Whole_Mean <- df.Whole_Mean %>%
        mutate(Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE))#,
#               Up3OfTotal_log = log(Up3OfTotal),
#               Up3OfBradySum_log = log(Up3OfBradySum),
#               Up3OfRestTremAmpSum_log = log(Up3OfRestTremAmpSum + 0.001),
#               Brain.Ext_log = log(Brain.Ext + abs(min(Brain.Ext)) + 0.001),
#               Brain.Int_log = log(Brain.Int + abs(min(Brain.Int)) + 0.001),
#               Brain.ExtInt_log = log(Brain.ExtInt + abs(min(Brain.ExtInt)) + 0.001),
#               Brain.DeltaIntExt_log = log(Brain.DeltaIntExt + abs(min(Brain.DeltaIntExt)) + 0.001),
#               RT.Ext_log = log(RT.Ext),
#               RT.Int_log = log(RT.Int),
#               RT.ExtInt_log = log(RT.ExtInt),
#               RT.DeltaIntExt_log = log(RT.DeltaIntExt + abs(min(RT.DeltaIntExt)) + 0.001))

        # Add ROI names
df.Whole_Mean <- df.Whole_Mean %>%
        arrange(pseudonym)
roinames <- c('LeftM1', 'LeftPutamen', 'RightCB', 'RightM1', 'SMA')
roinames <- tibble(ROI = rep(roinames, length(unique(df.Whole_Mean$pseudonym))))
df.Whole_Mean <- bind_cols(df.Whole_Mean, roinames)
df.Whole_Mean <- df.Whole_Mean %>%
        pivot_wider(names_from = ROI,
                    values_from = c(Brain.Ext,Brain.Int,Brain.ExtInt,Brain.DeltaIntExt))#,
                                    #Brain.Ext_log,Brain.Int_log,Brain.ExtInt_log,Brain.DeltaIntExt_log))

        # Write csv
OutputName <- paste(dirname(fDat_ROI.Whole_Mean[1]), '/VOI_ROI-Whole_Con-HCvPD_Mean_AllRois_ClinVars.csv', sep = '')
write_csv(df.Whole_Mean, OutputName)


# Analysis: HC>ON, Ext>Int or Int>Ext, ROI=Whole-brain
        # Data files
fDat_ROI.Whole_EXTvINT <- c('P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD_EXTvINT_PreSMA_ClinVars.csv',
                            'P:/3024006.02/Analyses/VOIs/VOI_ROI-Whole_Con-HCvPD-EXTvINT_RightPFC_ClinVars.csv')

        # Generate data frame
df.Whole_EXTvINT <- read_csv(fDat_ROI.Whole_EXTvINT[1])
for(f in 2:length(fDat_ROI.Whole_EXTvINT)){
        dat <- read_csv(fDat_ROI.Whole_EXTvINT[f])
        df.Whole_EXTvINT <- full_join(df.Whole_EXTvINT, dat)
}

        # Transformations
df.Whole_EXTvINT <- df.Whole_EXTvINT %>%
        mutate(Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE))#,
#               Up3OfTotal_log = log(Up3OfTotal),
#               Up3OfBradySum_log = log(Up3OfBradySum),
#               Up3OfRestTremAmpSum_log = log(Up3OfRestTremAmpSum + 0.001),
#               Brain.Ext_log = log(Brain.Ext + abs(min(Brain.Ext)) + 0.001),
#               Brain.Int_log = log(Brain.Int + abs(min(Brain.Int)) + 0.001),
#               Brain.ExtInt_log = log(Brain.ExtInt + abs(min(Brain.ExtInt)) + 0.001),
#               Brain.DeltaIntExt_log = log(Brain.DeltaIntExt + abs(min(Brain.DeltaIntExt)) + 0.001),
#               RT.Ext_log = log(RT.Ext),
#               RT.Int_log = log(RT.Int),
#               RT.ExtInt_log = log(RT.ExtInt),
#               RT.DeltaIntExt_log = log(RT.DeltaIntExt + abs(min(RT.DeltaIntExt)) + 0.001))

        # Add ROI names
df.Whole_EXTvINT <- df.Whole_EXTvINT %>%
        arrange(pseudonym)
roinames <- c('PreSMA', 'RightPFC')
roinames <- tibble(ROI = rep(roinames, length(unique(df.Whole_EXTvINT$pseudonym))))
df.Whole_EXTvINT <- bind_cols(df.Whole_EXTvINT, roinames)
df.Whole_EXTvINT <- df.Whole_EXTvINT %>%
        pivot_wider(names_from = ROI,
                    values_from = c(Brain.Ext,Brain.Int,Brain.ExtInt,Brain.DeltaIntExt))#,
                                    #Brain.Ext_log,Brain.Int_log,Brain.ExtInt_log,Brain.DeltaIntExt_log))

        # Write csv
OutputName <- paste(dirname(fDat_ROI.Whole_EXTvINT[1]), '/VOI_ROI-Whole_Con-HCvPD_EXTvINT_AllRois_ClinVars.csv', sep = '')
write_csv(df.Whole_EXTvINT, OutputName)


# Analysis: HC>ON, Mean(ExtInt), ROI=BiPutamen
        # Data files
fDat_ROI.Put_Mean <- c('P:/3024006.02/Analyses/VOIs/VOI_ROI-Putamen_Con-HCvPD_Mean_LeftPutamen_ClinVars.csv',
                       'P:/3024006.02/Analyses/VOIs/VOI_ROI-Putamen_Con-HCvPD_Mean_RightPutamen_ClinVars.csv')

        # Generate data frame
df.Put_Mean <- read_csv(fDat_ROI.Put_Mean[1])
for(f in 2:length(fDat_ROI.Put_Mean)){
        dat <- read_csv(fDat_ROI.Put_Mean[f])
        df.Put_Mean <- full_join(df.Put_Mean, dat)
}

        # Transformations
df.Put_Mean <- df.Put_Mean %>%
        mutate(Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE))#,
#               Up3OfTotal_log = log(Up3OfTotal),
#               Up3OfBradySum_log = log(Up3OfBradySum),
#               Up3OfRestTremAmpSum_log = log(Up3OfRestTremAmpSum + 0.001),
#               Brain.Ext_log = log(Brain.Ext + abs(min(Brain.Ext)) + 0.001),
#               Brain.Int_log = log(Brain.Int + abs(min(Brain.Int)) + 0.001),
#               Brain.ExtInt_log = log(Brain.ExtInt + abs(min(Brain.ExtInt)) + 0.001),
#               Brain.DeltaIntExt_log = log(Brain.DeltaIntExt + abs(min(Brain.DeltaIntExt)) + 0.001),
#               RT.Ext_log = log(RT.Ext),
#               RT.Int_log = log(RT.Int),
#               RT.ExtInt_log = log(RT.ExtInt),
#               RT.DeltaIntExt_log = log(RT.DeltaIntExt + abs(min(RT.DeltaIntExt)) + 0.001))

        # Add ROI names
df.Put_Mean <- df.Put_Mean %>%
        arrange(pseudonym)
roinames <- c('LeftPutamen', 'RightPutamen')
roinames <- tibble(ROI = rep(roinames, length(unique(df.Whole_EXTvINT$pseudonym))))
df.Put_Mean <- bind_cols(df.Put_Mean, roinames)
df.Put_Mean <- df.Put_Mean %>%
        pivot_wider(names_from = ROI,
                    values_from = c(Brain.Ext,Brain.Int,Brain.ExtInt,Brain.DeltaIntExt))#,
                                    #Brain.Ext_log,Brain.Int_log,Brain.ExtInt_log,Brain.DeltaIntExt_log))

        # Write csv
OutputName <- paste(dirname(fDat_ROI.Put_Mean[1]), '/VOI_ROI-Putamen_Con-HCvPD_Mean_AllRois_ClinVars.csv', sep = '')
write_csv(df.Put_Mean, OutputName)

#####

##### Subtyping comparisons #####

# Response times
        # Data
df_subtype <- df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1') %>%
        select(pseudonym, Subtype, Age, Gender, EstDisDurYears)
df_t <- df.task %>%
        filter(Group == 'PD_POM',
               Timepoint == 'ses-Visit1')
df_t <- left_join(df_t, df_subtype, by = 'pseudonym')
PoorPerformanceIndex <- df_t$Percentage.Correct[df_t$Condition == 'Ext'] < 0.25
PoorPerformancePseudos <- unique(df_t$pseudonym)[PoorPerformanceIndex]
df_t_clean <- df_t %>%
        filter(!pseudonym %in% PoorPerformancePseudos)
df <- df_t_clean %>%
        filter(Condition != 'Catch',
               !is.na(Subtype)) %>%
        mutate(Subtype = as.factor(Subtype),
               Condition = as.factor(Condition),
               Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE),
               Response.Time_log = log(Response.Time))
        # Descriptives
df %>%
        group_by(Subtype, Condition) %>%
        summarise(N = n(), Mean=mean(Response.Time), SD = sd(Response.Time), SE = SD/sqrt(N), lower = Mean-1.96*SE, upper = Mean+1.96*SE)
df %>%
        ggplot(aes(y=Response.Time, x=Subtype, group=pseudonym)) +
        geom_point(alpha=0.3) +
        facet_wrap(~Condition)
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Subtype)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Response.Time, fill=Subtype)) +
        geom_density(aes(color=Subtype), alpha = 0.5) +
        facet_wrap(~Condition)
        # Inferences
contrasts(df$Condition) <- contr.helmert(3)[c(3:1), 2:1]
m1 <- lmer(Response.Time_log ~ 1 + Condition*Subtype + Age_c + Gender + EstDisDurYears_c + (1|pseudonym), data = df, REML = TRUE)
summary(m1)
anova(m1)

# Error rates

# Disease progression
df <- df.clin.pom %>%
        filter(MultipleSessions == 'Yes',
               !is.na(Subtype),
               MriNeuroPsychTask == 'Motor') %>%
        select(pseudonym, Timepoint, Age, Gender, EstDisDurYears, LEDD, ParkinMedUser, Subtype, TimeToFUYears,
               Up3OfTotal, Up3OfBradySum, Up3OfRestTremAmpSum, Up3OfRigiditySum, Up3OfPIGDSum,
               Up3OfTotal.1YearDelta, Up3OfBradySum.1YearDelta, Up3OfRestTremAmpSum.1YearDelta, Up3OfRigiditySum.1YearDelta, Up3OfPIGDSum.1YearDelta) %>%
        mutate(Subtype = as.factor(Subtype),
               Age_c = scale(Age, center = TRUE, scale = FALSE),
               EstDisDurYears_c = scale(EstDisDurYears, center = TRUE, scale = FALSE),
               LEDD_c = scale(LEDD, center = TRUE, scale = FALSE))
        # Descriptives
df %>%
        filter(Timepoint == 'ses-Visit1') %>%
        group_by(Subtype) %>%
        summarise(n = n(),
                  Age.m = mean(Age), Age.sd = sd(Age),
                  DisDur.m = mean(EstDisDurYears), DisDur.s = sd(EstDisDurYears),
                  LEDD.m = mean(LEDD, na.rm = TRUE), LEDD.s = sd(LEDD, na.rm = TRUE),
                  Total.m = mean(Up3OfTotal.1YearDelta, na.rm = TRUE), Total.s = sd(Up3OfTotal.1YearDelta, na.rm = TRUE),
                  Brady.m = mean(Up3OfBradySum.1YearDelta, na.rm = TRUE), Brady.s = sd(Up3OfBradySum.1YearDelta, na.rm = TRUE),
                  RestTrem.m = mean(Up3OfRestTremAmpSum.1YearDelta, na.rm = TRUE), RestTrem.s = sd(Up3OfRestTremAmpSum.1YearDelta, na.rm = TRUE),
                  Rig.m = mean(Up3OfRigiditySum.1YearDelta, na.rm = TRUE), Rig.s = sd(Up3OfRigiditySum.1YearDelta, na.rm = TRUE),
                  PIGD.m = mean(Up3OfPIGDSum.1YearDelta, na.rm = TRUE), PIGD.s = sd(Up3OfPIGDSum.1YearDelta, na.rm = TRUE))
df %>%
        ggplot(aes(y=Up3OfTotal, x=TimeToFUYears, group=pseudonym)) +
        geom_point(alpha=0.3) +
        facet_wrap(~Subtype)
df %>%
        ggplot(aes(y=Response.Time, x=Condition, color=Subtype)) +
        geom_boxplot()
df %>%
        ggplot(aes(x=Up3OfTotal, fill=Timepoint)) +
        geom_density(aes(color=Timepoint), alpha = 0.5) +
        facet_wrap(~Subtype)
        # Inferences
m1 <- lmer(Up3OfTotal ~ 1 + Subtype*TimeToFUYears + Age_c + Gender + EstDisDurYears_c + LEDD_c + (1|pseudonym), data = df, REML = TRUE)
summary(m1)
anova(m1)

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

##### Demographics #####

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(N = n())

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(Age.avg = mean(Age, na.rm = TRUE), Age.sd = sd(Age, na.rm = TRUE))

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(DiseaseDuration.avg = mean(EstDisDurYears, na.rm = TRUE), DiseaseDuration.sd = sd(EstDisDurYears, na.rm = TRUE))

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        select(Gender) %>%
        table

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(Up3OfTotal.avg = mean(Up3OfTotal, na.rm = TRUE), Up3OfTotal.sd = sd(Up3OfTotal, na.rm = TRUE))
df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(Up3OnTotal.avg = mean(Up3OnTotal, na.rm = TRUE), Up3OnTotal.sd = sd(Up3OnTotal, na.rm = TRUE))

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(Up3OfTotal.1YearDelta.avg = mean(Up3OfTotal.1YearDelta, na.rm = TRUE), Up3OfTotal.1YearDelta.sd = sd(Up3OfTotal.1YearDelta, na.rm = TRUE))
df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(Up3OnTotal.1YearDelta.avg = mean(Up3OnTotal.1YearDelta, na.rm = TRUE), Up3OnTotal.1YearDelta.sd = sd(Up3OnTotal.1YearDelta, na.rm = TRUE))

df.clin.pom %>%
        filter(Timepoint == 'ses-Visit1',
               MriNeuroPsychTask == 'Motor') %>%
        summarise(LEDD.avg = round(mean(LEDD, na.rm = TRUE)), LEDD.sd = round(sd(LEDD, na.rm = TRUE)))
ggplot(df.clin.pom, aes(y=LEDD)) + 
        geom_boxplot()

#####