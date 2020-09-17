# Combine motor task performance and clinical variales into a single data frame

##### Import data #####

#Clinical vars
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsGenerateDataFrame.R')
dfClinVars <- ClinicalVarsGenerateDataFrame(rerun = FALSE)

#Motor task
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskDatabase.R')
dfMotor <- MotorTaskDatabase('3022026.01')
dfMotor.nomiss <- dfMotor[complete.cases(dfMotor), ]
dfMotor.nomiss.wide <- dfMotor.nomiss %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct))
dfMotor.nomiss.wide <- dfMotor.nomiss.wide %>%
        mutate(Visit=ifelse(Visit=='ses-Visit1','V1','V3'),
               timepoint=Visit,
               pseudonym=Subject) %>%
        select(-c(Subject,Visit,Group))

#####

##### Join motor and clinical vars into single data frame #####

df <- full_join(dfClinVars, dfMotor.nomiss.wide,
           by=c('pseudonym','timepoint'))

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
df.long <- cbind(df.long, Percentage.Correct)

#####