clinvars_for_mri <- function(inputfile, outputfile, varlist){
    
    inputfile <- 'P:/3022026.01/pep/ClinVars/derivatives/merged_manipulated_2022-02-08.csv'
    outputfile <- 'P:/3024006.02/Data/matlab/ClinVars_select_mri.csv'
    varlist <- c('pseudonym','TimepointNr','ParticipantType', 'MriNeuroPsychTask','Age','Gender', 'Up3OfTotal', 'Up3OfAppendicularSum','MonthSinceDiag', 'Subtype_DisDurSplit', 'Subtype_Imputed_DisDurSplit')
    
    df <- read_csv(inputfile)
    df1 <- df %>%
        select(all_of(varlist))
    write_csv(df1, outputfile)
    
}