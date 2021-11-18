relabel_categorical_vals <- function(df){
  
  df$DiagParkCertain <- as.factor(df$DiagParkCertain)             # Certainty of diagnosis
  levels(df$DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
  df$MostAffSide <- as.factor(df$MostAffSide)                     # Most affected side
  levels(df$MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
  df$PrefHand <- as.factor(df$PrefHand)                           # Dominant hand
  levels(df$PrefHand) <- c('Right', 'Left', 'NoPref')
  df$Gender <- as.factor(df$Gender)                               # Gender
  levels(df$Gender) <- c('Male', 'Female')
  df$ParkinMedUser <- as.factor(df$ParkinMedUser)                 # Parkinson's medication use
  levels(df$ParkinMedUser) <- c('No','Yes')
  df$ParticipantType[str_detect(df$Timepoint,'POMVisit*')] <- 3          # Fix the two cases where ParticipantType is undefined
  df$ParticipantType[str_detect(df$Timepoint,'PITVisit2')] <- 2
  df$ParticipantType <- as.factor(df$ParticipantType)
  levels(df$ParticipantType) <- c('PD_PIT','HC_PIT', 'PD_POM')
  
  df
  
}