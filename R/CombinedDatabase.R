# Combine motor task performance and clinical variables into a single data frame

CombinedDatabase <- function(){

##### Libraries #####
library(tidyverse)
#####

##### Import data #####

#Clinical vars
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
dfClinVars <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

#Motor task
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskGenerateDataFrame.R')
dfMotor <- MotorTaskGenerateDataFrame(rerun = FALSE)
dfMotor.wide <- dfMotor %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct, Button.Press.Mean, Button.Press.Sd))
dfMotor.wide <- dfMotor.wide %>%
        mutate(Visit=ifelse(Visit=='ses-Visit1','V1','V3'),
               timepoint=as.factor(Visit),
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
cat('Number of pseudonyms that lack task labels: ', '\n', missing.labels, '\n')

missing.motor.label <- df %>%
        select(pseudonym, MriNeuroPsychTask, Response.Time_Ext, Response.Time_Int2, Response.Time_Int3, Percentage.Correct_Ext, Percentage.Correct_Int2, Percentage.Correct_Int3) %>%
        filter(is.na(MriNeuroPsychTask) & (!is.na(Response.Time_Ext) | !is.na(Response.Time_Int2) | !is.na(Response.Time_Int3) | !is.na(df$Percentage.Correct_Ext) | !is.na(df$Percentage.Correct_Int2) | !is.na(df$Percentage.Correct_Int3))) %>%
        nrow
cat('Number of subjects with motor task data that lack task labels: ', '\n',
    missing.motor.label, '\n',
    'Fixing missing labels for subjects with motor task data...', '\n')

for(i in 1:nrow(df)){
        if(is.na(df$MriNeuroPsychTask[i]) && (!is.na(df$Response.Time_Ext[i]) | !is.na(df$Response.Time_Int2[i]) | !is.na(df$Response.Time_Int3[i]) | !is.na(df$Percentage.Correct_Ext[i]) | !is.na(df$Percentage.Correct_Int2[i]) | !is.na(df$Percentage.Correct_Int3[i]))){
                df$MriNeuroPsychTask[i] <- factor('Motor')
        }else if(df$pseudonym[i] == df$pseudonym[i-1] && is.na(df$MriNeuroPsychTask[i])){
                df$MriNeuroPsychTask[i] <- df$MriNeuroPsychTask[i-1]
        }
}

missing.labels <- summary(df$MriNeuroPsychTask)[3]
cat('Number of pseudonyms that lack task labels: ', '\n', missing.labels, '\n')

#####

##### CHECK: Multiple session labels #####

dist.labels <- summary(as.factor(df$MultipleSessions))
cat('Distribution of multiple sessions labels: ', '\n')
dist.labels

missing.labels <- summary(df$MultipleSessions)[3]
cat('Number of pseudonyms that lack multiple sessions labels: ', '\n', missing.labels, '\n')

cat('Fixing multiple sessions labels', '\n')
for(n in unique(df$pseudonym)){
        if(length(df[df$pseudonym == n, ]$timepoint) > 1){
                df[df$pseudonym == n, ]$MultipleSessions <- 'Yes'
        }else{
                df[df$pseudonym == n, ]$MultipleSessions <- 'No'
        }
}

#####

##### Subset by motor task #####

df.motor <- df %>%
        filter(MriNeuroPsychTask=='Motor')

#####

##### Lengthen data frame #####

df.motor.long <- df.motor %>%
        pivot_longer(cols=starts_with('Response.Time'),
                     names_to='Condition',
                     names_pattern='Response.Time_(.*)',
                     values_to='Response.Time') %>%
        select(-c(starts_with('Percentage.Correct')))
Percentage.Correct <- df.motor %>%
        select(starts_with('Percentage.Correct')) %>%
        pivot_longer(cols=c(1:3),
                     names_to = 'Condition',
                     names_pattern='Percentage.Correct_(.*)',
                     values_to='Percentage.Correct') %>%
        select('Percentage.Correct')
df.motor.long <- bind_cols(df.motor.long, Percentage.Correct)
df.motor.long$Condition <- as.factor(df.motor.long$Condition)

#####

##### CHECK: Important characteristics and missing data #####

# Unique pseudonyms
n.pseudos <- length(unique(df.motor.long$pseudonym))
cat('Number of unique pseudonyms after subsetting for motor task: ', n.pseudos, '\n')

# Timepoint
cat('Number of subjects per timepoint after subsetting for motor task: ', '\n')
table(df.motor.long$timepoint) / 3


# Check for missing data
CheckMissing <- function(dataframe, t, v){
        nm <- dataframe %>% filter(timepoint==t) %>% select(any_of(v)) %>% is.na %>% sum / 3
        cat('Missing ', v, 'at timepoint', t, ': ', nm, '\n')
}
        # Motor task data
timepoint <- c('V1','V3')
vars <- c('Response.Time', 'Percentage.Correct')
for(t in timepoint){
        for(v in vars){
        CheckMissing(df.motor.long, t, v)
        }
}
        # UPDRS3
timepoint <- c('V1','V2')
vars <- c('Up3OfTotal', 'Up3OnTotal', 'Up3OfBradySum', 'Up3OnBradySum')
for(t in timepoint){
        for(v in vars){
                CheckMissing(df.motor.long, t, v)
        }
}
#####

print(df.motor.long)

}