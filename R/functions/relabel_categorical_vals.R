relabel_categorical_vals <- function(df){
        
  df1 <- df
  
  df1$DiagParkCertain <- as.factor(df1$DiagParkCertain)             # Certainty of diagnosis
  levels(df1$DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
  df1$MostAffSide <- as.factor(df1$MostAffSide)                     # Most affected side
  levels(df1$MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
  df1$PrefHand <- as.factor(df1$PrefHand)                           # Dominant hand
  levels(df1$PrefHand) <- c('Right', 'Left', 'NoPref')
  df1$Gender <- as.factor(df1$Gender)                               # Gender
  levels(df1$Gender) <- c('Male', 'Female')
  df1$ParkinMedUser <- as.factor(df1$ParkinMedUser)                 # Parkinson's medication use
  levels(df1$ParkinMedUser) <- c('No','Yes')
  df1$ParticipantType[str_detect(df1$Timepoint,'PITVisit1') & is.na(df1$ParticipantType)] <- 1  # One PIT participant with undefined type
  df1$ParticipantType[str_detect(df1$Timepoint,'POMVisit*')] <- 3          # Fix the two cases where ParticipantType is undefined
  df1$ParticipantType[str_detect(df1$Timepoint,'PITVisit2')] <- 2
  df1$ParticipantType <- as.factor(df1$ParticipantType)
  levels(df1$ParticipantType) <- c('PD_PIT','HC_PIT', 'PD_POM')
  df1$WatchSide <- as.factor(df1$WatchSide)
  levels(df1$WatchSide) <- c('R','L')
  
  df1
  
}