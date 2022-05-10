clinvars_for_mri <- function(inputfile, outputfile, varlist){
    
        # inputfile <- 'P:/3022026.01/pep/ClinVars2/derivatives/merged_manipulated_2022-04-12_ba-diag.csv'
        inputfile <- 'P:/3022026.01/pep/ClinVars2/derivatives/merged_manipulated_2022-04-08_ba_and_fu_diag.csv'
        outputfile <- 'P:/3024006.02/Data/matlab/ClinVars_select_mri4.csv'
        varlist <- c('pseudonym','TimepointNr','ParticipantType', 'MriNeuroPsychTask','Age','Gender', 'Up3OfTotal',
                'Up3OfAppendicularSum','MonthSinceDiag', 'Subtype_DisDurSplit', 'Subtype_Imputed_DisDurSplit', 
                'Subtype_DisDurSplit.MCI', 'Subtype_Imputed_DisDurSplit.MCI',
                'DiagParkCertain', 'DiagParkPersist')
        
        df <- read_csv(inputfile)
        df1 <- df %>%
                select(all_of(varlist))
        
        # Define a list of subjects to exclude
        exclude.ba_diag <- df1 %>%
                filter(TimepointNr==0, (DiagParkCertain == 'NeitherDisease' | DiagParkCertain == 'DoubtAboutParkinsonism' | DiagParkCertain == 'Parkinsonism')) %>% 
                select(pseudonym)
        exclude.fu_diag <- df1 %>%
                filter(TimepointNr==2, (DiagParkPersist == 2)) %>% 
                select(pseudonym)
        exclude.pseudos <- full_join(exclude.ba_diag, exclude.fu_diag) %>% unique()
        # diag_exclusions <- baseline_exclusion %>% unique()
        df2 <- df1 %>%
                mutate(non_pd_diagnosis_at_ba = if_else(pseudonym %in% exclude.ba_diag$pseudonym, 1, 0),
                        non_pd_diagnosis_at_fu = if_else(pseudonym %in% exclude.fu_diag$pseudonym, 1, 0),
                        non_pd_diagnosis_at_ba_or_fu = if_else(pseudonym %in% exclude.pseudos$pseudonym, 1, 0))
        
        write_csv(df2, outputfile)
    
}