df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-08-25.csv')
df.clin.pit <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_PIT_clinical_variables_2021-08-25.csv')

df.clin.pom2 <- df.clin.pom %>%
        filter(Timepoint == 'ses-POMVisit1') %>%
        select(pseudonym, Age, Gender, Up3OfTotal, Timepoint, Group) %>%
        mutate(Gender = as.factor(Gender))
levels(df.clin.pom2$Gender)  <- c('Male', 'Female')
df.clin.pit2 <- df.clin.pit %>%
        filter(Timepoint == 'ses-PITVisit1') %>%
        select(pseudonym, Age, Gender, Up3OfTotal, Timepoint, Group)

df <- full_join(df.clin.pom2, df.clin.pit2) %>%
        arrange(pseudonym, Timepoint, Group) %>%
        filter(!is.na(Group))

outputname <- paste('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_confounds_fmri_', today(), '.csv', sep='')
write_csv(df, outputname)
