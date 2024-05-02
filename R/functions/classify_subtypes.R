classify_subtypes <- function(df, MI=TRUE, DiagExclusions='both', RelativeToBaseline=TRUE){
        
        library(readxl)
        library(mice)
        library(miceadds)
        
        ##### Select participants #####
        #df1 <- df %>%
        #        filter(Timepoint == 'ses-POMVisit1')
        df1 <- df %>%
                filter(ParticipantType=='PD_POM')
        #####
        
        ###### Calculate sums for variables used in subtype classification #####
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
                             RBDSQSum = rowSums(select(., any_of(RBDSQ)), na.rm = FALSE) + 1,
                             SCOPA_AUTSum1 = rowSums(select(., any_of(SCOPA_AUT)), na.rm = FALSE) + 1,
                             SCOPA_AUTSum2 = rowSums(select(., any_of(SCOPA_AUT.gender)), na.rm = TRUE) + 1,
                             SCOPA_AUTSum = SCOPA_AUTSum1 + SCOPA_AUTSum2)
        #####
        
        ##### Compute cognitive composite score ####
        if(!MI){
                # DEPRECATED!! 
                # Use available normative scores
                #File 1
                # ANDI_scores <- read_excel('/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/ANDI_stacked_1-471.xlsx')
                # colnames(ANDI_scores)[1:3] <- c('pseudonym', 'FullName', 'Variable')
                # ANDI_z_scores <- ANDI_scores %>%
                #         select(pseudonym, Variable, z) %>%
                #         pivot_wider(names_from = Variable,
                #                     values_from = z)
                # colnames(ANDI_z_scores)[2:6] <- c('AVLT.Total_1to5','AVLT.DelayedRecall_1to5','AVLT.Recognition_1to5','SemanticFluency','Brixton')
                # #File 2
                # SDMT_Benton_WAIS_scores <- read_csv('/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/POM_dataset SDMT and Benton JULO and WAIS-IV LNS z-norms.csv')
                # SDMT_Benton_WAIS_z_scores <- SDMT_Benton_WAIS_scores %>%
                #         select(pseudonym, SDMT_ORAL_90_Z_SCORE, Benton_Z_SCORE, LetterNumSeq_Z_Score_age_and_edu_adjusted)
                # colnames(SDMT_Benton_WAIS_z_scores)[2:4] <- c('SymbolDigit', 'Benton', 'LetterNumberSeq')
                # 
                # Neuropsych_z_scores <- full_join(ANDI_z_scores, SDMT_Benton_WAIS_z_scores, by = 'pseudonym') %>% 
                #         na.omit() %>%
                #         mutate(AVLT.avg = (AVLT.Total_1to5 + AVLT.DelayedRecall_1to5 + AVLT.Recognition_1to5)/3,
                #                CognitiveComposite = (SemanticFluency + Brixton + SymbolDigit + Benton + LetterNumberSeq + AVLT.avg) / 6)  
                
                
        }else{
                # DEPRECATED!!!
                # Use available and imputed normative scores
                #File 3
                # NormativeScores <- read_csv('/project/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/NormativeScores.csv')
                # 
                # Neuropsych_z_scores <- NormativeScores %>%
                #         select(pseudonym, AVLT.Total_1to5.imp, AVLT.DelayedRecall_1to5.imp, AVLT.Recognition_1to5.imp,
                #                SemanticFluency.imp, Brixton.imp, SymbolDigit.imp, Benton.imp, LetterNumberSeq.imp) %>%
                #         na.omit() %>%
                #         mutate(AVLT.avg.imp = (AVLT.Total_1to5.imp + AVLT.DelayedRecall_1to5.imp + AVLT.Recognition_1to5.imp)/3,
                #                CognitiveComposite = (SemanticFluency.imp + Brixton.imp + SymbolDigit.imp + 
                #                                              Benton.imp + LetterNumberSeq.imp + AVLT.avg.imp) / 6)   
        }
        
        # Merge datasets
        #df1 <- left_join(df1, Neuropsych_z_scores, by = 'pseudonym')
        
        # df1 <- df1 %>%
        #         select(pseudonym, TimepointNr, MonthSinceDiag, Updrs2Sum, Updrs3Sum, PIGDavg,
        #                RBDSQSum, SCOPA_AUTSum, CognitiveComposite, MoCASum, DiagParkCertain, DiagParkPersist)
        #####
        
        # ##### DEPRECATED!!!! Imputation of missing values through predictive mean matching #####
        # if(MI){
        #         md.pattern(df1)
        #         # Carry out imputation
        #         df1 <- df1 %>%
        #                 mutate(TimepointNr = as.factor(TimepointNr))
        #         imp <- mice(df1, method = 'pmm', m = 1, maxit = 50, seed=157)
        #         df1 <- complete(imp) %>% 
        #                 as_tibble %>%
        #                 mutate(TimepointNr = as.numeric(TimepointNr)-1)
        #         #md.pattern(df1)
        # }
        # #####
        
        ##### Define variables that depended on imputation #####
        df1 <- df1 %>% mutate(CognitiveComposite = z_CognitiveComposite2,
                              MOCA_MCI = if_else(MoCASum >= 26, 0, 1),
                              z_MOCA_MCI = if_else(z_MoCA__total > -1.5, 0 ,1),
                              MotorComposite = (Updrs2Sum + Updrs3Sum + PIGDavg)/3) %>%
                select(-c(MoCASum))
        
        ##### 
        
        ##### Exclude patients with non-PD diagnoses so they don't confound the classification #####
        diagnosis <- df1 %>% select(pseudonym, TimepointNr, DiagParkCertain, DiagParkPersist)
        
        # Define a list of subjects to exclude
        if(DiagExclusions == 'ba'){
                baseline_exclusion <- diagnosis %>%
                        filter(TimepointNr==0, (DiagParkCertain == 'NeitherDisease' | DiagParkCertain == 'DoubtAboutParkinsonism' | DiagParkCertain == 'Parkinsonism')) %>% 
                        select(pseudonym)
                diag_exclusions <- baseline_exclusion %>% unique()
        }else if(DiagExclusions == 'fu'){
                visit2_exclusion <- diagnosis %>%
                        filter(TimepointNr==2, (DiagParkPersist == 2)) %>% 
                        select(pseudonym)
                diag_exclusions <- visit2_exclusion %>% unique()
        }else if(DiagExclusions == 'both'){
                baseline_exclusion <- diagnosis %>%
                        filter(TimepointNr==0, (DiagParkCertain == 'NeitherDisease' | DiagParkCertain == 'DoubtAboutParkinsonism' | DiagParkCertain == 'Parkinsonism')) %>% 
                        select(pseudonym)
                visit2_exclusion <- diagnosis %>%
                        filter(TimepointNr==2, (DiagParkPersist == 2)) %>% 
                        select(pseudonym)
                diag_exclusions <- full_join(baseline_exclusion, visit2_exclusion) %>% unique()
        }else if(DiagExclusions == 'none'){
                diag_exclusions <- diagnosis %>%
                        filter(pseudonym == '') %>%
                        select(pseudonym)
        }
        df1 <- df1 %>%
                filter(!(pseudonym %in% diag_exclusions$pseudonym)) 
        #####
        
        ##### Derive Z-scores (relative to baseline) for whole cohort and for cohort split at disease duration #####
        # Set RelativeToBaseline=FALSE to get z-scores relative to peers (i.e. separate z-scores calculated for each timepoint)
        CutOff <- median(df1$MonthSinceDiag,na.rm = TRUE)
        df1 <- df1 %>% mutate(DisDurCutoff = if_else(MonthSinceDiag >= CutOff,'Above','Below'))
        
        generate_zscores <- function(dat, RelativeToBaseline=TRUE){
                
                if(RelativeToBaseline){
                        dat <- dat %>%
                                mutate(Updrs2Sum.z = (Updrs2Sum - mean(dat$Updrs2Sum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$Updrs2Sum[dat$TimepointNr==0],na.rm=TRUE),
                                       Updrs2Sum.Perc = pnorm(Updrs2Sum.z)*100,
                                       Updrs3Sum.z = (Updrs3Sum - mean(dat$Updrs3Sum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$Updrs3Sum[dat$TimepointNr==0],na.rm=TRUE),
                                       Updrs3Sum.Perc = pnorm(Updrs3Sum.z)*100,
                                       PIGD.z = (PIGDavg - mean(dat$PIGDavg[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$PIGDavg[dat$TimepointNr==0],na.rm=TRUE),
                                       PIGD.Perc = pnorm(PIGD.z)*100,
                                       MotorComposite.z1 = (MotorComposite - mean(dat$MotorComposite[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$MotorComposite[dat$TimepointNr==0],na.rm=TRUE),
                                       MotorComposite.Perc1 = pnorm(MotorComposite.z1)*100,
                                       MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
                                       MotorComposite.Perc2 = pnorm(MotorComposite.z2)*100,
                                       RBDSQ.z = (RBDSQSum - mean(dat$RBDSQSum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$RBDSQSum[dat$TimepointNr==0],na.rm=TRUE),
                                       RBDSQ.Perc = pnorm(RBDSQ.z)*100,
                                       SCOPA_AUT.z = (SCOPA_AUTSum - mean(dat$SCOPA_AUTSum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$SCOPA_AUTSum[dat$TimepointNr==0],na.rm=TRUE),
                                       SCOPA_AUT.Perc = pnorm(SCOPA_AUT.z)*100,
                                       MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
                                       MOCA_MCI.Perc = pnorm(MOCA_MCI.z)*100,
                                       z_MOCA_MCI.z = if_else(z_MOCA_MCI == 1, -0.675, 1),
                                       z_MOCA_MCI.Perc = pnorm(z_MOCA_MCI.z)*100,
                                       CognitiveComposite.z = (CognitiveComposite - mean(dat$CognitiveComposite[dat$TimepointNr==0],na.rm=TRUE)) / sd(dat$CognitiveComposite[dat$TimepointNr==0],na.rm=TRUE),
                                       CognitiveComposite.Perc = pnorm(CognitiveComposite.z)*100)
                        
                        dat
                }else{
                        dat <- dat %>%
                                mutate(Updrs2Sum.z = case_when(TimepointNr==0 ~ (Updrs2Sum - mean(dat$Updrs2Sum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$Updrs2Sum[dat$TimepointNr==0],na.rm=TRUE),
                                                               TimepointNr==1 ~ (Updrs2Sum - mean(dat$Updrs2Sum[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$Updrs2Sum[dat$TimepointNr==1],na.rm=TRUE),
                                                               TimepointNr==2 ~ (Updrs2Sum - mean(dat$Updrs2Sum[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$Updrs2Sum[dat$TimepointNr==2],na.rm=TRUE)),
                                       Updrs2Sum.Perc = pnorm(Updrs2Sum.z)*100,
                                       Updrs3Sum.z = case_when(TimepointNr==0 ~ (Updrs3Sum - mean(dat$Updrs3Sum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$Updrs3Sum[dat$TimepointNr==0],na.rm=TRUE),
                                                               TimepointNr==1 ~ (Updrs3Sum - mean(dat$Updrs3Sum[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$Updrs3Sum[dat$TimepointNr==1],na.rm=TRUE),
                                                               TimepointNr==2 ~ (Updrs3Sum - mean(dat$Updrs3Sum[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$Updrs3Sum[dat$TimepointNr==2],na.rm=TRUE)),
                                       Updrs3Sum.Perc = pnorm(Updrs3Sum.z)*100,
                                       PIGD.z = case_when(TimepointNr==0 ~ (PIGDavg - mean(dat$PIGDavg[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$PIGDavg[dat$TimepointNr==0],na.rm=TRUE),
                                                          TimepointNr==1 ~ (PIGDavg - mean(dat$PIGDavg[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$PIGDavg[dat$TimepointNr==1],na.rm=TRUE),
                                                          TimepointNr==2 ~ (PIGDavg - mean(dat$PIGDavg[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$PIGDavg[dat$TimepointNr==2],na.rm=TRUE)),
                                       PIGD.Perc = pnorm(PIGD.z)*100,
                                       MotorComposite.z1 = case_when(TimepointNr==0 ~ (MotorComposite - mean(dat$MotorComposite[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$MotorComposite[dat$TimepointNr==0],na.rm=TRUE),
                                                                     TimepointNr==1 ~ (MotorComposite - mean(dat$MotorComposite[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$MotorComposite[dat$TimepointNr==1],na.rm=TRUE),
                                                                     TimepointNr==2 ~ (MotorComposite - mean(dat$MotorComposite[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$MotorComposite[dat$TimepointNr==2],na.rm=TRUE)),
                                       MotorComposite.Perc1 = pnorm(MotorComposite.z1)*100,
                                       MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
                                       MotorComposite.Perc2 = pnorm(MotorComposite.z2)*100,
                                       RBDSQ.z = case_when(TimepointNr==0 ~ (RBDSQSum - mean(dat$RBDSQSum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$RBDSQSum[dat$TimepointNr==0],na.rm=TRUE),
                                                           TimepointNr==1 ~ (RBDSQSum - mean(dat$RBDSQSum[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$RBDSQSum[dat$TimepointNr==1],na.rm=TRUE),
                                                           TimepointNr==2 ~ (RBDSQSum - mean(dat$RBDSQSum[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$RBDSQSum[dat$TimepointNr==2],na.rm=TRUE)),
                                       RBDSQ.Perc = pnorm(RBDSQ.z)*100,
                                       SCOPA_AUT.z = case_when(TimepointNr==0 ~ (SCOPA_AUTSum - mean(dat$SCOPA_AUTSum[dat$TimepointNr==0],na.rm=TRUE))/sd(dat$SCOPA_AUTSum[dat$TimepointNr==0],na.rm=TRUE),
                                                               TimepointNr==1 ~ (SCOPA_AUTSum - mean(dat$SCOPA_AUTSum[dat$TimepointNr==1],na.rm=TRUE))/sd(dat$SCOPA_AUTSum[dat$TimepointNr==1],na.rm=TRUE),
                                                               TimepointNr==2 ~ (SCOPA_AUTSum - mean(dat$SCOPA_AUTSum[dat$TimepointNr==2],na.rm=TRUE))/sd(dat$SCOPA_AUTSum[dat$TimepointNr==2],na.rm=TRUE)),
                                       SCOPA_AUT.Perc = pnorm(SCOPA_AUT.z)*100,
                                       MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
                                       MOCA_MCI.Perc = pnorm(MOCA_MCI.z)*100,
                                       z_MOCA_MCI.z = if_else(z_MOCA_MCI == 1, -0.675, 1),
                                       z_MOCA_MCI.Perc = pnorm(z_MOCA_MCI.z)*100,
                                       CognitiveComposite.z = case_when(TimepointNr==0 ~ (CognitiveComposite - mean(dat$CognitiveComposite[dat$TimepointNr==0],na.rm=TRUE)) / sd(dat$CognitiveComposite[dat$TimepointNr==0],na.rm=TRUE),
                                                                        TimepointNr==1 ~ (CognitiveComposite - mean(dat$CognitiveComposite[dat$TimepointNr==1],na.rm=TRUE)) / sd(dat$CognitiveComposite[dat$TimepointNr==1],na.rm=TRUE),
                                                                        TimepointNr==2 ~ (CognitiveComposite - mean(dat$CognitiveComposite[dat$TimepointNr==2],na.rm=TRUE)) / sd(dat$CognitiveComposite[dat$TimepointNr==2],na.rm=TRUE)),
                                       CognitiveComposite.Perc = pnorm(CognitiveComposite.z)*100)
                        dat
                }
        }
                
        
        #Below
        df_below <- df1 %>%
                filter(DisDurCutoff == 'Below') %>%
                generate_zscores(., RelativeToBaseline = RelativeToBaseline)
        
        #Above
        df_above <- df1 %>%
                filter(DisDurCutoff == 'Above') %>%
                generate_zscores(., RelativeToBaseline = RelativeToBaseline)
        
        df_split <- full_join(df_below, df_above) %>%
                mutate(Subtype=NA,
                       Subtype.MCI=NA,
                       Subtype.MCI_z=NA)
        
        #No split
        df_nosplit <- df1 %>%
                generate_zscores(., RelativeToBaseline = RelativeToBaseline) %>%
                mutate(Subtype=NA,
                       Subtype.MCI=NA,
                       Subtype.MCI_z=NA)
        #####
        
        ##### Perform classification #####
        classification <- function(df){
                
                for(n in 1:length(df$Subtype)){
                        if(is.na(df$MotorComposite.Perc2[n]) | is.na(df$RBDSQ.Perc[n]) | is.na(df$SCOPA_AUT.Perc[n]) | is.na(df$CognitiveComposite.Perc[n])){
                                df$Subtype[n] <- '4_Undefined'
                        }else if((df$MotorComposite.Perc2[n] != 0 | df$RBDSQ.Perc[n] != 0 | df$SCOPA_AUT.Perc[n] != 0 | df$CognitiveComposite.Perc[n] != 100) &
                                 (df$MotorComposite.Perc2[n] >= 75 & df$RBDSQ.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$SCOPA_AUT.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$CognitiveComposite.Perc[n] <= 25) |
                                 (df$SCOPA_AUT.Perc[n] >= 75 & df$RBDSQ.Perc[n] >= 75 & df$CognitiveComposite.Perc[n] <= 25)){
                                df$Subtype[n] <- '3_Diffuse-Malignant'   
                        }else if(df$MotorComposite.Perc2[n] < 75 & df$RBDSQ.Perc[n] < 75 & df$SCOPA_AUT.Perc[n] < 75 & df$CognitiveComposite.Perc[n] > 25){
                                df$Subtype[n] <- '1_Mild-Motor'
                        }else{
                                df$Subtype[n] <- '2_Intermediate'
                        }
                }
                
                for(n in 1:length(df$Subtype.MCI)){
                        if(is.na(df$MotorComposite.Perc2[n]) | is.na(df$RBDSQ.Perc[n]) | is.na(df$SCOPA_AUT.Perc[n]) | is.na(df$MOCA_MCI.Perc[n])){
                                df$Subtype.MCI[n] <- '4_Undefined'
                        }else if((df$MotorComposite.Perc2[n] != 0 | df$RBDSQ.Perc[n] != 0 | df$SCOPA_AUT.Perc[n] != 0 | df$MOCA_MCI.Perc[n] != 100) &
                                 (df$MotorComposite.Perc2[n] >= 75 & df$RBDSQ.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$SCOPA_AUT.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$MOCA_MCI.Perc[n] <= 25) |
                                 (df$SCOPA_AUT.Perc[n] >= 75 & df$RBDSQ.Perc[n] >= 75 & df$MOCA_MCI.Perc[n] <= 25)){
                                df$Subtype.MCI[n] <- '3_Diffuse-Malignant'   
                        }else if(df$MotorComposite.Perc2[n] < 75 & df$RBDSQ.Perc[n] < 75 & df$SCOPA_AUT.Perc[n] < 75 & df$MOCA_MCI.Perc[n] > 25){
                                df$Subtype.MCI[n] <- '1_Mild-Motor'
                        }else{
                                df$Subtype.MCI[n] <- '2_Intermediate'
                        }
                }
                
                for(n in 1:length(df$Subtype.MCI_z)){
                        if(is.na(df$MotorComposite.Perc2[n]) | is.na(df$RBDSQ.Perc[n]) | is.na(df$SCOPA_AUT.Perc[n]) | is.na(df$z_MOCA_MCI.Perc[n])){
                                df$Subtype.MCI_z[n] <- '4_Undefined'
                        }else if((df$MotorComposite.Perc2[n] != 0 | df$RBDSQ.Perc[n] != 0 | df$SCOPA_AUT.Perc[n] != 0 | df$z_MOCA_MCI.Perc[n] != 100) &
                                 (df$MotorComposite.Perc2[n] >= 75 & df$RBDSQ.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$SCOPA_AUT.Perc[n] >= 75) |
                                 (df$MotorComposite.Perc2[n] >= 75 & df$z_MOCA_MCI.Perc[n] <= 25) |
                                 (df$SCOPA_AUT.Perc[n] >= 75 & df$RBDSQ.Perc[n] >= 75 & df$z_MOCA_MCI.Perc[n] <= 25)){
                                df$Subtype.MCI_z[n] <- '3_Diffuse-Malignant'   
                        }else if(df$MotorComposite.Perc2[n] < 75 & df$RBDSQ.Perc[n] < 75 & df$SCOPA_AUT.Perc[n] < 75 & df$z_MOCA_MCI.Perc[n] > 25){
                                df$Subtype.MCI_z[n] <- '1_Mild-Motor'
                        }else{
                                df$Subtype.MCI_z[n] <- '2_Intermediate'
                        }
                }
                
                
                
                df
                
        }
        
        # Separate classification above and below threshold
        df_split <- classification(df_split) %>%
                rename(Subtype_DisDurSplit = Subtype) %>%
                rename(Subtype_DisDurSplit.MCI = Subtype.MCI) %>%
                rename(Subtype_DisDurSplit.MCI_z = Subtype.MCI_z) %>%
                select(pseudonym, TimepointNr, DisDurCutoff, Subtype_DisDurSplit, Subtype_DisDurSplit.MCI, Subtype_DisDurSplit.MCI_z)
        
        # Classification for entire cohort
        df_nosplit <- classification(df_nosplit) %>%
                rename(Subtype_NoSplit = Subtype) %>%
                rename(Subtype_NoSplit.MCI = Subtype.MCI) %>%
                rename(Subtype_NoSplit.MCI_z = Subtype.MCI_z) %>%
                select(pseudonym, TimepointNr, CognitiveComposite, Subtype_NoSplit, Subtype_NoSplit.MCI, Subtype_NoSplit.MCI_z)
        
        df1 <- full_join(df_nosplit, df_split, by = c('pseudonym', 'TimepointNr'))
        # df1 %>% select(pseudonym, TimepointNr, DisDurCutoff, starts_with('Subtype_'))
        
        df1$Subtype_NoSplit[is.na(df1$Subtype_NoSplit)] <- '4_Undefined'
        df1$Subtype_NoSplit.MCI[is.na(df1$Subtype_NoSplit.MCI)] <- '4_Undefined'
        df1$Subtype_NoSplit.MCI_z[is.na(df1$Subtype_NoSplit.MCI_z)] <- '4_Undefined'
        df1$Subtype_DisDurSplit[is.na(df1$Subtype_DisDurSplit)] <- '4_Undefined'
        df1$Subtype_DisDurSplit.MCI[is.na(df1$Subtype_DisDurSplit.MCI)] <- '4_Undefined'
        df1$Subtype_DisDurSplit.MCI_z[is.na(df1$Subtype_DisDurSplit.MCI_z)] <- '4_Undefined'
        
        df <- left_join(df, df1, by = c('pseudonym', 'TimepointNr')) %>%
                mutate(Subtype_Matches = Subtype_DisDurSplit == Subtype_NoSplit,
                       Subtype_Matches.MCI = Subtype_DisDurSplit.MCI == Subtype_NoSplit.MCI)
        #####
        
        df
        
}


# # Deprecated: Perform classification
# classification <- function(df){
#         for(n in 1:length(df$Subtype)){
#                 if(is.na(df$MotorComposite.z2[n]) | is.na(df$RBDSQ.z[n]) | is.na(df$SCOPA_AUT.z[n]) | is.na(df$CognitiveComposite.z[n])){
#                         df$Subtype[n] <- 'Undefined'
#                 }else if((df$MotorComposite.Perc2[n] != 0 | df$RBDSQ.Perc[n] != 0 | df$SCOPA_AUT.Perc[n] != 0 | df$CognitiveComposite.Perc[n] != 100) &
#                          (df$MotorComposite.z2[n] >= 0.675 & df$RBDSQ.z[n] >= 0.675) |
#                          (df$MotorComposite.z2[n] >= 0.675 & df$SCOPA_AUT.z[n] >= 0.675) |
#                          (df$MotorComposite.z2[n] >= 0.675 & df$CognitiveComposite.Perc[n] <= -0.675) |
#                          (df$SCOPA_AUT.z[n] >= 0.675 & df$RBDSQ.z[n] >= 0.675 & df$CognitiveComposite.Perc[n] <= -0.675)){
#                         df$Subtype[n] <- 'Diffuse-Malignant'
#                 }else if(df$MotorComposite.z2[n] < 0.675 & df$RBDSQ.z[n] < 0.675 & df$SCOPA_AUT.z[n] < 0.675 & df$CognitiveComposite.Perc[n] > -0.675){
#                         df$Subtype[n] <- 'Mild-Motor'
#                 }else{
#                         df$Subtype[n] <- 'Intermediate'
#                 }
#         }
#         
#         df
#         
# }