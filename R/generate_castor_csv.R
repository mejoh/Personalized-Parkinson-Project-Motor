# This script generates a single csv file that summarizes the clinical variables
# of all subjects in the specified bids-directory
# The output file is in person-period format

generate_castor_csv <- function(bidsdir){
        
        library(tidyverse)
        library(jsonlite)
        library(stringr)
        library(lubridate)
        
        # Define a list of subjects
        Subjects <- basename(list.dirs(bidsdir, recursive = FALSE)) 
        Subjects <- Subjects[str_starts(Subjects, 'sub-')]
        # Count number of visits
        VisitCounter <- 0
        for(n in Subjects){
                dSubDir <- paste(bidsdir, n, sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses-Visit')]
                for(t in Visits){
                        VisitCounter = VisitCounter + 1
                }
        }
        
        # Import a row of data for a specified subject and visit
        # Finds json files, parses them, and binds variables horizontally
        # NOTE: Visit and Home questionnaires are collapsed to a single row
        ImportCastorJson <- function(subject, visit){
                
                
                
                # Find subject's files and subset by pattern
                # Visits and home questionnaires are collapsed (i.e. treated as one time point)
                dSub <- paste(bidsdir, subject, '/', sep='')
                fAllFiles <- dir(dSub, full.names = TRUE, recursive = TRUE)
                fSubsetFiles <- fAllFiles[grep(visit, fAllFiles)]
                if(visit=='ses-Visit1'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-HomeQuestionnaires1', fAllFiles)])
                }
                if(visit=='ses-Visit2'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-HomeQuestionnaires2', fAllFiles)])
                }
                if(visit=='ses-Visit3'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-HomeQuestionnaires3', fAllFiles)])
                }
                
                # FIX: Removal of duplication and naming errors
                if(visit=='ses-Visit1' || visit=='ses-Visit2' || visit=='ses-Visit3'){
                        ExcludedFiles <- c('Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_1',
                                           'Castor.Visit1.Motorische_taken_OFF.Updrs3_deel_2')#,
                        #'Castor.Visit1.Motorische_taken_ON.Updrs3_deel_3')   # < Not sure about this last one... only incorrect for some
                        for(i in 1:length(ExcludedFiles)){
                                idx <- grep(ExcludedFiles[i], fSubsetFiles)
                                if(not_empty(idx)){
                                        fSubsetFiles <- fSubsetFiles[-c(idx)]
                                }
                        }
                }
                
                # Initialize data frame, insert pseudonym
                Data <- tibble(pseudonym = basename(dSub))
                
                # Parse subsetted json files and bind to data frame
                for(i in 1:length(fSubsetFiles)){
                        json <- jsonlite::read_json(fSubsetFiles[i])
                        # FIX: Rename vars where Of and On labels have been accidentally reversed
                        if(str_detect(fSubsetFiles[i], 'Motorische_taken_ON') && str_detect(names(json$crf), 'Up3Of')){
                                print(dSub)
                                msg <- 'Up3Of variable found in On assessment, replacing with Up3On...'
                                print(msg)
                                names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
                        }else if(str_detect(fSubsetFiles[i], 'Motorische_taken_OFF') && str_detect(names(json$crf), 'Up3On')){
                                print(dSub)
                                msg <- 'Up3On variable found in Off assessment, replacing with Up3Of...'
                                print(msg)
                                names(json$crf) <- str_replace_all(names(json$crf), 'Up3Of', 'Up3On')
                        }
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
                Visits <- Visits[startsWith(Visits,'ses-Visit')]
                for(t in Visits){
                        dat <- ImportCastorJson(n, t)
                        nam <- names(dat)
                        VarNames <- c(VarNames, nam)
                        VarNames <- unique(VarNames)
                }
        }
        # Initialize the final data frame and name variables
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
                Visits <- Visits[startsWith(Visits,'ses-Visit')]
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
        
        ##### Preprocessing #####
        
        # Sort data frame
        df2 <- df %>%
                        arrange(pseudonym, Timepoint)
        
        # Define an approximate disease onset and estimated disease duration
        # NOTE: Warnings in this step come from NAs in Visit2, nothing to be concerned about
        DefineDiseaseDuration <- function(dataframe){
                
                # Convert assessment time to date format
                dataframe <- dataframe %>%
                        mutate(Up3OfAssesTime = sub(';.*', '', Up3OfAssesTime)) %>%
                        mutate(Up3OfAssesTime = dmy(Up3OfAssesTime))
                
                # Calculate time of diagnosis (which is only available for Visit1)
                YearOnly <- dataframe %>%
                        select(pseudonym, Timepoint, DiagParkYear, DiagParkMonth, DiagParkDay,
                               Up3OfAssesTime) %>%
                        filter(!is.na(DiagParkYear)) %>%
                        filter(is.na(DiagParkMonth))
                YearOnly$DiagParkYear <- as.numeric(YearOnly$DiagParkYear)
                YearOnly$DiagParkMonth <- c(6)
                YearOnly$DiagParkDay <- c(15)
                
                YearMonthOnly <- dataframe %>%
                        select(pseudonym, Timepoint, DiagParkYear, DiagParkMonth, DiagParkDay,
                               Up3OfAssesTime) %>%
                        filter(!is.na(DiagParkYear)) %>%
                        filter(!is.na(DiagParkMonth)) %>%
                        filter(is.na(DiagParkDay))
                YearMonthOnly$DiagParkYear <- as.numeric(YearMonthOnly$DiagParkYear)
                YearMonthOnly$DiagParkMonth <- as.numeric(YearMonthOnly$DiagParkMonth)
                YearMonthOnly$DiagParkDay <- c(15) 
                
                YearMonthDay <- dataframe %>%
                        select(pseudonym, Timepoint, DiagParkYear, DiagParkMonth, DiagParkDay,
                               Up3OfAssesTime) %>%
                        filter(!is.na(DiagParkYear)) %>%
                        filter(!is.na(DiagParkMonth)) %>%
                        filter(!is.na(DiagParkDay))
                YearMonthDay$DiagParkYear <- as.numeric(YearMonthDay$DiagParkYear)
                YearMonthDay$DiagParkMonth <- as.numeric(YearMonthDay$DiagParkMonth)
                YearMonthDay$DiagParkDay <- as.numeric(YearMonthDay$DiagParkDay)
                
                YearMissing <- dataframe %>%
                        select(pseudonym, Timepoint, DiagParkYear, DiagParkMonth, DiagParkDay,
                               Up3OfAssesTime) %>%
                        filter(is.na(DiagParkYear))
                YearMissing$DiagParkYear <- as.numeric(YearMissing$DiagParkYear)
                YearMissing$DiagParkMonth <- as.numeric(YearMissing$DiagParkMonth)
                YearMissing$DiagParkDay <- as.numeric(YearMissing$DiagParkDay)
                
                # Bind estimated diagnosis dates and sort
                EstDiagnosisDates <- bind_rows(YearOnly, YearMonthOnly, YearMonthDay, YearMissing) %>%
                        arrange(pseudonym, Timepoint) %>% 
                        mutate(EstDiagDate = ymd(paste(DiagParkYear,DiagParkMonth,DiagParkDay))) %>%
                        mutate(EstDisDurYears = as.numeric(Up3OfAssesTime - EstDiagDate) / 365) %>%
                        mutate(TimeToFUYears = 0)
                
                # Compute time to follow-up and estimated disease duration
                for(n in 1:nrow(EstDiagnosisDates)){
                        if(EstDiagnosisDates$Timepoint[n] == 'ses-Visit2' && EstDiagnosisDates$Timepoint[n-1] == 'ses-Visit1' && EstDiagnosisDates$pseudonym[n] == EstDiagnosisDates$pseudonym[n-1]){
                                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-1]) / 365
                                EstDiagnosisDates$EstDisDurYears[n] <- EstDiagnosisDates$EstDisDurYears[n-1]
                        }
                }
                
                dataframe <- bind_cols(dataframe, tibble(EstDisDurYears = EstDiagnosisDates$EstDisDurYears, TimeToFUYears = EstDiagnosisDates$TimeToFUYears))
                return(dataframe)
                
        }
        df2 <- DefineDiseaseDuration(df2)
        
        # Lists of subscores
        list.TotalOff <- c('Up3OfSpeech', 'Up3OfFacial', 'Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle',
                           'Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                           'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                           'Up3OfArise', 'Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos', 'Up3OfPostur', 'Up3OfSpont', 'Up3OfPosTYesDev',
                           'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev', 'Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev',
                           'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw', 'Up3OfConstan')
        list.TotalOn <- str_replace(list.TotalOff, 'Of','On')
        list.BradykinesiaOff <- c('Up3OfFiTaYesDev', 'Up3OfFiTaNonDev', 'Up3OfHaMoYesDev', 'Up3OfHaMoNonDev', 'Up3OfProSYesDev',
                                  'Up3OfProSNonDev', 'Up3OfToTaYesDev', 'Up3OfToTaNonDev', 'Up3OfLAgiYesDev', 'Up3OfLAgiNonDev',
                                  'Up3OfArise', 'Up3OfSpont')
        list.BradykinesiaOn <- str_replace(list.BradykinesiaOff, 'Of', 'On')
        list.RestTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfConstan')
        list.RestTremorOn <- str_replace(list.RestTremorOff, 'Of', 'On')
        list.RigidityOff <- c('Up3OfRigNec', 'Up3OfRigRue', 'Up3OfRigLue', 'Up3OfRigRle', 'Up3OfRigLle')
        list.RigidityOn <- str_replace(list.RigidityOff, 'Of','On')
        list.PIGDOff <- c('Up3OfGait', 'Up3OfFreez', 'Up3OfStaPos')
        list.PIGDOn <- str_replace(list.PIGDOff, 'Of', 'On')
        list.ActionTremorOff <- c('Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev')
        list.ActionTremorOn <- str_replace(list.RigidityOff, 'Of', 'On')
        list.CompositeTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev',
                                     'Up3OfConstan','Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev')
        list.CompositeTremorOn <- str_replace(list.CompositeTremorOff, 'Of', 'On')
        
        
        # Variable selection / construction
        VariableSelectionConstruction <- function(dataframe){

                # Variable selection and definition of subscores
                dataframe <- dataframe %>%
                        select(pseudonym,
                               Age,
                               Gender, 
                               EstDisDurYears,
                               Timepoint,
                               TimeToFUYears,
                               MriNeuroPsychTask,
                               DiagParkCertain,
                               MostAffSide,
                               PrefHand,
                               ParkinMedUser,
                               starts_with('Up3Of'),
                               starts_with('Up3On'),
                               starts_with('Up1a'),
                               starts_with('Updrs2'),
                               starts_with('Nps'),
                               starts_with('ScopaAut'),
                               starts_with('Ess'),
                               starts_with('ScopaSlp'),
                               starts_with('RemSbdq')) %>%
                        mutate(across(-c('pseudonym', 'Updrs2Cag', 'ScopaAut31b', 'ScopaAut32b', 'NpsMocBonus', 'Timepoint', 'ScopaAutCag',
                                         'ScopaAut29b', 'EssCag', 'ScopaSlpCag', 'RemSbdqCag'), as.numeric)) %>% 
                        mutate(Up3OfTotal = rowSums(.[list.TotalOff]),
                               Up3OnTotal = rowSums(.[list.TotalOn])) %>%
                        mutate(Up3OfBradySum = rowSums(.[list.BradykinesiaOff]),
                               Up3OnBradySum = rowSums(.[list.BradykinesiaOn])) %>%
                        mutate(Up3OfRestTremAmpSum = rowSums(.[list.RestTremorOff]),
                               Up3OnRestTremAmpSum = rowSums(.[list.RestTremorOn])) %>%
                        mutate(Up3OfRigiditySum = rowSums(.[list.RigidityOff]),
                               Up3OnRigiditySum = rowSums(.[list.RigidityOn])) %>%
                        mutate(Up3OfPIGDSum = rowSums(.[list.PIGDOff]),
                               Up3OnPIGDSum = rowSums(.[list.PIGDOn])) %>%
                        mutate(Up3OfActionTremorSum = rowSums(.[list.ActionTremorOff]),
                               Up3OnActionTremorSum = rowSums(.[list.ActionTremorOn])) %>%
                        mutate(Up3OfCompositeTremorSum = rowSums(.[list.CompositeTremorOff]),
                               Up3OnCompositeTremorSum = rowSums(.[list.CompositeTremorOn])) %>%
                        mutate(Up3TotalOnOffDelta = Up3OfTotal - Up3OnTotal,
                               Up3BradySumOnOffDelta = Up3OfBradySum - Up3OnBradySum,
                               Up3RestTremAmpSumOnOffDelta = Up3OfRestTremAmpSum - Up3OnRestTremAmpSum)
                
                return(dataframe)
        }
        df3 <- VariableSelectionConstruction(df2)
        
        # Extend time-invariant variables to all levels of 'Timepoint'
        varlist <- c('Gender', 'Age', 'MriNeuroPsychTask', 'EstDisDurYears')
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
                dataframe$Up3OfHoeYah <- as.factor(dataframe$Up3OfHoeYah)                     # Hoen & Yahr stage
                dataframe$Up3OnHoeYah <- as.factor(dataframe$Up3OnHoeYah)
                dataframe$MriNeuroPsychTask <- as.factor(dataframe$MriNeuroPsychTask)         # Which task was done?
                levels(dataframe$MriNeuroPsychTask) <- c('Motor', 'Reward')
                dataframe$DiagParkCertain <- as.factor(dataframe$DiagParkCertain)             # Certainty of diagnosis
                levels(dataframe$DiagParkCertain) <- c('PD','DoubtAboutPD','Parkinsonism','DoubtAboutParkinsonism', 'NeitherDisease')
                dataframe$MostAffSide <- as.factor(dataframe$MostAffSide)                     # Most affected side
                levels(dataframe$MostAffSide) <- c('RightOnly', 'LeftOnly', 'BiR>L', 'BiL>R', 'BiR=L', 'None')
                dataframe$PrefHand <- as.factor(dataframe$PrefHand)                           # Dominant hand
                levels(dataframe$PrefHand) <- c('Right', 'Left', 'NoPref')
                dataframe$Gender <- as.factor(dataframe$Gender)                               # Gender
                levels(dataframe$Gender) <- c('Male', 'Female')
                dataframe$Age <- as.numeric(dataframe$Age)                                    # Age
                dataframe$ParkinMedUser <- as.factor(dataframe$ParkinMedUser)                 # Parkinson's medication use
                levels(dataframe$ParkinMedUser) <- c('No','Yes')
                dataframe$NpsEducYears <- as.numeric(dataframe$NpsEducYears)                  # Education years
                dataframe$Timepoint <- as.factor(dataframe$Timepoint)                         # Timepoint
                return(dataframe)
        }
        df5 <- TransformVariables(df4)
        
        # Calculate disease progression (Year2 - Year1) and indicate which participants have FU data
        # TODO: What should be done about Year3? Calculate (Year3 - Year2)?
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
                        mutate(Up3OfTotal.1YearDelta = NA,
                               Up3OnTotal.1YearDelta = NA,
                               Up3OfTotal.1YearROC = NA,
                               Up3OnTotal.1YearROC = NA,
                               
                               Up3OfBradySum.1YearDelta = NA,
                               Up3OnBradySum.1YearDelta = NA,
                               Up3OfBradySum.1YearROC = NA,
                               Up3OnBradySum.1YearROC = NA,
                               
                               Up3OfRestTremAmpSum.1YearDelta = NA,
                               Up3OnRestTremAmpSum.1YearDelta = NA,
                               Up3OfRestTremAmpSum.1YearROC = NA,
                               Up3OnRestTremAmpSum.1YearROC = NA,
                               
                               Up3OfRigiditySum.1YearDelta = NA,
                               Up3OnRigiditySum.1YearDelta = NA,
                               Up3OfRigiditySum.1YearROC = NA,
                               Up3OnRigiditySum.1YearROC = NA,
                               
                               Up3OfPIGDSum.1YearDelta = NA,
                               Up3OnPIGDSum.1YearDelta = NA,
                               Up3OfPIGDSum.1YearROC = NA,
                               Up3OnPIGDSum.1YearROC = NA,
                               
                               MultipleSessions = 0)
                
                alpha <- 0.5
                for(n in 1:nrow(dataframe)){
                        if(dataframe$Timepoint[n] == 'ses-Visit2' && dataframe$Timepoint[n-1] == 'ses-Visit1'){
                                
                                dataframe$Up3OfTotal.1YearDelta[(n-1):n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]
                                dataframe$Up3OnTotal.1YearDelta[(n-1):n] <- dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]
                                #dataframe$Up3OfTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]) / dataframe$Up3OfTotal[n-1]) * 100
                                #dataframe$Up3OnTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]) / dataframe$Up3OnTotal[n-1]) * 100
                                dataframe$Up3OfTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfTotal[n-1], dataframe$Up3OfTotal[n], length(list.TotalOff), alpha = 0.5/length(list.TotalOff))
                                dataframe$Up3OnTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnTotal[n-1], dataframe$Up3OnTotal[n], length(list.TotalOn), alpha = 0.5/length(list.TotalOn))
                                
                                dataframe$Up3OfBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]
                                dataframe$Up3OnBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]
                                #dataframe$Up3OfBradySum.1YearROC[(n-1):n] <- ((dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]) / dataframe$Up3OfBradySum[n-1]) * 100
                                #dataframe$Up3OnBradySum.1YearROC[(n-1):n] <- ((dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]) / dataframe$Up3OnBradySum[n-1]) * 100
                                dataframe$Up3OfBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfBradySum[n-1], dataframe$Up3OfBradySum[n], length(list.BradykinesiaOff), alpha = 0.5/length(list.BradykinesiaOff))
                                dataframe$Up3OnBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnBradySum[n-1], dataframe$Up3OnBradySum[n], length(list.BradykinesiaOn), alpha = 0.5/length(list.BradykinesiaOn))
                                
                                dataframe$Up3OfRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]
                                dataframe$Up3OnRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]
                                #dataframe$Up3OfRestTremAmpSum.1YearROC[(n-1):n] <- ((dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]) / dataframe$Up3OfRestTremAmpSum[n-1]) * 100
                                #dataframe$Up3OnRestTremAmpSum.1YearROC[(n-1):n] <- ((dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]) / dataframe$Up3OnRestTremAmpSum[n-1]) * 100
                                dataframe$Up3OfRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRestTremAmpSum[n-1], dataframe$Up3OfRestTremAmpSum[n], length(list.RestTremorOff), alpha = 0.5/length(list.RestTremorOff))
                                dataframe$Up3OnRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRestTremAmpSum[n-1], dataframe$Up3OnRestTremAmpSum[n], length(list.RestTremorOn), alpha = 0.5/length(list.RestTremorOff))
                                
                                dataframe$Up3OfRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-1]
                                dataframe$Up3OnRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-1]
                                #dataframe$Up3OfRigiditySum.1YearROC[(n-1):n] <- ((dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-1]) / dataframe$Up3OfRigiditySum[n-1]) * 100
                                #dataframe$Up3OnRigiditySum.1YearROC[(n-1):n] <- ((dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-1]) / dataframe$Up3OnRigiditySum[n-1]) * 100
                                dataframe$Up3OfRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRigiditySum[n-1], dataframe$Up3OfRigiditySum[n], length(list.RigidityOff), alpha = 0.5/length(list.RigidityOff))
                                dataframe$Up3OnRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRigiditySum[n-1], dataframe$Up3OnRigiditySum[n], length(list.RigidityOn), alpha = 0.5/length(list.RigidityOn))
                                
                                dataframe$Up3OfPIGDSum.1YearDelta[(n-1):n] <- dataframe$Up3OfPIGDSum[n] - dataframe$Up3OfPIGDSum[n-1]
                                dataframe$Up3OnPIGDSum.1YearDelta[(n-1):n] <- dataframe$Up3OnPIGDSum[n] - dataframe$Up3OnPIGDSum[n-1]
                                #dataframe$Up3OfPIGDSum.1YearROC[(n-1):n] <- ((dataframe$Up3OfPIGDSum[n] - dataframe$Up3OfPIGDSum[n-1]) / dataframe$Up3OfPIGDSum[n-1]) * 100
                                #dataframe$Up3OnPIGDSum.1YearROC[(n-1):n] <- ((dataframe$Up3OnPIGDSum[n] - dataframe$Up3OnPIGDSum[n-1]) / dataframe$Up3OnPIGDSum[n-1]) * 100
                                dataframe$Up3OfPIGDSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfPIGDSum[n-1], dataframe$Up3OfPIGDSum[n], length(list.PIGDOff), alpha = 0.5/length(list.PIGDOff))
                                dataframe$Up3OnPIGDSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnPIGDSum[n-1], dataframe$Up3OnPIGDSum[n], length(list.PIGDOn), alpha = 0.5/length(list.PIGDOn))
                                
                                dataframe$MultipleSessions[(n-1):n] = 1
                        }
                }
                dataframe$MultipleSessions <- as.factor(dataframe$MultipleSessions)
                levels(dataframe$MultipleSessions) <- c('No','Yes')
                return(dataframe)
                
        }
        df6 <- CalculateDiseaseProgression(df5)
        
        # Rearrange variables
        df7 <- df6 %>%
                relocate(pseudonym, Timepoint, Gender, Age, EstDisDurYears, TimeToFUYears, MultipleSessions, MriNeuroPsychTask,
                         Up3OfTotal, Up3OfTotal.1YearDelta, Up3OfTotal.1YearROC,
                         Up3OnTotal, Up3OnTotal.1YearDelta, Up3OnTotal.1YearROC)
        
        #####
        
        ##### Report / Fix oddities #####
        
        # TimeToFUYears: Negative values
        Check1 <- function(dataframe){
                BelowZeroFU <- dataframe %>%
                        filter(TimeToFUYears < 0)
                cat(nrow(BelowZeroFU), ' participants have negative time to follow-up, check so that visit 1 data is available.', '\n',
                    'Data entry mistake may have been made. Setting TimeToFUYears to positive for: ', '\n', sep = '')
                print(BelowZeroFU$pseudonym)
                idx <- dataframe$TimeToFUYears[dataframe$TimeToFUYears < 0 & !is.na(dataframe$TimeToFUYears)]
                dataframe$TimeToFUYears[idx] <- dataframe$TimeToFUYears[idx]*(-1)  
                return(dataframe)
        }
        df8 <- Check1(df7)
        
        # EstDisDurYears: Negative values
        Check2 <- function(dataframe){
                BelowZeroDisDur <- dataframe %>%
                        filter(EstDisDurYears < 0)
                cat(nrow(BelowZeroDisDur), ' participants have negative disease durations, check so that visit 1 data is available.', '\n',
                    'Data entry mistake may have been made. Setting EstDisDurYears to positive for: ', '\n', sep = '')
                print(BelowZeroDisDur$pseudonym)
                idx <- dataframe$EstDisDurYears[dataframe$EstDisDurYears < 0 & !is.na(dataframe$EstDisDurYears)]
                dataframe$EstDisDurYears[idx] <- dataframe$EstDisDurYears[idx]*(-1)
                return(dataframe)
        }
        df9 <- Check2(df8)
        
        # Missing values
        Check3 <- function(dataframe){
                x <- apply(dataframe, 2, is.na) %>% colSums
                msg <- c('Reporting missing values per variable...')
                print(msg)
                print(x)
        }
        Check3(df7)
        
        #####
        
        ##### Write to csv #####
        
        outputfile <- paste(bidsdir, 'derivatives/database_clinical_variables.csv', sep = '')
        if(!dir.exists(dirname(outputfile))){
                dir.create(dirname(outputfile))
        }
        if(file.exists(outputfile)){
                file.remove(outputfile)
        }
        write_csv(df7, outputfile)
        
        #####        
        
}










