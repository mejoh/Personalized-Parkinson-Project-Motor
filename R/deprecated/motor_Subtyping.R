## OPTIONS
# Subet by motor task, subset by no task
# Z-score: From Fereshtehnejad, from our own cohort, or from our own cohort slipt above and below 3 years EstDisDurYears
# Motor composite z-score calculation 1 or 2

source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
library(tidyverse)
library(lubridate)
library(readxl)
        # Clinical vars
fDat <- 'P:/3022026.01/pep/ClinVars/derivatives/database_clinical_variables_2021-04-06.csv'
df.clin.pom <- read_csv(fDat)
df <- df.clin.pom %>%
        filter(Timepoint == 'ses-POMVisit1')
        # Age- and education-adjusted cognitive vars
ANDI_scores <- read_excel('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/ANDI_stacked_1-471.xlsx')
SDMT_Benton_WAIS_scores <- read_csv('P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/POM_dataset SDMT and Benton JULO and WAIS-IV LNS z-norms.csv')

##### Generate data frame #####
# UDPRS II
vars.updrs2 <- c('Updrs2It14', 'Updrs2It15', 'Updrs2It16', 'Updrs2It17', 'Updrs2It18', 'Updrs2It19',
                 'Updrs2It20', 'Updrs2It21', 'Updrs2It22', 'Updrs2It23', 'Updrs2It24', 'Updrs2It25', 'Updrs2It26')
df.updrs2 <- df %>%
        select(pseudonym, EstDisDurYears, Age, Gender, MriNeuroPsychTask,
               any_of(vars.updrs2)) %>%
        mutate(Updrs2Sum = rowSums(select(., any_of(vars.updrs2)), na.rm = FALSE)) %>%
        select(-c(any_of(vars.updrs2)))

# UPDRS III
vars.updrs3 <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle',
                 'Up3OfRigLle', 'Up3OfFiTaNonDev', 'Up3OfFiTaYesDev', 'Up3OfHaMoNonDev', 'Up3OfHaMoYesDev',
                 'Up3OfProSNonDev', 'Up3OfProSYesDev', 'Up3OfToTaNonDev', 'Up3OfToTaYesDev', 'Up3OfLAgiNonDev',
                 'Up3OfLAgiYesDev',  'Up3OfArise', 'Up3OfGait',  'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur',
                 'Up3OfSpont', 'Up3OfPosTNonDev', 'Up3OfPosTYesDev', 'Up3OfKinTreNonDev', 'Up3OfKinTreYesDev',
                 'Up3OfRAmpArmNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpJaw',
                 'Up3OfConstan')
df.updrs3 <- df %>%
        select(pseudonym, any_of(vars.updrs3)) %>%
        mutate(Updrs3Sum = rowSums(select(., any_of(vars.updrs3)), na.rm = FALSE)) %>%
        select(-c(any_of(vars.updrs3)))

