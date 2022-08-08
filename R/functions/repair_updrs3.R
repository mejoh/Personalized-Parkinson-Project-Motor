# UPDRS-3 scores range from 0-4
# Some items are scored 5. These are labelled 'Niet beordelbaar' in the dictionary
# Scores of 5 should therefore be turned into NAs

repair_updrs3 <- function(df){
  
  df1 <- df
  
  # Lists of items to fix
  list.TotalOff <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                     'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                     'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                     'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont', 'Up3OfPosTYesDev',
                     'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev',
                     'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan')
  list.TotalOn <- str_replace(list.TotalOff, 'Of','On')
  
  list.OffnOn <- c(list.TotalOff,list.TotalOn)
  AffectedPsuedos <- c()
  for(v in list.OffnOn){
    # Find items with score = 5
    idx <- df1[,v] == 5 & !is.na(df1[,v])
    if(sum(idx,na.rm=TRUE)>0){
      cat('Score > 4 found for variable ', v, ', n = ', sum(idx,na.rm=TRUE), ', setting to NA\n',sep='')
      cat(df1$pseudonym[idx], '\n')
      cat(df1$Timepoint[idx], '\n')
      AffectedPsuedos <- c(AffectedPsuedos, df1$pseudonym[idx])
      df1[idx,v] = NA
    }
  }
  cat('Total number of unique affected participants: ', length(unique(AffectedPsuedos)),'\n', sep='')
  print(unique(AffectedPsuedos))
  
  df1
  
}


