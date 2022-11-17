clinvars_for_mri <- function(inputfile, outputfile, varlist){
    
        library(tidyverse)
        
        # inputfile <- 'P:/3022026.01/pep/ClinVars2/derivatives/merged_manipulated_2022-04-12_ba-diag.csv'
        inputfile <- 'P:/3022026.01/pep/ClinVars4/derivatives/merged_manipulated_2022-09-21.csv'
        outputfile <- 'P:/3024006.02/Data/matlab/ClinVars_select_mri6.csv'
        varlist <- c('pseudonym','TimepointNr','ParticipantType','Age','Gender', 'Up3OfTotal',
                'Up3OfBradySum', 'Up3OfRigiditySum', 'Up3OfAppendicularSum','MonthSinceDiag',
                'Subtype_DiagEx1_DisDurSplit', 'Subtype_DiagEx3_DisDurSplit',
                'DiagParkCertain', 'DiagParkPersist')
        
        df <- read_csv(inputfile)
        df1 <- df %>%
                filter(MriNeuroPsychTask=='Motor') %>%
                select(all_of(varlist))
        
        # Define a list of subjects to exclude based on disease conversion at baseline or follow-up
        exclude.ba_diag <- df1 %>%
                filter(TimepointNr==0, (DiagParkCertain == 'NeitherDisease' | DiagParkCertain == 'DoubtAboutParkinsonism' | DiagParkCertain == 'Parkinsonism')) %>% 
                select(pseudonym)
        exclude.fu_diag <- df1 %>%
                filter(TimepointNr==2, (DiagParkPersist == 2)) %>% 
                select(pseudonym)
        exclude.pseudos <- full_join(exclude.ba_diag, exclude.fu_diag) %>% unique()
        # diag_exclusions <- baseline_exclusion %>% unique()
        df1 <- df1 %>%
                mutate(non_pd_diagnosis_at_ba = if_else(pseudonym %in% exclude.ba_diag$pseudonym, 1, 0),
                        non_pd_diagnosis_at_fu = if_else(pseudonym %in% exclude.fu_diag$pseudonym, 1, 0),
                        non_pd_diagnosis_at_ba_or_fu = if_else(pseudonym %in% exclude.pseudos$pseudonym, 1, 0))
        
        # Use baseline values for covariates
        baseline_covars <- c('Age', 'Gender', 'MonthSinceDiag', 'Subtype_DiagEx1_DisDurSplit', 'Subtype_DiagEx3_DisDurSplit',
                             'non_pd_diagnosis_at_ba', 'non_pd_diagnosis_at_fu', 'non_pd_diagnosis_at_ba_or_fu')
        df1.ba <- df1 %>%
                filter(TimepointNr == 0) %>%
                select(pseudonym, ParticipantType, all_of(baseline_covars)) %>%
                mutate(Subtype_DiagEx1_DisDurSplit = if_else(ParticipantType == 'HC_PIT', '0_Healthy', Subtype_DiagEx1_DisDurSplit),
                       Subtype_DiagEx3_DisDurSplit = if_else(ParticipantType == 'HC_PIT', '0_Healthy', Subtype_DiagEx3_DisDurSplit)) %>%
                mutate(Gender = if_else(Gender == 'Male', 1, 0))
        df1 <- df1 %>%
                select(-c(all_of(baseline_covars), DiagParkCertain, DiagParkPersist)) %>%
                left_join(., df1.ba, by=c('pseudonym','ParticipantType'))
        
        
        write_csv(df1, outputfile)
    
}