# PIGD
vars.PIGD <- c('Updrs2It25','Updrs2It26', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos')
df.PIGD <- df %>%
        select(pseudonym, any_of(vars.PIGD)) %>%
        mutate(PIGDavg = rowSums(select(., any_of(vars.PIGD)), na.rm = FALSE)/length(vars.PIGD)) %>%
        select(-c(any_of(vars.PIGD)))

# RBDSQ
vars.RBDSQ <- c('RemSbdq01', 'RemSbdq02', 'RemSbdq03', 'RemSbdq04', 'RemSbdq05',
                'RemSbdq06', 'RemSbdq07', 'RemSbdq08', 'RemSbdq09', 'RemSbdq10', 
                'RemSbdq11', 'RemSbdq12')
df.RBDSQ <- df %>%
        select(pseudonym, any_of(vars.RBDSQ)) %>%
        mutate(RBDSQSum = rowSums(select(., any_of(vars.RBDSQ)), na.rm = FALSE) + 1) %>%
        select(-c(any_of(vars.RBDSQ)))

# SCOPA
vars.SCOPA_AUT <- c('ScopaAut01', 'ScopaAut02', 'ScopaAut03', 'ScopaAut04', 'ScopaAut05',
                    'ScopaAut06', 'ScopaAut07', 'ScopaAut08', 'ScopaAut09', 'ScopaAut10',
                    'ScopaAut11', 'ScopaAut12', 'ScopaAut13', 'ScopaAut14', 'ScopaAut15',
                    'ScopaAut16', 'ScopaAut17', 'ScopaAut18', 'ScopaAut19', 'ScopaAut20',
                    'ScopaAut21')
df.SCOPA_AUT <- df %>%
        select(pseudonym, any_of(vars.SCOPA_AUT)) %>%
        mutate(SCOPA_AUTSum1 = rowSums(select(., any_of(vars.SCOPA_AUT)), na.rm = FALSE) + 1) %>%
        select(-c(any_of(vars.SCOPA_AUT)))

vars.SCOPA_AUT.gender <- c('ScopaAut23', 'ScopaAut24', 'ScopaAut27', 'ScopaAut28')
df.SCOPA_AUT.gender <- df %>%
        select(pseudonym, Gender, any_of(vars.SCOPA_AUT.gender)) %>%
        mutate(SCOPA_AUTSum2 = rowSums(select(., any_of(vars.SCOPA_AUT.gender)), na.rm = TRUE) + 1) %>%
        select(-c(Gender, any_of(vars.SCOPA_AUT.gender)))

df.SCOPA_AUT <- full_join(df.SCOPA_AUT, df.SCOPA_AUT.gender, by = 'pseudonym') %>%
        mutate(SCOPA_AUTSum = SCOPA_AUTSum1 + SCOPA_AUTSum2) %>%
        select(-c(SCOPA_AUTSum1, SCOPA_AUTSum2))

# MOCA_MCI
df.MOCA_MCI <- df %>%
        select(pseudonym, NpsMocTotAns) %>%
        mutate(MOCA_MCI = if_else(NpsMocTotAns >= 26, 0, 1))

# Cognitive composite score
# Compute the mean from 6 z-scored cognitive tests:
# mean AVLT, Semantic Fluency, Brixton, Symbol digit, Benton, Letter number sequencing
        # Prepare cognitive scores
        #File 1: AVLT, SemanticFluency, Brixton
colnames(ANDI_scores)[1] <- 'pseudonym'
colnames(ANDI_scores)[2] <- 'FullName'
colnames(ANDI_scores)[3] <- 'Variable'
table(ANDI_scores$Variable)
ANDI_z_scores <- ANDI_scores %>%
        select(pseudonym, Variable, z) %>%
        pivot_wider(names_from = Variable,
                    values_from = z)
colnames(ANDI_z_scores)[2] <- 'AVLT.Total_1to5'
colnames(ANDI_z_scores)[3] <- 'AVLT.DelayedRecall_1to5'
colnames(ANDI_z_scores)[4] <- 'AVLT.Recognition_1to5'
colnames(ANDI_z_scores)[5] <- 'SemanticFluency'
colnames(ANDI_z_scores)[6] <- 'Brixton'
        #File 2: Symbol digit, Benton, Letter Number sequence
SDMT_Benton_WAIS_z_scores <- SDMT_Benton_WAIS_scores %>%
        select(pseudonym, SDMT_ORAL_90_Z_SCORE, Benton_Z_SCORE, LetterNumSeq_Z_Score_age_and_edu_adjusted)
colnames(SDMT_Benton_WAIS_z_scores)[2] <- 'SymbolDigit'
colnames(SDMT_Benton_WAIS_z_scores)[3] <- 'Benton'
colnames(SDMT_Benton_WAIS_z_scores)[4] <- 'LetterNumberSeq'

Neuropsych_z_scores <- full_join(ANDI_z_scores, SDMT_Benton_WAIS_z_scores, by = 'pseudonym')
Neuropsych_z_scores <- tibble(Neuropsych_z_scores[complete.cases(Neuropsych_z_scores), ])
Neuropsych_z_scores <- Neuropsych_z_scores %>%
        mutate(AVLT.avg = (AVLT.Total_1to5 + AVLT.DelayedRecall_1to5 + AVLT.Recognition_1to5)/3) %>%
        mutate(CognitiveComposite = (SemanticFluency + Brixton + SymbolDigit + Benton + LetterNumberSeq + AVLT.avg) / 6)

df.CognitiveComposite <- Neuropsych_z_scores %>%
        select(pseudonym, CognitiveComposite)

# Assemble scores
df.ScoreSums <- cbind(df.updrs2, 
                      Updrs3Sum = df.updrs3$Updrs3Sum, 
                      PIGDavg = df.PIGD$PIGDavg, 
                      MotorComposite = (df.updrs2$Updrs2Sum + df.updrs3$Updrs3Sum + df.PIGD$PIGDavg)/3,
                      RBDSQSum = df.RBDSQ$RBDSQSum, 
                      SCOPA_AUTSum = df.SCOPA_AUT$SCOPA_AUTSum, 
                      MOCA_MCI = df.MOCA_MCI$MOCA_MCI)
df.ScoreSums <- left_join(df.ScoreSums, df.CognitiveComposite, by = 'pseudonym')
df.ScoreSums <- tibble(df.ScoreSums[complete.cases(df.ScoreSums), ])
#####

##### Calculate z-scores and percentiles #####

# Z-scores from Fereshtehnejad et al., 2017
        # Calculate z-scores
df.ScoreSums_z_feresh <- df.ScoreSums %>%
        mutate(Updrs2.z = (Updrs2Sum - 5.96)/4.23,
               Updrs3.z = (Updrs3Sum - 21.02)/9.049,
               PIGD.z = (PIGDavg - 0.2281)/0.226778,
               MotorComposite.z = (Updrs2.z + Updrs3.z + PIGD.z)/3,
               RBDSQ.z = (RBDSQSum - 3.56)/2.787,
               SCOPA_AUT.z = (SCOPA_AUTSum - 9.61)/6.199,
               MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1))

        # Calculate percentiles
