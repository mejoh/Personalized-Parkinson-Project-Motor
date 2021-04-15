generate_PIT_castor_csv <- function(bidsdir){
        
        library(tidyverse)
        library(jsonlite)
        library(stringr)
        library(lubridate)
        library(assertthat)
        
        bidsdir <- 'P:/3022026.01/pep/ClinVars/'
        
        # Define a list of subjects
        Subjects <- basename(list.dirs(bidsdir, recursive = FALSE)) 
        Subjects <- Subjects[str_starts(Subjects, 'sub-')]
        
        #subject <- 'sub-POMU00366691DE130349'
        #visit <- 'ses-PITVisit1'
        
        # Import function
        ImportCastorJson <- function(subject, visit){
                
                
                # Find subject's files and subset by pattern
                # Visits and home questionnaires are collapsed (i.e. treated as one time point)
                dSub <- paste(bidsdir, subject, sep='')
                fAllFiles <- dir(dSub, full.names = TRUE, recursive = TRUE)
                fSubsetFiles <- fAllFiles[grep(visit, fAllFiles)]
                if(visit=='ses-PITVisit1'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-PITHomeQuestionnaires1', fAllFiles)])
                }
                if(visit=='ses-PITVisit2'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-PITHomeQuestionnaires2', fAllFiles)])
                }
                
                # Initialize data frame, insert pseudonym
                Data <- tibble(pseudonym = basename(dSub))
                
                # Parse subsetted json files and bind to data frame
                for(i in 1:length(fSubsetFiles)){
                        json <- jsonlite::read_json(fSubsetFiles[i])
                        Data <- bind_cols(Data[1,], as_tibble(json$crf)[1,])    # < Indexing to remove rows, gets rid of list answers!!!
                }
                
                # Return subject's data frame
                Data
        }
        
        ##### Initialize data frame #####
        # Search for all variable names
        VarNames <- c()
        for(n in Subjects){
                dSubDir <- paste(bidsdir, n, sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses-PITVisit')]
                for(t in Visits){
                        dat <- ImportCastorJson(n, t)
                        nam <- names(dat)
                        VarNames <- c(VarNames, nam)
                        VarNames <- unique(VarNames)
                }
        }
        # Initialize the final data frame and name variables
        # Count number of visits
        VisitCounter <- 0
        for(n in Subjects){
                dSubDir <- paste(bidsdir, n, sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses-PITVisit')]
                for(t in Visits){
                        VisitCounter = VisitCounter + 1
                }
        }
        df <- tibble('1' = rep('NA', VisitCounter))            # < NAs need to be chars for now so that the code below can work
        # Add temporary variable names
        for(i in 1:(length(VarNames) - 1)){
                df <- bind_cols(df, tibble(varname = rep('NA', VisitCounter)))
        }
        # Add final variable names
        colnames(df) <- VarNames
        # Add timepoint variable
        df <- bind_cols(df, tibble(Timepoint = rep('NA', VisitCounter)))
        #####
        
        ##### Import data #####
        # Import subject data variable by variable
        RowID <- 1
        for(n in 1:length(Subjects)){
                dSubDir <- paste(bidsdir, Subjects[n], sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses-PITVisit')]
                for(t in Visits){
                        dat <- ImportCastorJson(Subjects[n], t)
                        SubVarNames <- colnames(dat)
                        for(i in 1:length(SubVarNames)){
                                colidx <- str_which(VarNames, SubVarNames[i])
                                df[RowID,colidx] <- unlist(dat[i])  # < Some variables are lists, like dat[77], these will be incorrectly imported!!! 
                        }
                        df$Timepoint[RowID] <- t
                        RowID = RowID + 1
                }
        }
        #####
        
        # Turn uninformative characters to NA
        df[df=='NA'] <- NA    # Not filled in?
        df[df=='?'] <- NA     # Not available for certain subjects (castor dependencies?)
        df[df==''] <- NA      # Not filled in?
        df[df=='##USER_MISSING_95##'] <- NA
        df[df=='##USER_MISSING_96##'] <- NA
        df[df=='##USER_MISSING_97##'] <- NA
        df[df=='##USER_MISSING_98##'] <- NA
        df[df=='##USER_MISSING_99##'] <- NA
        
        df1 <- df
        
        # FIX: BDI2 variables 16, 18, and 21 need to be altered. 
        # 16/18 take on values 0-6 when they should take on values 0-3
        # 21 takes on values 1-4 when it should take on values 0-3
        msg <- 'Fixing BDI2 variables Bdi2It16, Bdi2It18, and Bdi2It21...'
        print(msg)
        df1 <- df %>%
                mutate(Bdi2It16 = as.numeric(Bdi2It16),
                       Bdi2It18 = as.numeric(Bdi2It18),
                       Bdi2It21 = as.numeric(Bdi2It21))
        for(v in 1:length(df1$Bdi2It16)){
                if(is.na(df1$Bdi2It16[v])){
                        next
                }else if(df1$Bdi2It16[v] == 1 | df1$Bdi2It16[v] == 2){
                        df1$Bdi2It16[v] = 1
                }else if(df1$Bdi2It16[v] == 3 | df1$Bdi2It16[v] == 4){
                        df1$Bdi2It16[v] = 2
                }else if(df1$Bdi2It16[v] == 5 | df1$Bdi2It16[v] == 6){
                        df1$Bdi2It16[v] = 3
                }
        }
        for(v in 1:length(df1$Bdi2It18)){
                if(is.na(df1$Bdi2It16[v])){
                }else if(df1$Bdi2It18[v] == 1 | df1$Bdi2It18[v] == 2){
                        df1$Bdi2It18[v] = 1
                }else if(df1$Bdi2It18[v] == 3 | df1$Bdi2It18[v] == 4){
                        df1$Bdi2It18[v] = 2
                }else if(df1$Bdi2It18[v] == 5 | df1$Bdi2It18[v] == 6){
                        df1$Bdi2It18[v] = 3
                }
        }
        for(v in 1:length(df1$Bdi2It21)){
                if(!is.na(df1$Bdi2It21[v])){
                        df1$Bdi2It21[v] <- df1$Bdi2It21[v]-1
                }
        }
        
        reverse_variable_values <- function(var, valrange){
                
                var <- as.numeric(var)
                opposite <- max(valrange):min(valrange)
                
                for(n in 1:length(var)){
                        if(is.na(var[n])){
                                next
                        }
                        for(v in 1:length(valrange)){
                                if(sum(var[n] == valrange) > 0 & var[n] == valrange[v]){
                                        var[n] <- opposite[v]
                                        break
                                }else if(sum(var[n] == valrange) == 0){
                                        msg <- 'Value not found in range, set to NA'
                                        print(msg)
                                        var[n] <- NA
                                }
                        }
                }
                
                return(var)
                
        }
        
        # FIX: STAI state variables Stai11, 12, 15, 18, 111, 115, 116, 119, 120 needs to be reversed
        msg <- 'Reversing scoring for Stai state variables Stai01, 02, 05, 08, 11, 15, 16, 19, 20...'
        print(msg)
        valrange <- 1:4
        df1$StaiState01 <- reverse_variable_values(df1$StaiState01, valrange)
        df1$StaiState02 <- reverse_variable_values(df1$StaiState02, valrange)
        df1$StaiState05 <- reverse_variable_values(df1$StaiState05, valrange)
        df1$StaiState08 <- reverse_variable_values(df1$StaiState08, valrange)
        df1$StaiState11 <- reverse_variable_values(df1$StaiState11, valrange)
        df1$StaiState15 <- reverse_variable_values(df1$StaiState15, valrange)
        df1$StaiState16 <- reverse_variable_values(df1$StaiState16, valrange)
        df1$StaiState19 <- reverse_variable_values(df1$StaiState19, valrange)
        df1$StaiState20 <- reverse_variable_values(df1$StaiState20, valrange)
        
        # FIX: STAI trait variables Stai21, 23, 26, 27, 210, 213, 214, 215, 216, 219 needs to be reversed
        msg <- 'Reversing scoring for Stai state variables Stai01, 03, 06, 07, 10, 13, 14, 15, 16, 19...'
        print(msg)
        valrange <- 1:4
        df1$StaiTrait01 <- reverse_variable_values(df1$StaiTrait01, valrange)
        df1$StaiTrait03 <- reverse_variable_values(df1$StaiTrait03, valrange)
        df1$StaiTrait06 <- reverse_variable_values(df1$StaiTrait06, valrange)
        df1$StaiTrait07 <- reverse_variable_values(df1$StaiTrait07, valrange)
        df1$StaiTrait10 <- reverse_variable_values(df1$StaiTrait10, valrange)
        df1$StaiTrait13 <- reverse_variable_values(df1$StaiTrait13, valrange)
        df1$StaiTrait14 <- reverse_variable_values(df1$StaiTrait14, valrange)
        df1$StaiTrait15 <- reverse_variable_values(df1$StaiTrait15, valrange)
        df1$StaiTrait16 <- reverse_variable_values(df1$StaiTrait16, valrange)
        df1$StaiTrait19 <- reverse_variable_values(df1$StaiTrait19, valrange)
        
        ##### Preprocessing #####
        
        # Sort data frame
        df2 <- df1 %>%
                arrange(pseudonym, Timepoint) %>%
                relocate(pseudonym, Timepoint)
        
        # Define years to follow-up
        df2 <- df2 %>%
                mutate(TimeToFUYears = 0)
        for(n in 1:nrow(df2)){
                if(df2$Timepoint[n] == 'ses-PITVisit2' && df2$Timepoint[n-1] == 'ses-PITVisit1' && df2$pseudonym[n] == df2$pseudonym[n-1]){
                        df2$TimeToFUYears[n] <- 2
                }
        }
        
        # Lists of subscores
        list.TotalOff <- c('Up3OfSpeech_1', 'Up3OfFacial_1', 'Up3OfRigNec_1', 'Up3OfRigRue_1', 'Up3OfRigLue_1', 'Up3OfRigRle_1',
                           'Up3OfRigLle_1', 'Up3OfFiTaR_1', 'Up3OfFiTaL_2', 'Up3OfHaMoR_1', 'Up3OfHaMoL_2', 'Up3OfProS_1',
                           'Up3OfProSL_2', 'Up3OfToTaR_1', 'Up3OfToTaL_2', 'Up3OfLAgiR_1', 'Up3OfLAgiL_2',
                           'Up3OfArise_1', 'Up3OfGait_1', 'Up3OfFreez_1', 'Up3OfStaPos_1', 'Up3OfPostur_1', 'Up3OfSpont_1',
                           'Up3OfPosTR_1', 'Up3OfPosTL_2', 'Up3OfKinTreR_1', 'Up3OfKinTreL_2', 'Up3OfRAmpArmR_1', 'Up3OfRAmpArmL_2',
                           'Up3OfRAmpLegR_1', 'Up3OfRAmpLegL_2', 'Up3OfRAmpJaw_1', 'Up3OfConstan_1')
        list.BradykinesiaOff <- c('Up3OfFiTaR_1', 'Up3OfFiTaL_2', 'Up3OfHaMoR_1', 'Up3OfHaMoL_2', 'Up3OfProS_1',
                                  'Up3OfProSL_2', 'Up3OfToTaR_1', 'Up3OfToTaL_2', 'Up3OfLAgiR_1', 'Up3OfLAgiL_2',
                                  'Up3OfArise_1', 'Up3OfSpont_1')
        list.RestTremorOff <- c('Up3OfRAmpArmR_1', 'Up3OfRAmpArmL_2', 'Up3OfRAmpLegR_1', 'Up3OfRAmpLegL_2', 'Up3OfConstan_1')
        list.RigidityOff <- c('Up3OfRigNec_1', 'Up3OfRigRue_1', 'Up3OfRigLue_1', 'Up3OfRigRle_1', 'Up3OfRigLle_1')
        list.PIGDOff <- c('Up3OfGait_1', 'Up3OfFreez_1', 'Up3OfStaPos_1')
        list.ActionTremorOff <- c('Up3OfPosTR_1', 'Up3OfPosTL_2', 'Up3OfKinTreR_1', 'Up3OfKinTreL_2')
        list.CompositeTremorOff <- c('Up3OfRAmpArmR_1', 'Up3OfRAmpArmL_2', 'Up3OfRAmpLegR_1', 'Up3OfRAmpLegL_2', 'Up3OfConstan_1',
                                     'Up3OfPosTR_1', 'Up3OfPosTL_2', 'Up3OfKinTreR_1', 'Up3OfKinTreL_2')
        list.STAITrait <- c('StaiTrait01', 'StaiTrait02', 'StaiTrait03', 'StaiTrait04', 'StaiTrait05', 'StaiTrait06', 'StaiTrait07',
                            'StaiTrait08', 'StaiTrait09', 'StaiTrait10', 'StaiTrait11', 'StaiTrait12', 'StaiTrait13', 'StaiTrait14',
                            'StaiTrait15', 'StaiTrait16', 'StaiTrait17', 'StaiTrait18', 'StaiTrait19', 'StaiTrait20')
        list.STAIState <- c('StaiState01', 'StaiState02', 'StaiState03', 'StaiState04', 'StaiState05', 'StaiState06', 'StaiState07',
                            'StaiState08', 'StaiState09', 'StaiState10', 'StaiState11', 'StaiState12', 'StaiState13', 'StaiState14',
                            'StaiState15', 'StaiState16', 'StaiState17', 'StaiState18', 'StaiState19', 'StaiState20')
        list.QUIP_gambling <- c('QuipIt01', 'QuipIt08', 'QuipIt15', 'QuipIt22')
        list.QUIP_sex <- c('QuipIt02', 'QuipIt09', 'QuipIt16', 'QuipIt23')
        list.QUIP_buying <- c('test', 'QuipIt10', 'QuipIt17', 'QuipIt24')
        list.QUIP_eating <- c('QuipIt03', 'QuipIt05', 'QuipIt18', 'QuipIt25')
        list.QUIP_hobbypund <- c('QuipIt04', 'QuipIt12', 'QuipIt19', 'QuipIt26', 'QuipIt05', 'QuipIt13', 'QuipIt20', 'QuipIt27')
        list.QUIP_icd <- c(list.QUIP_gambling, list.QUIP_sex, list.QUIP_buying, list.QUIP_eating)
        list.QUIP_rs <- c(list.QUIP_icd, list.QUIP_hobbypund)
        list.Apat <- c('Apat01','Apat02','Apat03','Apat04','Apat05','Apat06','Apat07','Apat08','Apat09','Apat10','Apat11','Apat12',
                       'Apat13','Apat14')
        list.BDI2 <- c('Bdi2It01', 'Bdi2It02', 'Bdi2It03', 'Bdi2It04', 'Bdi2It05', 'Bdi2It06', 'Bdi2It07', 'Bdi2It08', 'Bdi2It09',  'Bdi2It10',
                       'Bdi2It11', 'Bdi2It12', 'Bdi2It13', 'Bdi2It14', 'Bdi2It15', 'Bdi2It16', 'Bdi2It17', 'Bdi2It18', 'Bdi2It19', 'Bdi2It20', 'Bdi2It21')
        
        # Variable selection / construction
        VariableSelectionConstruction <- function(dataframe){
                
                # Variable selection and definition of subscores
                dataframe <- dataframe %>%
                        select(pseudonym,
                               Age_1,
                               Age_2,
                               Gender_1,
                               Gender_2,
                               Timepoint,
                               TimeToFUYears,
                               MostAffSide_1,
                               PrefHand_1,
                               PrefHand_2,
                               hand_motor_1,
                               hand_motor_2,
                               MedUse_1,
                               starts_with('Up3Of'),
                               starts_with('Up3On'),
                               starts_with('Up1a'),
                               starts_with('Updrs2'),
                               starts_with('NpsMocTotAns'),
                               starts_with('NpsEducYears'),
                               starts_with('Quip'),
                               starts_with('test'),
                               starts_with('Apat'),
                               starts_with('Bdi2'),
                               starts_with('Stai'),) %>%
                        mutate(across(-c('pseudonym', 'Timepoint', 'MedUse_1'), as.numeric)) %>% 
                        mutate(Up3OfTotal = rowSums(.[list.TotalOff])) %>%
                        mutate(Up3OfBradySum = rowSums(.[list.BradykinesiaOff])) %>%
                        mutate(Up3OfRestTremAmpSum = rowSums(.[list.RestTremorOff])) %>%
                        mutate(Up3OfRigiditySum = rowSums(.[list.RigidityOff])) %>%
                        mutate(Up3OfPIGDSum = rowSums(.[list.PIGDOff])) %>%
                        mutate(Up3OfActionTremorSum = rowSums(.[list.ActionTremorOff])) %>%
                        mutate(Up3OfCompositeTremorSum = rowSums(.[list.CompositeTremorOff])) %>%
                        mutate(STAITraitSum = rowSums(.[list.STAITrait]),
                               STAIStateSum = rowSums(.[list.STAIState]),
                               QUIPicdSum = rowSums(.[list.QUIP_icd]),
                               QUIPrsSum = rowSums(.[list.QUIP_rs]),
                               APATSum = rowSums(.[list.Apat]),
                               BDI2Sum = rowSums(.[list.BDI2])) %>%
                        unite('Age', c('Age_1','Age_2'), na.rm = TRUE, remove = TRUE) %>%
                        unite('Gender', c('Gender_1','Gender_2'), na.rm = TRUE, remove = TRUE) %>%
                        unite('PrefHand', c('PrefHand_1','PrefHand_2'), na.rm = TRUE, remove = TRUE) %>%
                        unite('RespHand', c('hand_motor_1','hand_motor_2'), na.rm = TRUE, remove = TRUE) %>%
                        unite('NpsMocTotAns', c('NpsMocTotAns_1','NpsMocTotAns_2'), na.rm = TRUE, remove = TRUE) %>%
                        unite('NpsEducYears', c('NpsEducYears_1','NpsEducYears_2'), na.rm = TRUE, remove = TRUE)
                
                for(n in 1:length(dataframe$NpsMocTotAns)){
                        if (dataframe$NpsMocTotAns[n] == 1){
                                dataframe$NpsMocTotAns[n] <- NA  
                        }
                }
                
                return(dataframe)
                
        }
        df3 <- VariableSelectionConstruction(df2)
        df3[df3==''] <- NA      # Not filled in?
        
        # Extend time-invariant variables to all levels of 'Timepoint'
        varlist <- c('Gender', 'Age')
        ExtendVars <- function(dataframe, varlist){
                
                # Iterate over variables in the input list
                for(var in varlist){    
                        
                        # Iterate over pseudonyms
                        for(id in unique(dataframe$pseudonym)){
                                
                                # Subset data based on current pseudonym and current variable
                                vals <- dataframe %>%
                                        filter(pseudonym == id) %>%
                                        select(matches(var))
                                
                                # Perform the same subsetting as above and look for NAs
                                na.idx <- dataframe %>%
                                        filter(pseudonym == id) %>%
                                        select(matches(var)) %>%
                                        is.na %>%
                                        as.vector
                                
                                # Skip ids with no real values
                                if(length(na.idx) == sum(na.idx)) next
                                
                                # Define index for non-NA values
                                val.idx <- !na.idx
                                
                                # Find the value that is not NA
                                non.na.val <- vals[val.idx,]
                                
                                # Replace NAs with real values
                                vals[na.idx,] <- non.na.val
                                
                                #Find column and row index in data frame where values should be replaced
                                col.idx <- colnames(dataframe) == var
                                row.idx <- dataframe$pseudonym == id
                                
                                # Perform replacement
                                dataframe[row.idx, col.idx] <- vals
                                
                        }
                }
                
                return(dataframe)
                
        }
        df4 <- ExtendVars(df3,varlist)
        
        # Transformations
        TransformVariables <- function(dataframe){
                dataframe$Up3OfHoeYah_1 <- as.factor(dataframe$Up3OfHoeYah_1)                     # Hoen & Yahr stage
                dataframe$MostAffSide_1 <- as.factor(dataframe$MostAffSide_1)                     # Most affected side
                levels(dataframe$MostAffSide_1) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
                dataframe$PrefHand <- as.factor(dataframe$PrefHand)                           # Dominant hand
                levels(dataframe$PrefHand) <- c('Right', 'Left', 'NoPref')
                dataframe$PrefHand <- as.factor(dataframe$PrefHand)                           # Dominant hand
                levels(dataframe$PrefHand) <- c('Right', 'Left', 'NoPref')
                dataframe$Gender <- as.factor(dataframe$Gender)                               # Gender
                levels(dataframe$Gender) <- c('Male', 'Female')
                dataframe$Timepoint <- as.factor(dataframe$Timepoint)                         # Timepoint
                return(dataframe)
        }
        df5 <- TransformVariables(df4)
        
        # Calculate disease progression (Year2 - Year1) and indicate which participants have FU data
        CalculateDiseaseProgression <- function(dataframe){
                
                elble.change <- function(T1, T2, subscore.length, alpha=0.5, percent=TRUE){
                        if(!is.na(T1) & !is.na(T2)){
                                
                                T1 <- T1/subscore.length
                                T2 <- T2/subscore.length
                                diff <- T2-T1
                                
                                FC <- 10 ^ (alpha * diff) - 1
                                PC <- 100 * FC
                                
                                if(percent==TRUE){
                                        return(PC)
                                }else if(percent==FALSE){
                                        return(FC)
                                }
                        }else{
                                return(NA)
                        }
                }
                
                dataframe <- dataframe %>%
                        mutate(MultipleSessions = 0)
                
                alpha <- 0.5
                for(n in 1:nrow(dataframe)){
                        if(dataframe$Timepoint[n] == 'ses-PITVisit2' && dataframe$Timepoint[n-1] == 'ses-PITVisit1'){
                                
                                #$Up3OfTotal.1YearDelta[(n-1):n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]
                                dataframe$MultipleSessions[(n-1):n] = 1
                                
                       }
                }
                dataframe$MultipleSessions <- as.factor(dataframe$MultipleSessions)
                levels(dataframe$MultipleSessions) <- c('No','Yes')
                return(dataframe)
                
        }
        df6 <- CalculateDiseaseProgression(df5)
        
        # Missing values
        Check1 <- function(dataframe){
                x <- apply(dataframe, 2, is.na) %>% colSums
                msg <- c('Reporting missing values per variable...')
                print(msg)
                print(x)
        }
        Check1(df6)
        
        ##### Write to csv #####
        
        outputfile <- paste(bidsdir, 'derivatives/database_PIT_clinical_variables_', today(),  '.csv', sep = '')
        if(!dir.exists(dirname(outputfile))){
                dir.create(dirname(outputfile))
        }
        if(file.exists(outputfile)){
                file.remove(outputfile)
        }
        write_csv(df6, outputfile)
        
        ##### 
        
}