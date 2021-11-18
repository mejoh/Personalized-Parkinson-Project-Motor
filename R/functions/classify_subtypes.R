classify_subtypes <- function(df){
        
        # TO DO:
        # Look into implementing an option for multiple imputation
  
  library(readxl)
  
  df1 <- df %>%
    filter(Timepoint == 'ses-POMVisit1')
  
  # Calculate sums for selected variables
  updrs2 <- c('Updrs2It14', 'Updrs2It15', 'Updrs2It16', 'Updrs2It17', 'Updrs2It18', 'Updrs2It19',
                   'Updrs2It20', 'Updrs2It21', 'Updrs2It22', 'Updrs2It23', 'Updrs2It24', 'Updrs2It25', 'Updrs2It26')
  updrs3 <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle',
                   'Up3OfRigLle', 'Up3OfFiTaNonDev', 'Up3OfFiTaYesDev', 'Up3OfHaMoNonDev', 'Up3OfHaMoYesDev',
                   'Up3OfProSNonDev', 'Up3OfProSYesDev', 'Up3OfToTaNonDev', 'Up3OfToTaYesDev', 'Up3OfLAgiNonDev',
                   'Up3OfLAgiYesDev',  'Up3OfArise', 'Up3OfGait',  'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur',
                   'Up3OfSpont', 'Up3OfPosTNonDev', 'Up3OfPosTYesDev', 'Up3OfKinTreNonDev', 'Up3OfKinTreYesDev',
                   'Up3OfRAmpArmNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpJaw',
                   'Up3OfConstan')
  PIGD <- c('Updrs2It25','Updrs2It26', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos')
  RBDSQ <- c('RemSbdq01', 'RemSbdq02', 'RemSbdq03', 'RemSbdq04', 'RemSbdq05',
                  'RemSbdq06', 'RemSbdq07', 'RemSbdq08', 'RemSbdq09', 'RemSbdq10', 
                  'RemSbdq11', 'RemSbdq12')
  SCOPA_AUT <- c('ScopaAut01', 'ScopaAut02', 'ScopaAut03', 'ScopaAut04', 'ScopaAut05',
                      'ScopaAut06', 'ScopaAut07', 'ScopaAut08', 'ScopaAut09', 'ScopaAut10',
                      'ScopaAut11', 'ScopaAut12', 'ScopaAut13', 'ScopaAut14', 'ScopaAut15',
                      'ScopaAut16', 'ScopaAut17', 'ScopaAut18', 'ScopaAut19', 'ScopaAut20',
                      'ScopaAut21')
  SCOPA_AUT.gender <- c('ScopaAut23', 'ScopaAut24', 'ScopaAut27', 'ScopaAut28')
  
  df1 <- df1 %>%
    plyr::mutate(Updrs2Sum = rowSums(select(., any_of(updrs2)), na.rm = FALSE),
                 Updrs3Sum = rowSums(select(., any_of(updrs3)), na.rm = FALSE),
                 PIGDavg = rowSums(select(., any_of(PIGD)), na.rm = FALSE)/length(PIGD),
                 MotorComposite = (Updrs2Sum + Updrs3Sum + PIGDavg)/3,
                 RBDSQSum = rowSums(select(., any_of(RBDSQ)), na.rm = FALSE) + 1,
                 SCOPA_AUTSum1 = rowSums(select(., any_of(SCOPA_AUT)), na.rm = FALSE) + 1,
                 SCOPA_AUTSum2 = rowSums(select(., any_of(SCOPA_AUT.gender)), na.rm = TRUE) + 1,
                 SCOPA_AUTSum = SCOPA_AUTSum1 + SCOPA_AUTSum2,
                 MOCA_MCI = if_else(NpsMocTotAns >= 26, 0, 1))
  
  # Compute cognitive composite score
    #File 1
  ANDI_scores <- read_excel('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/ANDI_stacked_1-471.xlsx')
  colnames(ANDI_scores)[1:3] <- c('pseudonym', 'FullName', 'Variable')
  ANDI_z_scores <- ANDI_scores %>%
    select(pseudonym, Variable, z) %>%
    pivot_wider(names_from = Variable,
                values_from = z)
  colnames(ANDI_z_scores)[2:6] <- c('AVLT.Total_1to5','AVLT.DelayedRecall_1to5','AVLT.Recognition_1to5','SemanticFluency','Brixton')
    #File 2
  SDMT_Benton_WAIS_scores <- read_csv('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/POM_dataset SDMT and Benton JULO and WAIS-IV LNS z-norms.csv')
  SDMT_Benton_WAIS_z_scores <- SDMT_Benton_WAIS_scores %>%
    select(pseudonym, SDMT_ORAL_90_Z_SCORE, Benton_Z_SCORE, LetterNumSeq_Z_Score_age_and_edu_adjusted)
  colnames(SDMT_Benton_WAIS_z_scores)[2:4] <- c('SymbolDigit', 'Benton', 'LetterNumberSeq')
  
  Neuropsych_z_scores <- full_join(ANDI_z_scores, SDMT_Benton_WAIS_z_scores, by = 'pseudonym') %>% 
    na.omit() %>%
    mutate(AVLT.avg = (AVLT.Total_1to5 + AVLT.DelayedRecall_1to5 + AVLT.Recognition_1to5)/3,
           CognitiveComposite = (SemanticFluency + Brixton + SymbolDigit + Benton + LetterNumberSeq + AVLT.avg) / 6)
  
  # Derive Z-scores
  CutOff <- median(df1$MonthSinceDiag,na.rm = TRUE)
  #CutOff <- mean(df1$MonthSinceDiag,na.rm = TRUE)
  #CutOff <- 12*3
  df1 <- left_join(df1, Neuropsych_z_scores, by = 'pseudonym') %>%
    mutate(DisDurSplit = if_else(MonthSinceDiag >= CutOff,'Above','Below'))
  
  generate_zscores <- function(dat){
    
    dat <- dat %>%
      mutate(Updrs2Sum.z = (Updrs2Sum - mean(dat$Updrs2Sum,na.rm=TRUE))/sd(dat$Updrs2Sum,na.rm=TRUE),
             Updrs2Sum.Perc = pnorm(Updrs2Sum.z)*100,
             Updrs3Sum.z = (Updrs3Sum - mean(dat$Updrs3Sum,na.rm=TRUE))/sd(dat$Updrs3Sum,na.rm=TRUE),
             Updrs3Sum.Perc = pnorm(Updrs3Sum.z)*100,
             PIGD.z = (PIGDavg - mean(dat$PIGDavg,na.rm=TRUE))/sd(dat$PIGDavg,na.rm=TRUE),
             PIGD.Perc = pnorm(PIGD.z)*100,
             MotorComposite.z1 = (MotorComposite - mean(dat$MotorComposite,na.rm=TRUE))/sd(dat$MotorComposite,na.rm=TRUE),
             MotorComposite.Perc1 = pnorm(MotorComposite.z1)*100,
             MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
             MotorComposite.Perc2 = pnorm(MotorComposite.z2)*100,
             RBDSQ.z = (RBDSQSum - mean(dat$RBDSQSum,na.rm=TRUE))/sd(dat$RBDSQSum,na.rm=TRUE),
             RBDSQ.Perc = pnorm(RBDSQ.z)*100,
             SCOPA_AUT.z = (SCOPA_AUTSum - mean(dat$SCOPA_AUTSum,na.rm=TRUE))/sd(dat$SCOPA_AUTSum,na.rm=TRUE),
             SCOPA_AUT.Perc = pnorm(SCOPA_AUT.z)*100,
             MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
             MOCA_MCI.Perc = pnorm(MOCA_MCI.z)*100,
             CognitiveComposite.z = (CognitiveComposite - mean(dat$CognitiveComposite,na.rm=TRUE)) / sd(dat$CognitiveComposite,na.rm=TRUE),
             CognitiveComposite.Perc = pnorm(CognitiveComposite.z)*100)
    
    dat
    
  }
  
  #Below
  df_below <- df1 %>%
    filter(DisDurSplit == 'Below') %>%
    generate_zscores()
  
  #Above
  df_above <- df1 %>%
    filter(DisDurSplit == 'Above') %>%
    generate_zscores()
  
  df_split <- full_join(df_below, df_above) %>%
    mutate(Subtype=NA)
  
  #No split
  df_nosplit <- df1 %>%
    generate_zscores() %>%
    mutate(Subtype=NA)
  
  # Perform classification
  classification <- function(df){
    for(n in 1:length(df$Subtype)){
      if(is.na(df$MotorComposite.z2[n]) | is.na(df$RBDSQ.z[n]) | is.na(df$SCOPA_AUT.z[n]) | is.na(df$CognitiveComposite.z[n])){
        df$Subtype[n] <- 'Undefined'
      }else if((df$MotorComposite.Perc2[n] != 0 | df$RBDSQ.Perc[n] != 0 | df$SCOPA_AUT.Perc[n] != 0 | df$CognitiveComposite.Perc[n] != 100) &
         (df$MotorComposite.z2[n] >= 0.675 & df$RBDSQ.z[n] >= 0.675) |
         (df$MotorComposite.z2[n] >= 0.675 & df$SCOPA_AUT.z[n] >= 0.675) |
         (df$MotorComposite.z2[n] >= 0.675 & df$CognitiveComposite.Perc[n] <= -0.675) |
         (df$SCOPA_AUT.z[n] >= 0.675 & df$RBDSQ.z[n] >= 0.675 & df$CognitiveComposite.Perc[n] <= -0.675)){
        df$Subtype[n] <- 'Diffuse-Malignant'   
      }else if(df$MotorComposite.z2[n] < 0.675 & df$RBDSQ.z[n] < 0.675 & df$SCOPA_AUT.z[n] < 0.675 & df$CognitiveComposite.Perc[n] > -0.675){
        df$Subtype[n] <- 'Mild-Motor'
      }else{
        df$Subtype[n] <- 'Intermediate'
      }
    }
    
    df
    
  }
  df_split <- classification(df_split) %>%
    rename(Subtype_DisDurSplit = Subtype) %>%
    select(pseudonym, Subtype_DisDurSplit)
  df_nosplit <- classification(df_nosplit) %>%
    rename(Subtype_NoSplit = Subtype) %>%
    select(pseudonym, MotorComposite, CognitiveComposite, Subtype_NoSplit)
  df1 <- full_join(df_nosplit,df_split, by='pseudonym')
  df1$Subtype_DisDurSplit[is.na(df1$Subtype_DisDurSplit)] <- 'Undefined'
  df <- left_join(df, df1, by = 'pseudonym') %>%
    mutate(SubtypeMatches = Subtype_DisDurSplit == Subtype_NoSplit)
  
  df
  
}