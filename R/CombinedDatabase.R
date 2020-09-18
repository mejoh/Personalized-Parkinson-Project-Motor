# Combine motor task performance and clinical variales into a single data frame

##### Import data #####

#Clinical vars
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
dfClinVars <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

#Motor task
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskDatabase.R')
dfMotor <- MotorTaskDatabase('3022026.01')
dfMotor.wide <- dfMotor %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct))
dfMotor.wide <- dfMotor.wide %>%
        mutate(Visit=ifelse(Visit=='ses-Visit1','V1','V3'),
               timepoint=Visit,
               pseudonym=Subject) %>%
        relocate(pseudonym, timepoint) %>%
        select(-c(Subject,Visit,Group))

#####

##### CHECK: Pseudonym overlap between clinical and task #####

# Number of subjects
cat('Number of unique pseudonyms in ClinVars database:', length(unique(dfClinVars$pseudonym)), '\n')
cat('Number of unique pseudonyms in Motor database:', length(unique(dfMotor.wide$pseudonym)), '\n')
cat('Number of intersecting pseudonyms in ClinVars and Motor databases:', length(intersect(dfClinVars$pseudonym,dfMotor.wide$pseudonym)), '\n')
MotInClin <- length(unique(dfClinVars$pseudonym) %in% unique(dfMotor.wide$pseudonym)) - sum(unique(dfClinVars$pseudonym) %in% unique(dfMotor.wide$pseudonym))
cat('This many pseudonyms exist in ClinVars but not in Motor: ', MotInClin, '\n')
ClinInMot <- length(unique(dfMotor.wide$pseudonym) %in% unique(dfClinVars$pseudonym)) - sum(unique(dfMotor.wide$pseudonym) %in% unique(dfClinVars$pseudonym))
cat('This many pseudonyms exist in Motor but not in ClinVars: ', ClinInMot, '\n')

#####

##### Join motor and clinical vars into single data frame #####

df <- full_join(dfClinVars, dfMotor.wide,
           by=c('pseudonym','timepoint'))

#####

##### CHECK: Missing task labels #####

dist.labels <- summary(as.factor(df$MriNeuroPsychTask))
cat('Distribution of task labels: ', '\n')
dist.labels

missing.labels <- summary(df$MriNeuroPsychTask)[3]
cat('Number of pseudonyms that lack task labels: ', '\n', missing.labels)

missing.motor.label <- df %>%
        select(pseudonym, MriNeuroPsychTask, Response.Time_Ext, Percentage.Correct_Ext) %>%
        filter(is.na(MriNeuroPsychTask) & !is.na(Response.Time_Ext)) %>%
        nrow
cat('Number of subjects with motor task data that lack task labels: ', '\n',
    missing.motor.label, '\n',
    'Fixing missing labels for subjects with motor task data...')

for(i in 1:nrow(df)){
        if(is.na(df$MriNeuroPsychTask[i]) && (!is.na(df$Response.Time_Ext[i]) | !is.na(df$Response.Time_Int2[i]) | !is.na(df$Response.Time_Int3[i]))){
                df$MriNeuroPsychTask[i] <- factor('Motor')
        }else if(df$pseudonym[i] == df$pseudonym[i-1] && is.na(df$MriNeuroPsychTask[i])){
                df$MriNeuroPsychTask[i] <- df$MriNeuroPsychTask[i-1]
        }
}

missing.labels <- summary(df$MriNeuroPsychTask)[3]
cat('Number of pseudonyms that lack task labels: ', '\n', missing.labels)

#####

##### Lengthen data frame #####

df.long <- df %>%
        pivot_longer(cols=starts_with('Response.Time'),
                     names_to='Condition',
                     names_pattern='Response.Time_(.*)',
                     values_to='Response.Time') %>%
        select(-c(starts_with('Percentage.Correct')))
Percentage.Correct <- df %>%
        select(starts_with('Percentage.Correct')) %>%
        pivot_longer(cols=c(1:3),
                     names_to = 'Condition',
                     names_pattern='Percentage.Correct_(.*)',
                     values_to='Percentage.Correct') %>%
        select('Percentage.Correct')
df.long <- bind_cols(df.long, Percentage.Correct)

#####

##### Subset by motor task #####

df.long.motor <- df.long %>%
        filter(MriNeuroPsychTask=='Motor')

#####