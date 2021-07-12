df.clin.pom <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-04-15.csv')
df.clin.pit <- read_csv('P:/3022026.01/pep/ClinVars/derivatives/database_PIT_clinical_variables_2021-04-15.csv')

df.clin.pom2 <- df.clin.pom %>%
        filter(Timepoint == 'ses-POMVisit1') %>%
        select(pseudonym, Age, Gender, Up3OfTotal, Timepoint, Group)
df.clin.pit2 <- df.clin.pit %>%
        filter(Timepoint == 'ses-PITVisit1') %>%
        select(pseudonym, Age, Gender, Up3OfTotal, Timepoint, Group)

df <- full_join(df.clin.pom2, df.clin.pit2) %>%
        arrange(pseudonym, Timepoint, Group)

outputname <- 'P:/3022026.01/pep/ClinVars/derivatives/database_clinical_confounds_fmri.csv'
write_csv(df, outputname)