df.ScoreSums_z_feresh2 <- bind_cols(df.ScoreSums_z_feresh, 
                                MotorComposite.Perc = pnorm(df.ScoreSums_z_feresh$MotorComposite.z)*100,
                                RBDSQ.Perc = pnorm(df.ScoreSums_z_feresh$RBDSQ.z)*100,
                                SCOPA_AUT.Perc = pnorm(df.ScoreSums_z_feresh$SCOPA_AUT.z)*100,
                                MOCA_MCI.Perc = pnorm(df.ScoreSums_z_feresh$MOCA_MCI.z)*100)

# Z-scores derived from whole cohort
        # Note: There's at least 2 ways to calculate the z-score for MotorComposite
        # 1. Form z-score for MotorComposite by dividing its own average with its own standard deviation (same treatment as all other variables)
        # 2. Approach from paper: Take the mean of the average z-scores for Updrs2, Updrs3, and PIGD (different treatment than other variables)

        # Calculate z-scores
df.ScoreSums_z_cohort <- df.ScoreSums %>%
        mutate(Updrs2Sum.z = (Updrs2Sum - mean(Updrs2Sum))/sd(Updrs2Sum),
               Updrs3Sum.z = (Updrs3Sum - mean(Updrs3Sum))/sd(Updrs3Sum),
               PIGD.z = (PIGDavg - mean(PIGDavg))/sd(PIGDavg),
               MotorComposite.z1 = (MotorComposite - mean(MotorComposite))/sd(MotorComposite),
               MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
               RBDSQ.z = (RBDSQSum - mean(RBDSQSum))/sd(RBDSQSum),
               SCOPA_AUT.z = (SCOPA_AUTSum - mean(SCOPA_AUTSum))/sd(SCOPA_AUTSum),
               MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
               CognitiveComposite.z = (CognitiveComposite - mean(CognitiveComposite)) / sd(CognitiveComposite))

        # Calculate percentiles
df.ScoreSums_z_cohort2 <- bind_cols(df.ScoreSums_z_cohort, 
                               MotorComposite.Perc1 = pnorm(df.ScoreSums_z_cohort$MotorComposite.z1)*100,
                               MotorComposite.Perc2 = pnorm(df.ScoreSums_z_cohort$MotorComposite.z2)*100,
                               RBDSQ.Perc = pnorm(df.ScoreSums_z_cohort$RBDSQ.z)*100,
                               SCOPA_AUT.Perc = pnorm(df.ScoreSums_z_cohort$SCOPA_AUT.z)*100,
                               MOCA_MCI.Perc = pnorm(df.ScoreSums_z_cohort$MOCA_MCI.z)*100,
                               CognitiveComposite.Perc = pnorm(df.ScoreSums_z_cohort$CognitiveComposite.z)*100)

# Z-scores derived from cohort, split at above or below 3 years disease duration
df.ScoreSums_DisDurSplit <- df.ScoreSums %>%
        mutate(Above3 = if_else(EstDisDurYears >= 3, 1,0))
df.ScoreSums_DisDurSplit %>% select(Above3) %>% table

df.ScoreSums_DisDurSplit_Above3 <- df.ScoreSums_DisDurSplit %>%
        filter(Above3 == 1)
df.ScoreSums_DisDurSplit_Above3_z_cohort <- df.ScoreSums_DisDurSplit_Above3 %>%
        mutate(Updrs2Sum.z = (Updrs2Sum - mean(Updrs2Sum))/sd(Updrs2Sum),
               Updrs3Sum.z = (Updrs3Sum - mean(Updrs3Sum))/sd(Updrs3Sum),
               PIGD.z = (PIGDavg - mean(PIGDavg))/sd(PIGDavg),
               MotorComposite.z1 = (MotorComposite - mean(MotorComposite))/sd(MotorComposite),
               MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
               RBDSQ.z = (RBDSQSum - mean(RBDSQSum))/sd(RBDSQSum),
               SCOPA_AUT.z = (SCOPA_AUTSum - mean(SCOPA_AUTSum))/sd(SCOPA_AUTSum),
               MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
               CognitiveComposite.z = (CognitiveComposite - mean(CognitiveComposite)) / sd(CognitiveComposite))
