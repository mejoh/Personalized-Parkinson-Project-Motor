# This script gathers all data frame manipulations
# These manipulations are intended to be independent of each other
# so it should be possible to carry them out in any order.

manipulate_castor_csv <- function(datafile='/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_2023-08-11.csv'){

        library(tidyverse)
        library(jsonlite)
        library(lubridate)
        
        ##### Read joined file ####
        df <- read_csv(datafile)
        print(problems(df))
        #####
        
        ##### Replace numeric values with meaningful labels #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/relabel_categorical_vals.R')
        df <- relabel_categorical_vals(df)
        #####
        
        ##### Repair impossible values #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/turn_negative_to_positive.R')
        varlist <- c('MonthSinceDiag', 'WeeksSinceLastVisit', 'Age')
        for(var in varlist){
                turn_negative_to_positive(df, var)
        }
        #####
        
        ##### Determine task #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/determine_mri_task.R')
        df <- determine_mri_task(df, '/project/3022026.01/pep/bids')
        #####
        
        ##### Repair BDI and reverse STAI scores #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/repair_bdiII_values.R')
        df <- repair_bdiII_values(df)
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/reverse_STAI_values.R')
        df <- reverse_STAI_values(df)
        #####
        
        ##### Set values of UPDRS-III items that have 5 to NA. These are items that could not be assessed!! #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/repair_updrs3.R')
        df <- repair_updrs3(df)
        #####
        
        ##### Extend variables #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/extend_variables.R')
        varlist <- c('Gender', 'Age', 'MonthSinceDiag', 'MostAffSide', 'MriNeuroPsychTask', 'MriRespHand') #MostAffSide
        df <- extend_variables(df, varlist)
        #####
        
        ##### Include LEDD if possible (Dependency: motor_LEDD.m) #####
        file <- '/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/LEDD/MedicationTable.csv'
        meds <- read_csv(file)
        df <- left_join(df, meds, by = c('pseudonym','Timepoint'))
        df$LEDD[df$LEDD>8000] <- NA       # Remove unreasonably high values
        #####
        
        ##### Compute summary scores (Dependency: Extend variables) #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_summaryscores.R')
        df <- compute_summaryscores(df)
        #####
        
        ##### Compute cognitive composite score #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_cognitive_composite.R')
        df <- df %>%
                left_join(., compute_cognitive_composite(df))
        #####
        
        ##### Compute progression (deltas and ROCs; Dependency: Compute summary scores) #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/elble_change.R')
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_progression.R')
        # varlist <- c('Up4Dyskinesia', 'Up4Fluct', 'Up4Dystonia', 'Up4Total',
        #              'AsymmetryIndexRiLe.Brady', 'AsymmetryIndexArmLeg.Brady', 'AsymmetryIndexRiLe.Rigidity', 'AsymmetryIndexArmLeg.Rigidity',
        #              'AsymmetryIndexRiLe.RestTrem', 'AsymmetryIndexArmLeg.RestTrem', 'AsymmetryIndexRiLe.ActTrem',
        #              'AsymmetryIndexRiLe.All', 'AsymmetryIndexArmLeg.All', 'AsymmetryIndexRiLeDelta.All', 'AsymmetryIndexArmLegDelta.All',
        #              'AsymmetryIndexRiLe.WeightedBradyRig', 'AsymmetryIndexArmLeg.WeightedBradyRig',
        #              'Up3OfBradyProportion', 'Up3OfRigidityProportion', 'Up3OfPIGDProportion', 'Up3OfRestTremProportion', 'Up3OfActTremProportion', 'Up3OfOtherProportion',
        #              'Up3OfBradyProportion2', 'Up3OfRigidityProportion2', 'Up3OfPIGDProportion2', 'Up3OfRestTremProportion2', 'Up3OfActTremProportion2', 'Up3OfOtherProportion2',
        #              'Up3OfTotal', 'Up3OnTotal', 'Up3OfBradySum', 'Up3OnBradySum', 'Up3OfRigiditySum', 'Up3OnRigiditySum',
        #              'Up3OfAppendicularSum', 'Up3OnAppendicularSum', 'Up3OfPIGDSum', 'Up3OnPIGDSum', 'Up3OfPIGDSum_Up3Only', 'Up3OnPIGDSum_Up3Only', 
        #              'Up3OfAxialSum', 'Up3OnAxialSum', 'Up3OfRestTremAmpSum', 'Up3OnRestTremAmpSum', 'Up3OfActionTremorSum', 'Up3OnActionTremorSum',
        #              'Up3OfCompositeTremorSum', 'Up3OnCompositeTremorSum', 'Up3OfOtherSum', 'Up3OnOtherSum',
        #              'Up3OfTotal.Norm', 'Up3OnTotal.Norm', 'Up3OfBradySum.Norm', 'Up3OnBradySum.Norm', 'Up3OfRigiditySum.Norm', 'Up3OnRigiditySum.Norm',
        #              'Up3OfAppendicularSum.Norm', 'Up3OnAppendicularSum.Norm', 'Up3OfPIGDSum.Norm', 'Up3OnPIGDSum.Norm', 'Up3OfPIGDSum_Up3Only.Norm', 'Up3OnPIGDSum_Up3Only.Norm', 
        #              'Up3OfAxialSum.Norm', 'Up3OfAxialSum.Norm', 'Up3OfRestTremAmpSum.Norm', 'Up3OnRestTremAmpSum.Norm', 'Up3OfActionTremorSum.Norm', 'Up3OnActionTremorSum.Norm',
        #              'Up3OfCompositeTremorSum.Norm', 'Up3OnCompositeTremorSum.Norm', 'Up3OfOtherSum.Norm', 'Up3OnOtherSum.Norm', 'MotorComposite',
        #              'STAIStateSum', 'STAITraitSum', 'QUIPicdSum', 'QUIPrsSum', 'AES12Sum', 'ApatSum', 'BDI2Sum', 'PDQ39_SingleIndex',
        #              'ROMPSum', 'VIPDQ23Sum', 'VIPDQ17Sum', 'Up1Total', 'Up2Total',
        #              'RBDSQSum', 'SCOPA_AUTSum', 'MoCASum',
        #              'NpsMis15wRigTot', 'NpsMis15WrdDelRec', 'NpsMis15WrdRecognition',
        #              'NpsMisBenton', 'NpsMisBrixton', 'NpsMisWaisLcln', 'NpsMisWaisRude', 'NpsMisSemFlu',
        #              'NpsMisModa30', 'NpsMisModa60', 'NpsMisModa90', 'LEDD')
        # varlist <- c('Up4Dyskinesia', 'Up4Fluct', 'Up4Dystonia', 'Up4Total',
        #              'AsymmetryIndexRiLe.Brady', 'AsymmetryIndexArmLeg.Brady', 'AsymmetryIndexRiLe.Rigidity', 'AsymmetryIndexArmLeg.Rigidity',
        #              'AsymmetryIndexRiLe.RestTrem', 'AsymmetryIndexArmLeg.RestTrem', 'AsymmetryIndexRiLe.ActTrem',
        #              'AsymmetryIndexRiLe.All', 'AsymmetryIndexArmLeg.All', 'AsymmetryIndexRiLeDelta.All', 'AsymmetryIndexArmLegDelta.All',
        #              'AsymmetryIndexRiLe.WeightedBradyRig', 'AsymmetryIndexArmLeg.WeightedBradyRig',
        #              'Up3OfBradyProportion', 'Up3OfRigidityProportion', 'Up3OfPIGDProportion', 'Up3OfRestTremProportion', 'Up3OfActTremProportion', 'Up3OfOtherProportion',
        #              'Up3OfBradyProportion2', 'Up3OfRigidityProportion2', 'Up3OfPIGDProportion2', 'Up3OfRestTremProportion2', 'Up3OfActTremProportion2', 'Up3OfOtherProportion2',
        #              'Up3OfTotal', 'Up3OnTotal', 'Up3OfBradySum', 'Up3OnBradySum', 'Up3OfRigiditySum', 'Up3OnRigiditySum',
        #              'Up3OfAppendicularSum', 'Up3OnAppendicularSum', 'Up3OfPIGDSum', 'Up3OnPIGDSum', 'Up3OfPIGDSum_Up3Only', 'Up3OnPIGDSum_Up3Only', 
        #              'Up3OfAxialSum', 'Up3OnAxialSum', 'Up3OfRestTremAmpSum', 'Up3OnRestTremAmpSum', 'Up3OfRestTremAmpSum2', 'Up3OnRestTremAmpSum2',
        #              'Up3OfActionTremorSum', 'Up3OnActionTremorSum',
        #              'Up3OfCompositeTremorSum', 'Up3OnCompositeTremorSum', 'Up3OfOtherSum', 'Up3OnOtherSum', 'MotorComposite',
        #              'STAIStateSum', 'STAITraitSum', 'QUIPicdSum', 'QUIPrsSum', 'AES12Sum', 'ApatSum', 'BDI2Sum', 'PDQ39_SingleIndex',
        #              'ROMPSum', 'VIPDQ23Sum', 'VIPDQ17Sum', 'Up1Total', 'Up2Total',
        #              'RBDSQSum', 'SCOPA_AUTSum', 'MoCASum', 'LEDD')
        # for(var in varlist){
        #         df <- compute_progression(df, var)      
        # }
        #####
        
        ##### Detect patients who participated in both PIT and POM #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/detect_xstudy_participation.R')
        df <- detect_xstudy_participation(df)
        #####
        
        ##### Classify PD patients from POM into subtypes (Feresh et al., 2017) #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/classify_subtypes.R')
        # All timepoints for all subjects are classified relative to baseline z-scores
        df_noimp_relba <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'none', RelativeToBaseline = TRUE)
        # df_imp_relba <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'none', RelativeToBaseline = TRUE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_Imputed_',.x), starts_with('Subtype'))
        
        df_noimp_relba_diagex1 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'ba', RelativeToBaseline = TRUE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx1_',.x), starts_with('Subtype'))
        # df_imp_relba_diagex1 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'ba', RelativeToBaseline = TRUE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_Imputed_DiagEx1_',.x), starts_with('Subtype'))
        
        df_noimp_relba_diagex2 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'fu', RelativeToBaseline = TRUE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx2_',.x), starts_with('Subtype'))
        # df_imp_relba_diagex2 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'fu', RelativeToBaseline = TRUE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_Imputed_DiagEx2_',.x), starts_with('Subtype'))
        
        df_noimp_relba_diagex3 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'both', RelativeToBaseline = TRUE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx3_',.x), starts_with('Subtype'))
        # df_imp_relba_diagex3 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'both', RelativeToBaseline = TRUE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_Imputed_DiagEx3_',.x), starts_with('Subtype'))
        
        # All timepoints for all subjects are classified relative to session-specific z-scores
        df_noimp_relpeers_diagex1 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'ba', RelativeToBaseline = FALSE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx1_RelPeers_',.x), starts_with('Subtype'))
        # df_imp_relpeers_diagex1 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'ba', RelativeToBaseline = FALSE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx1_Imputed_RelPeers_',.x), starts_with('Subtype'))
        
        df_noimp_relpeers_diagex2 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'fu', RelativeToBaseline = FALSE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx2_RelPeers_',.x), starts_with('Subtype'))
        # df_imp_relpeers_diagex2 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'fu', RelativeToBaseline = FALSE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx2_Imputed_RelPeers_',.x), starts_with('Subtype'))
        
        df_noimp_relpeers_diagex3 <- classify_subtypes(df, MI = FALSE, DiagExclusions = 'both', RelativeToBaseline = FALSE) %>%
                select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
                rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx3_RelPeers_',.x), starts_with('Subtype'))
        # df_imp_relpeers_diagex3 <- classify_subtypes(df, MI = TRUE, DiagExclusions = 'both', RelativeToBaseline = FALSE) %>%
        #         select(pseudonym, ParticipantType, TimepointNr, starts_with('Subtype')) %>%
        #         rename_with( ~ gsub('Subtype_', 'Subtype_DiagEx3_Imputed_RelPeers_',.x), starts_with('Subtype'))
        
        df <- full_join(df_noimp_relba, df_noimp_relba_diagex1, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        df <- full_join(df, df_noimp_relba_diagex2, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        df <- full_join(df, df_noimp_relba_diagex3, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        df <- full_join(df, df_noimp_relpeers_diagex1, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        df <- full_join(df, df_noimp_relpeers_diagex2, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        df <- full_join(df, df_noimp_relpeers_diagex3, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        
        # df <- full_join(df, df_imp_relba, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relba_diagex1, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relba_diagex2, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relba_diagex3, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relpeers_diagex1, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relpeers_diagex2, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        # df <- full_join(df, df_imp_relpeers_diagex3, by = c('pseudonym', 'ParticipantType','TimepointNr'))
        #####
        
        ##### Calculate time to follow-up (Dependency: Extend variables) #####
        source('/home/sysneu/marjoh/scripts/Personalized-Parkinson-Project-Motor/R/functions/compute_weekstofollowup.R')
        df <- compute_weekstofollowup(df)
        #####
        
        ##### Convert metrics for convencience #####
        df <- df %>%
                mutate(YearsSinceDiag = MonthSinceDiag / 12,
                       YearsToFollowUp = (WeeksToFollowUp / 4) / 12)
        #####
        
        ##### Write to file #####
        outputname <- paste(dirname(datafile), '/merged_manipulated_', today(), '.csv', sep = '')
        write_csv(df, outputname)
        #####

}

# ##### Check missing timepoint values #####
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit1') %>%
#   select(pseudonym, MonthSinceDiag)
# length(dat$MonthSinceDiag)
# sum(is.na(dat$MonthSinceDiag))
# 
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit2') %>%
#   select(pseudonym, WeeksSinceVisit1)
# length(dat$WeeksSinceVisit1)
# sum(is.na(dat$WeeksSinceVisit1))
# 
# dat <- df %>%
#   filter(Timepoint=='ses-POMVisit3') %>%
#   select(pseudonym, WeeksSinceVisit2)
# length(dat$WeeksSinceVisit2)
# sum(is.na(dat$WeeksSinceVisit2))
# #####
# 
# ##### Check handedness #####
# dat <- df %>%
#   filter(MriNeuroPsychTask == 'Motor') %>%
#   select(pseudonym, Timepoint, MriRespHand, MostAffSide)
# #####