df.ScoreSums_DisDurSplit_Above3_z_cohort2 <- bind_cols(df.ScoreSums_DisDurSplit_Above3_z_cohort, 
                                    MotorComposite.Perc1 = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$MotorComposite.z1)*100,
                                    MotorComposite.Perc2 = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$MotorComposite.z2)*100,
                                    RBDSQ.Perc = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$RBDSQ.z)*100,
                                    SCOPA_AUT.Perc = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$SCOPA_AUT.z)*100,
                                    MOCA_MCI.Perc = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$MOCA_MCI.z)*100,
                                    CognitiveComposite.Perc = pnorm(df.ScoreSums_DisDurSplit_Above3_z_cohort$CognitiveComposite.z)*100)


df.ScoreSums_DisDurSplit_Below3  <- df.ScoreSums_DisDurSplit %>%
        filter(Above3 == 0)
df.ScoreSums_DisDurSplit_Below3_z_cohort <- df.ScoreSums_DisDurSplit_Below3 %>%
        mutate(Updrs2Sum.z = (Updrs2Sum - mean(Updrs2Sum))/sd(Updrs2Sum),
               Updrs3Sum.z = (Updrs3Sum - mean(Updrs3Sum))/sd(Updrs3Sum),
               PIGD.z = (PIGDavg - mean(PIGDavg))/sd(PIGDavg),
               MotorComposite.z1 = (MotorComposite - mean(MotorComposite))/sd(MotorComposite),
               MotorComposite.z2 = (Updrs2Sum.z + Updrs3Sum.z + PIGD.z)/3,
               RBDSQ.z = (RBDSQSum - mean(RBDSQSum))/sd(RBDSQSum),
               SCOPA_AUT.z = (SCOPA_AUTSum - mean(SCOPA_AUTSum))/sd(SCOPA_AUTSum),
               MOCA_MCI.z = if_else(MOCA_MCI == 1, -0.675, 1),
               CognitiveComposite.z = (CognitiveComposite - mean(CognitiveComposite)) / sd(CognitiveComposite))
df.ScoreSums_DisDurSplit_Below3_z_cohort2 <- bind_cols(df.ScoreSums_DisDurSplit_Below3_z_cohort, 
                                                       MotorComposite.Perc1 = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$MotorComposite.z1)*100,
                                                       MotorComposite.Perc2 = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$MotorComposite.z2)*100,
                                                       RBDSQ.Perc = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$RBDSQ.z)*100,
                                                       SCOPA_AUT.Perc = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$SCOPA_AUT.z)*100,
                                                       MOCA_MCI.Perc = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$MOCA_MCI.z)*100,
                                                       CognitiveComposite.Perc = pnorm(df.ScoreSums_DisDurSplit_Below3_z_cohort$CognitiveComposite.z)*100)

df.ScoreSums_DisDurSplit_z_cohort <- bind_rows(df.ScoreSums_DisDurSplit_Below3_z_cohort2, df.ScoreSums_DisDurSplit_Above3_z_cohort2)

#####

##### Subtype #####

        # Decide which scores to use
df.Subtyping <- df.ScoreSums_DisDurSplit_z_cohort[complete.cases(df.ScoreSums_DisDurSplit_z_cohort), ]
#df.Subtyping <- df.ScoreSums_z_feresh2
        # Decide which variable to use for MCI
df.Subtyping <- df.Subtyping %>%
        mutate(MCI_Var.z = CognitiveComposite.z,
               MCI_Var.Perc = CognitiveComposite.Perc,
               Subtype = NA)
        # Perform subtyping
for(n in 1:length(df.Subtyping$Subtype)){
        if((df.Subtyping$MotorComposite.Perc2[n] != 0 | df.Subtyping$RBDSQ.Perc[n] != 0 | df.Subtyping$SCOPA_AUT.Perc[n] != 0 | df.Subtyping$MCI_Var.Perc[n] != 100) &
           (df.Subtyping$MotorComposite.z2[n] >= 0.675 & df.Subtyping$RBDSQ.z[n] >= 0.675) |
           (df.Subtyping$MotorComposite.z2[n] >= 0.675 & df.Subtyping$SCOPA_AUT.z[n] >= 0.675) |
           (df.Subtyping$MotorComposite.z2[n] >= 0.675 & df.Subtyping$MCI_Var.z[n] <= -0.675) |
           (df.Subtyping$SCOPA_AUT.z[n] >= 0.675 & df.Subtyping$RBDSQ.z[n] >= 0.675 & df.Subtyping$MCI_Var.z[n] <= -0.675)){
                df.Subtyping$Subtype[n] <- 'Diffuse-Malignant'   
        }else if(is.na(df.Subtyping$MotorComposite.z2[n]) | is.na(df.Subtyping$RBDSQ.z[n]) | is.na(df.Subtyping$SCOPA_AUT.z[n]) | is.na(df.Subtyping$MCI_Var.z[n])){
                df.Subtyping$Subtype[n] <- 'Undefined'
        } else if(df.Subtyping$MotorComposite.z2[n] < 0.675 & df.Subtyping$RBDSQ.z[n] < 0.675 & df.Subtyping$SCOPA_AUT.z[n] < 0.675 & df.Subtyping$MCI_Var.z[n] > -0.675){
                df.Subtyping$Subtype[n] <- 'Mild-Motor'
        } else {
                df.Subtyping$Subtype[n] <- 'Intermediate'
        }
}

table(df.Subtyping$Subtype)
table(df.Subtyping$Above3)

#df.Subtyping <- df.Subtyping %>%
#        filter(MriNeuroPsychTask == 'Motor')

#####

##### Descriptives #####

table(df.Subtyping$Subtype)

df.Subtyping %>%
        group_by(Subtype) %>%
        summarise(N = n(),
                  avg_MotorComposite = mean(MotorComposite), sd_MotorComposite = sd(MotorComposite),
                  avg_RBDSQ = mean(RBDSQSum), sd_RBDSQ = sd(RBDSQSum),
                  avg_SCOPA_AUT = mean(SCOPA_AUTSum), sd_SCOPA_AUT = sd(SCOPA_AUTSum),
                  avg_CognitiveComposite = mean(CognitiveComposite), sd_CognitiveComposite = sd(CognitiveComposite))

#df.Subtyping %>%
#        ggplot(., aes(y = Updrs2Sum, color = Subtype)) +
#        geom_boxplot()
#df.Subtyping %>%
#        ggplot(., aes(y = Updrs3Sum, color = Subtype)) +
#        geom_boxplot()
#df.Subtyping %>%
#        ggplot(., aes(y = PIGDavg, color = Subtype)) +
#        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(y = MotorComposite, color = Subtype)) +
        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(y = RBDSQSum, color = Subtype)) +
        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(y = SCOPA_AUTSum, color = Subtype)) +
        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(y = CognitiveComposite, color = Subtype)) +
        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(x = MOCA_MCI, fill = Subtype)) +
        geom_bar()
df.Subtyping %>%
        ggplot(., aes(x = Gender, fill = Subtype)) +
        geom_bar()
df.Subtyping %>%
        ggplot(., aes(x = Age)) +
        geom_density()
df.Subtyping %>%
        ggplot(., aes(y = Age, color = Subtype)) +
        geom_boxplot()
df.Subtyping %>%
        ggplot(., aes(x = EstDisDurYears)) +
        geom_density()
df.Subtyping %>%
        ggplot(., aes(y = EstDisDurYears, color = Subtype)) +
        geom_boxplot()

        #k-Means
df2_kmeans <- df.Subtyping %>%
        select(MotorComposite, RBDSQSum, RBDSQSum, SCOPA_AUTSum, CognitiveComposite, Age, Gender, EstDisDurYears) %>%
        mutate(Gender = if_else(Gender == 'Female',1,0))
kmeansObj <- kmeans(df2_kmeans, centers = 3)
pairs(df2_kmeans, col = kmeansObj$cluster, pch = 19, cex = 1)
points(kmeansObj$centers, col = 1:3, pch = 3, cex = 3, lwd = 3)

df.Subtyping <- bind_cols(df.Subtyping, kcluster = kmeansObj$cluster)
df.Subtyping %>%
        group_by(Subtype, kcluster) %>%
        summarise(N = n())
df.Subtyping %>%
        ggplot(aes(Subtype, kcluster)) + 
        geom_jitter()

#####

##### Write to file #####

df.Subtyping_only <- df.Subtyping %>%
        select(pseudonym, Subtype)
OutputName <- paste('P:/3022026.01/pep/ClinVars/derivatives/Subtypes_', today(), '.csv', sep='')
write_csv(df.Subtyping_only, OutputName)

#####
        
        
