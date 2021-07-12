# This script generates a single csv file that summarizes the clinical variables
# of all subjects in the specified bids-directory
# The output file is in person-period format

generate_castor_csv <- function(bidsdir){
        
        library(tidyverse)
        library(jsonlite)
        library(stringr)
        library(lubridate)
        library(assertthat)
        
        bidsdir <- 'P:/3022026.01/pep/ClinVars/'
        
        # Define a list of subjects
        Subjects <- basename(list.dirs(bidsdir, recursive = FALSE)) 
        Subjects <- Subjects[str_starts(Subjects, 'sub-')]
        
        # Import a row of data for a specified subject and visit
        # Finds json files, parses them, and binds variables horizontally
        # NOTE: Visit and Home questionnaires are collapsed to a single row
        ImportCastorJson <- function(subject, visit){
                
                
                # Find subject's files and subset by pattern
                # Visits and home questionnaires are collapsed (i.e. treated as one time point)
                dSub <- paste(bidsdir, subject, sep='')
                fAllFiles <- dir(dSub, full.names = TRUE, recursive = TRUE)
                fSubsetFiles <- fAllFiles[grep(visit, fAllFiles)]
                if(visit=='ses-POMVisit1'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires1', fAllFiles)])
                }
                if(visit=='ses-POMVisit2'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires2', fAllFiles)])
                }
                if(visit=='ses-POMVisit3'){
                        fSubsetFiles <- c(fSubsetFiles, fAllFiles[grep('ses-POMHomeQuestionnaires3', fAllFiles)])
                }
                
                # FIX: Removal of duplication and naming errors
                if(visit=='ses-POMVisit1' || visit=='ses-POMVisit2' || visit=='ses-POMVisit3'){
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
                Visits <- Visits[startsWith(Visits,'ses-POMVisit')]
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
                Visits <- Visits[startsWith(Visits,'ses-POMVisit')]
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
        # Add task variable
        df <- bind_cols(df, tibble(MriNeuroPsychTask = rep('NA', VisitCounter)))
        #####
        
        ##### Import data #####
        # Import subject data variable by variable
        RowID <- 1
        for(n in 1:length(Subjects)){
                dSubDir <- paste(bidsdir, Subjects[n], sep='')
                Visits <- dir(dSubDir)
                Visits <- Visits[startsWith(Visits,'ses-POMVisit')]
                dTaskDir <- paste(dirname(bidsdir), '/bids/', Subjects[n], '/', Visits[1], '/beh', sep='')
                behfiles <- dir(dTaskDir)
                if(length(behfiles[str_detect(behfiles, 'task-motor')]) > 0 & length(behfiles[str_detect(behfiles, 'task-reward')]) == 0){
                        Task <- 'Motor'
                }else if(length(behfiles[str_detect(behfiles, 'task-reward')]) > 0 & length(behfiles[str_detect(behfiles, 'task-motor')]) == 0){
                        Task <- 'Reward'
                }
                for(t in Visits){
                        dat <- ImportCastorJson(Subjects[n], t)
                        SubVarNames <- colnames(dat)
                        for(i in 1:length(SubVarNames)){
                                colidx <- str_which(VarNames, SubVarNames[i])
                                df[RowID,colidx] <- unlist(dat[i])  # < Some variables are lists, like dat[77], these will be incorrectly imported!!! 
                        }
                        df$Timepoint[RowID] <- t
                        df$MriNeuroPsychTask[RowID] <- Task
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
                        if(EstDiagnosisDates$Timepoint[n] == 'ses-POMVisit2' && EstDiagnosisDates$Timepoint[n-1] == 'ses-POMVisit1' && EstDiagnosisDates$pseudonym[n] == EstDiagnosisDates$pseudonym[n-1]){
                                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-1]) / 365
                                EstDiagnosisDates$EstDisDurYears[n] <- EstDiagnosisDates$EstDisDurYears[n-1]
                        }else if(EstDiagnosisDates$Timepoint[n] == 'ses-POMVisit3' && EstDiagnosisDates$Timepoint[n-2] == 'ses-POMVisit1' && EstDiagnosisDates$pseudonym[n] == EstDiagnosisDates$pseudonym[n-2]){
                                EstDiagnosisDates$TimeToFUYears[n] <- as.numeric(EstDiagnosisDates$Up3OfAssesTime[n] - EstDiagnosisDates$Up3OfAssesTime[n-2]) / 365
                                EstDiagnosisDates$EstDisDurYears[n] <- EstDiagnosisDates$EstDisDurYears[n-2]
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
        list.CompositeTremorOff <- c('Up3OfRAmpArmYesDev', 'Up3OfRAmpArmNonDev', 'Up3OfRAmpLegYesDev', 'Up3OfRAmpLegNonDev', 'Up3OfRAmpJaw',
                                     'Up3OfConstan','Up3OfPosTYesDev', 'Up3OfPosTNonDev', 'Up3OfKinTreYesDev', 'Up3OfKinTreNonDev')
        list.CompositeTremorOn <- str_replace(list.CompositeTremorOff, 'Of', 'On')
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
        list.QUIP_medication <- c('QuipIt06', 'QuipIt14', 'QuipIt21', 'QuipIt28')
        list.QUIP_icd <- c(list.QUIP_gambling, list.QUIP_sex, list.QUIP_buying, list.QUIP_eating)
        list.QUIP_rs <- c(list.QUIP_icd, list.QUIP_hobbypund, list.QUIP_medication)
        list.AES12 <- c('Aes12Pd01', 'Aes12Pd02', 'Aes12Pd03', 'Aes12Pd04', 'Aes12Pd05', 'Aes12Pd06', 'Aes12Pd07', 'Aes12Pd08', 'Aes12Pd09',
                        'Aes12Pd10', 'Aes12Pd11', 'Aes12Pd12')
        list.Apat <- c('Apat01','Apat02','Apat03','Apat04','Apat05','Apat06','Apat07','Apat08','Apat09','Apat10','Apat11','Apat12',
                       'Apat13','Apat14')
        list.BDI2 <- c('Bdi2It01', 'Bdi2It02', 'Bdi2It03', 'Bdi2It04', 'Bdi2It05', 'Bdi2It06', 'Bdi2It07', 'Bdi2It08', 'Bdi2It09',  'Bdi2It10',
                       'Bdi2It11', 'Bdi2It12', 'Bdi2It13', 'Bdi2It14', 'Bdi2It15', 'Bdi2It16', 'Bdi2It17', 'Bdi2It18', 'Bdi2It19', 'Bdi2It20', 'Bdi2It21')
        list.TalkProb <- c('TalkProb01', 'TalkProb02', 'TalkProb03', 'TalkProb04', 'TalkProb05', 'TalkProb06', 'TalkProb07')
        list.VisualProb23 <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04', 'VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr08', 'VisualPr09',
                              'VisualPr10', 'VisualPr11', 'VisualPr12', 'VisualPr13', 'VisualPr14', 'VisualPr15', 'VisualPr16', 'VisualPr17', 'VisualPr18',
                              'VisualPr19', 'VisualPr20', 'VisualPr21', 'VisualPr22', 'VisualPr23')
        list.VisualProb17_ocularsurface <- c('VisualPr01', 'VisualPr02', 'VisualPr03', 'VisualPr04')
        list.VisualProb17_intraocular <- c('VisualPr08','VisualPr09','VisualPr15','VisualPr19')
        list.VisualProb17_oculomotor <- c('VisualPr05', 'VisualPr06', 'VisualPr07', 'VisualPr23')
        list.VisualProb17_opticnerve <- c('VisualPr11', 'VisualPr13', 'VisualPr14', 'VisualPr21', 'VisualPr22')
        list.VisualProb17 <- c(list.VisualProb17_ocularsurface, list.VisualProb17_intraocular, list.VisualProb17_oculomotor, list.VisualProb17_opticnerve)
        list.PDQ39_mobility <- c("Pdq39It01","Pdq39It02","Pdq39It03","Pdq39It04","Pdq39It05","Pdq39It06","Pdq39It07","Pdq39It08","Pdq39It09","Pdq39It10")
        list.PDQ39_activities <- c("Pdq39It11","Pdq39It12","Pdq39It13","Pdq39It14","Pdq39It15","Pdq39It16")
        list.PDQ39_emotional <- c("Pdq39It17","Pdq39It18","Pdq39It19","Pdq39It20","Pdq39It21","Pdq39It22")
        list.PDQ39_stigma <- c("Pdq39It23","Pdq39It24","Pdq39It25","Pdq39It26")
        list.PDQ39_socialsupport <- c("Pdq39It27","Pdq39It28b","Pdq39It29")
        list.PDQ39_cognitions <- c("Pdq39It30","Pdq39It31","Pdq39It32","Pdq39It33")
        list.PDQ39_communication <- c("Pdq39It34","Pdq39It35","Pdq39It36")
        list.PDQ39_bodilydiscomfort <- c("Pdq39It37","Pdq39It38","Pdq39It39")
        list.PDQ39_singleindex <-  c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum', 'PDQ39_stigmaSum', 'PDQ39_socialsupportSum',
                                     'PDQ39_cognitionsSum', 'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')
        
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
                               starts_with('RemSbdq'),
                               starts_with('Quip'),
                               starts_with('test'),
                               starts_with('Aes12'),
                               starts_with('Sf12'),
                               starts_with('Bdi2'),
                               starts_with('Pdq39'),
                               starts_with('Stai'),
                               starts_with('Woq'),
                               starts_with('TalkProb'),
                               starts_with('VisualPr'),
                               starts_with('FrOf'),
                               starts_with('Fog'),
                               starts_with('Pase'),
                               starts_with('Fallen')) %>%
                        mutate(across(-c('pseudonym', 'Updrs2Cag', 'ScopaAut31b', 'ScopaAut32b', 'NpsMocBonus', 'Timepoint', 'MriNeuroPsychTask', 'ScopaAutCag',
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
                        mutate(Up3TotalOnOffDelta = Up3OnTotal - Up3OfTotal,
                               Up3BradySumOnOffDelta = Up3OnBradySum - Up3OfBradySum,
                               Up3RestTremAmpSumOnOffDelta = Up3OnRestTremAmpSum - Up3OfRestTremAmpSum,
                               Up3RigidityOnOffDelta =  Up3OnRigiditySum- Up3OfActionTremorSum,
                               Up3PIGDOnOffDelta = Up3OnPIGDSum - Up3OfPIGDSum,
                               Up3PegRLBOnOffDelta = Up3OnPegRLBSum - Up3OfPegRLBSum) %>%
                        mutate(STAITraitSum = rowSums(.[list.STAITrait]),
                               STAIStateSum = rowSums(.[list.STAIState]),
                               QUIPicdSum = rowSums(.[list.QUIP_icd]),
                               QUIPrsSum = rowSums(.[list.QUIP_rs]),
                               AES12Sum = rowSums(.[list.AES12]),
                               ApatSum = rowSums(.[list.Apat]),
                               BDI2Sum = rowSums(.[list.BDI2]),
                               TalkProbSum = rowSums(.[list.TalkProb]),
                               VisualProb23Sum = rowSums(.[list.VisualProb23]),
                               VisualProb17Sum = rowSums(.[list.VisualProb17]),
                               PDQ39_mobilitySum = rowSums(.[list.PDQ39_mobility]) / (4*10) * 100,
                               PDQ39_activitiesSum = rowSums(.[list.PDQ39_activities]) / (4*6) * 100,
                               PDQ39_emotionalSum = rowSums(.[list.PDQ39_emotional]) / (4*6) * 100,
                               PDQ39_stigmaSum = rowSums(.[list.PDQ39_stigma]) / (4*4) * 100,
                               PDQ39_socialsupportSum = rowSums(.[list.PDQ39_socialsupport], na.rm = TRUE),
                               PDQ39_cognitionsSum = rowSums(.[list.PDQ39_cognitions]) / (4*4) * 100,
                               PDQ39_communicationSum = rowSums(.[list.PDQ39_communication]) / (4*3) * 100,
                               PDQ39_bodilydiscomfortSum = rowSums(.[list.PDQ39_bodilydiscomfort]) / (4*3) * 100) %>%
                        mutate(Group = 'PD_POM')
                
                
                for(v in 1:length(dataframe$PDQ39_socialsupportSum)){
                        if(is.na(dataframe$Pdq39It27[v]) | (dataframe$Pdq39It28a[v] == 1 && is.na(dataframe$Pdq39It28b[v])) | is.na(dataframe$Pdq39It29[v])){
                                dataframe$PDQ39_socialsupportSum[v] <- NA
                        }else
                                
                                nrvars <- length(na.omit(c(dataframe$Pdq39It27[v], dataframe$Pdq39It28a[v], dataframe$Pdq39It28b[v], dataframe$Pdq39It29[v])))
                                dataframe$PDQ39_socialsupportSum[v] <- dataframe$PDQ39_socialsupportSum[v] / (4*nrvars) * 100
                }
                
                
                # Calculate a single sum from all PDQ39 domains
                dataframe <- dataframe %>%
                        rowwise() %>%
                        mutate(PDQ39_SingleIndex = sum(c_across(c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum',
                                                                  'PDQ39_stigmaSum', 'PDQ39_socialsupportSum', 'PDQ39_cognitionsSum',
                                                                  'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')), na.rm = FALSE),
                               PDQ39_SingleIndex = PDQ39_SingleIndex / length(na.omit(c_across(c('PDQ39_mobilitySum', 'PDQ39_activitiesSum', 'PDQ39_emotionalSum',
                                                                                                 'PDQ39_stigmaSum', 'PDQ39_socialsupportSum', 'PDQ39_cognitionsSum',
                                                                                                 'PDQ39_communicationSum', 'PDQ39_bodilydiscomfortSum')))))
                
                
                return(dataframe)
                
        }
        df3 <- VariableSelectionConstruction(df2)
        
        # Extend time-invariant variables to all levels of 'Timepoint'
        varlist <- c('Gender', 'Age', 'EstDisDurYears')
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
                               
                               Up3OfCompositeTremorSum.1YearDelta = NA,
                               Up3OnCompositeTremorSum.1YearDelta = NA,
                               Up3OfCompositeTremorSum.1YearROC = NA,
                               Up3OnCompositeTremorSum.1YearROC = NA,
                               
                               Up3OfRigiditySum.1YearDelta = NA,
                               Up3OnRigiditySum.1YearDelta = NA,
                               Up3OfRigiditySum.1YearROC = NA,
                               Up3OnRigiditySum.1YearROC = NA,
                               
                               Up3OfPIGDSum.1YearDelta = NA,
                               Up3OnPIGDSum.1YearDelta = NA,
                               Up3OfPIGDSum.1YearROC = NA,
                               Up3OnPIGDSum.1YearROC = NA,
                               
                               Up3OfPegRLBSum.1YearDelta = NA,
                               Up3OnPegRLBSum.1YearDelta = NA,
                               Up3OfPegRLBSum.1YearROC = NA,
                               Up3OnPegRLBSum.1YearROC = NA,
                               
                               Up3OfTotal.2YearDelta = NA,
                               Up3OnTotal.2YearDelta = NA,
                               Up3OfTotal.2YearROC = NA,
                               Up3OnTotal.2YearROC = NA,
                               
                               Up3OfBradySum.2YearDelta = NA,
                               Up3OnBradySum.2YearDelta = NA,
                               Up3OfBradySum.2YearROC = NA,
                               Up3OnBradySum.2YearROC = NA,
                               
                               Up3OfRestTremAmpSum.2YearDelta = NA,
                               Up3OnRestTremAmpSum.2YearDelta = NA,
                               Up3OfRestTremAmpSum.2YearROC = NA,
                               Up3OnRestTremAmpSum.2YearROC = NA,
                               
                               Up3OfCompositeTremorSum.1YearDelta = NA,
                               Up3OnCompositeTremorSum.1YearDelta = NA,
                               Up3OfCompositeTremorSum.1YearROC = NA,
                               Up3OnCompositeTremorSum.1YearROC = NA,
                               
                               Up3OfRigiditySum.2YearDelta = NA,
                               Up3OnRigiditySum.2YearDelta = NA,
                               Up3OfRigiditySum.2YearROC = NA,
                               Up3OnRigiditySum.2YearROC = NA,
                               
                               Up3OfPIGDSum.2YearDelta = NA,
                               Up3OnPIGDSum.2YearDelta = NA,
                               Up3OfPIGDSum.2YearROC = NA,
                               Up3OnPIGDSum.2YearROC = NA,
                               
                               Up3OfPegRLBSum.2YearDelta = NA,
                               Up3OnPegRLBSum.2YearDelta = NA,
                               Up3OfPegRLBSum.2YearROC = NA,
                               Up3OnPegRLBSum.2YearROC = NA,
                               
                               STAITraitSum.1YearDelta = NA,
                               STAITraitSum.1YearROC = NA,
                               STAITraitSum.2YearDelta = NA,
                               STAITraitSum.2YearROC = NA,
                               
                               STAIStateSum.1YearDelta = NA,
                               STAIStateSum.1YearROC = NA,
                               STAIStateSum.2YearDelta = NA,
                               STAIStateSum.2YearROC = NA,
                               
                               QUIPicdSum.1YearDelta = NA,
                               QUIPicdSum.1YearROC = NA,
                               QUIPicdSum.2YearDelta = NA,
                               QUIPicdSum.2YearROC = NA,
                               
                               QUIPrsSum.1YearDelta = NA,
                               QUIPrsSum.1YearROC = NA,
                               QUIPrsSum.2YearDelta = NA,
                               QUIPrsSum.2YearROC = NA,
                               
                               AES12Sum.1YearDelta = NA,
                               AES12Sum.1YearROC = NA,
                               AES12Sum.2YearDelta = NA,
                               AES12Sum.2YearROC = NA,
                               
                               ApatSum.1YearDelta = NA,
                               ApatSum.1YearROC = NA,
                               ApatSum.2YearDelta = NA,
                               ApatSum.2YearROC = NA,
                               
                               BDI2Sum.1YearDelta = NA,
                               BDI2Sum.1YearROC = NA,
                               BDI2Sum.2YearDelta = NA,
                               BDI2Sum.2YearROC = NA,
                               
                               PDQ39_SingleIndex.1YearDelta = NA,
                               PDQ39_SingleIndex.1YearROC = NA,
                               PDQ39_SingleIndex.2YearDelta = NA,
                               PDQ39_SingleIndex.2YearROC = NA,
                               
                               TalkProbSum.1YearDelta = NA,
                               TalkProbSum.1YearROC = NA,
                               TalkProbSum.2YearDelta = NA,
                               TalkProbSum.2YearROC = NA,
                               
                               VisualProb23Sum.1YearDelta = NA,
                               VisualProb23Sum.1YearROC = NA,
                               VisualProb23Sum.2YearDelta = NA,
                               VisualProb23Sum.2YearROC = NA,
                               
                               VisualProb17Sum.1YearDelta = NA,
                               VisualProb17Sum.1YearROC = NA,
                               VisualProb17Sum.2YearDelta = NA,
                               VisualProb17Sum.2YearROC = NA,
                               
                               MultipleSessions = 0)
                
                alpha <- 0.5
                for(n in 1:nrow(dataframe)){
                        if(dataframe$Timepoint[n] == 'ses-POMVisit2' && dataframe$Timepoint[n-1] == 'ses-POMVisit1'){
                                
                                dataframe$Up3OfTotal.1YearDelta[(n-1):n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]
                                dataframe$Up3OnTotal.1YearDelta[(n-1):n] <- dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]
                                #dataframe$Up3OfTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-1]) / dataframe$Up3OfTotal[n-1]) * 100
                                #dataframe$Up3OnTotal.1YearROC[(n-1):n] <- ((dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-1]) / dataframe$Up3OnTotal[n-1]) * 100
                                dataframe$Up3OfTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfTotal[n-1], dataframe$Up3OfTotal[n], length(list.TotalOff), alpha = 0.5/length(list.TotalOff))
                                dataframe$Up3OnTotal.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnTotal[n-1], dataframe$Up3OnTotal[n], length(list.TotalOn), alpha = 0.5/length(list.TotalOn))
                                
                                dataframe$Up3OfBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-1]
                                dataframe$Up3OnBradySum.1YearDelta[(n-1):n] <- dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-1]
                                dataframe$Up3OfBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfBradySum[n-1], dataframe$Up3OfBradySum[n], length(list.BradykinesiaOff), alpha = 0.5/length(list.BradykinesiaOff))
                                dataframe$Up3OnBradySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnBradySum[n-1], dataframe$Up3OnBradySum[n], length(list.BradykinesiaOn), alpha = 0.5/length(list.BradykinesiaOn))
                                
                                dataframe$Up3OfRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-1]
                                dataframe$Up3OnRestTremAmpSum.1YearDelta[(n-1):n] <- dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-1]
                                dataframe$Up3OfRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRestTremAmpSum[n-1], dataframe$Up3OfRestTremAmpSum[n], length(list.RestTremorOff), alpha = 0.5/length(list.RestTremorOff))
                                dataframe$Up3OnRestTremAmpSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRestTremAmpSum[n-1], dataframe$Up3OnRestTremAmpSum[n], length(list.RestTremorOn), alpha = 0.5/length(list.RestTremorOn))
                                
                                dataframe$Up3OfCompositeTremorSum.1YearDelta[(n-1):n] <- dataframe$Up3OfCompositeTremorSum[n] - dataframe$Up3OfCompositeTremorSum[n-1]
                                dataframe$Up3OnCompositeTremorSum.1YearDelta[(n-1):n] <- dataframe$Up3OnCompositeTremorSum[n] - dataframe$Up3OnCompositeTremorSum[n-1]
                                dataframe$Up3OfCompositeTremorSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfCompositeTremorSum[n-1], dataframe$Up3OfCompositeTremorSum[n], length(list.CompositeTremorOff), alpha = 0.5/length(list.CompositeTremorOff))
                                dataframe$Up3OnCompositeTremorSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnCompositeTremorSum[n-1], dataframe$Up3OnCompositeTremorSum[n], length(list.CompositeTremorOn), alpha = 0.5/length(list.CompositeTremorOn))
                                
                                dataframe$Up3OfRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-1]
                                dataframe$Up3OnRigiditySum.1YearDelta[(n-1):n] <- dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-1]
                                dataframe$Up3OfRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfRigiditySum[n-1], dataframe$Up3OfRigiditySum[n], length(list.RigidityOff), alpha = 0.5/length(list.RigidityOff))
                                dataframe$Up3OnRigiditySum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnRigiditySum[n-1], dataframe$Up3OnRigiditySum[n], length(list.RigidityOn), alpha = 0.5/length(list.RigidityOn))
                                
                                dataframe$Up3OfPIGDSum.1YearDelta[(n-1):n] <- dataframe$Up3OfPIGDSum[n] - dataframe$Up3OfPIGDSum[n-1]
                                dataframe$Up3OnPIGDSum.1YearDelta[(n-1):n] <- dataframe$Up3OnPIGDSum[n] - dataframe$Up3OnPIGDSum[n-1]
                                dataframe$Up3OfPIGDSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OfPIGDSum[n-1], dataframe$Up3OfPIGDSum[n], length(list.PIGDOff), alpha = 0.5/length(list.PIGDOff))
                                dataframe$Up3OnPIGDSum.1YearROC[(n-1):n] <- elble.change(dataframe$Up3OnPIGDSum[n-1], dataframe$Up3OnPIGDSum[n], length(list.PIGDOn), alpha = 0.5/length(list.PIGDOn))
                                
                                dataframe$Up3OfPegRLBSum.1YearDelta[(n-1):n] = dataframe$Up3OfPegRLBSum[n] - dataframe$Up3OfPegRLBSum[n-1]
                                dataframe$Up3OnPegRLBSum.1YearDelta[(n-1):n] = dataframe$Up3OnPegRLBSum[n] - dataframe$Up3OnPegRLBSum[n-1]
                                dataframe$Up3OfPegRLBSum.1YearROC[(n-1):n] = elble.change(dataframe$Up3OfPegRLBSum[n-1], dataframe$Up3OfPegRLBSum[n], 1, alpha = 0.5/1)
                                dataframe$Up3OnPegRLBSum.1YearROC[(n-1):n] = elble.change(dataframe$Up3OnPegRLBSum[n-1], dataframe$Up3OnPegRLBSum[n], 1, alpha = 0.5/1)
                                
                                dataframe$STAITraitSum.1YearDelta[(n-1):n] <- dataframe$STAITraitSum[n] - dataframe$STAITraitSum[n-1]
                                dataframe$STAITraitSum.1YearROC[(n-1):n] <- elble.change(dataframe$STAITraitSum[n-1], dataframe$STAITraitSum[n], length(list.STAITrait), alpha = 0.5/length(list.STAITrait))
                                
                                dataframe$STAIStateSum.1YearDelta[(n-1):n] <- dataframe$STAIStateSum[n] - dataframe$STAIStateSum[n-1]
                                dataframe$STAIStateSum.1YearROC[(n-1):n] <- elble.change(dataframe$STAIStateSum[n-1], dataframe$STAIStateSum[n], length(list.STAIState), alpha = 0.5/length(list.STAIState))
                                
                                dataframe$QUIPicdSum.1YearDelta[(n-1):n] <- dataframe$QUIPicdSum[n] - dataframe$QUIPicdSum[n-1]
                                dataframe$QUIPicdSum.1YearROC[(n-1):n] <- elble.change(dataframe$QUIPicdSum[n-1], dataframe$QUIPicdSum[n], length(list.QUIP_icd), alpha = 0.5/length(list.QUIP_icd))
                                
                                dataframe$QUIPrsSum.1YearDelta[(n-1):n] <- dataframe$QUIPrsSum[n] - dataframe$QUIPrsSum[n-1]
                                dataframe$QUIPrsSum.1YearROC[(n-1):n] <- elble.change(dataframe$QUIPrsSum[n-1], dataframe$QUIPrsSum[n], length(list.QUIP_rs), alpha = 0.5/length(list.QUIP_rs))
                                
                                dataframe$AES12Sum.1YearDelta[(n-1):n] <- dataframe$AES12Sum[n] - dataframe$AES12Sum[n-1]
                                dataframe$AES12Sum.1YearROC[(n-1):n] <- elble.change(dataframe$AES12Sum[n-1], dataframe$AES12Sum[n], length(list.AES12), alpha = 0.5/length(list.AES12))
                                
                                dataframe$ApatSum.1YearDelta[(n-1):n] <- dataframe$Apat12Sum[n] - dataframe$Apat12Sum[n-1]
                                dataframe$ApatSum.1YearROC[(n-1):n] <- elble.change(dataframe$Apat12Sum[n-1], dataframe$Apat12Sum[n], length(list.Apat), alpha = 0.5/length(list.Apat))
                                
                                dataframe$BDI2Sum.1YearDelta[(n-1):n] <- dataframe$BDI2Sum[n] - dataframe$BDI2Sum[n-1]
                                dataframe$BDI2Sum.1YearROC[(n-1):n] <- elble.change(dataframe$BDI2Sum[n-1], dataframe$BDI2Sum[n], length(list.BDI2), alpha = 0.5/length(list.BDI2))
                                
                                dataframe$PDQ39_SingleIndex.1YearDelta[(n-1):n] <- dataframe$PDQ39_SingleIndex[n] - dataframe$PDQ39_SingleIndex[n-1]
                                dataframe$PDQ39_SingleIndex.1YearROC[(n-1):n] <- elble.change(dataframe$PDQ39_SingleIndex[n-1], dataframe$PDQ39_SingleIndex[n], length(list.PDQ39_singleindex), alpha = 0.5/length(list.PDQ39_singleindex))
                                
                                dataframe$TalkProbSum.1YearDelta[(n-1):n] <- dataframe$TalkProbSum[n] - dataframe$TalkProbSum[n-1]
                                dataframe$TalkProbSum.1YearROC[(n-1):n] <- elble.change(dataframe$TalkProbSum[n-1], dataframe$TalkProbSum[n], length(list.TalkProb), alpha = 0.5/length(list.TalkProb))
                                
                                dataframe$VisualProb23Sum.1YearDelta[(n-1):n] <- dataframe$VisualProb23Sum[n] - dataframe$VisualProb23Sum[n-1]
                                dataframe$VisualProb23Sum.1YearROC[(n-1):n] <- elble.change(dataframe$VisualProb23Sum[n-1], dataframe$VisualProb23Sum[n], length(list.VisualProb23), alpha = 0.5/length(list.VisualProb23))
                                
                                dataframe$VisualProb17Sum.1YearDelta[(n-1):n] <- dataframe$VisualProb17Sum[n] - dataframe$VisualProb17Sum[n-1]
                                dataframe$VisualProb17Sum.1YearROC[(n-1):n] <- elble.change(dataframe$VisualProb17Sum[n-1], dataframe$VisualProb17Sum[n], length(list.VisualProb17), alpha = 0.5/length(list.VisualProb17))
                                
                                dataframe$MultipleSessions[(n-1):n] = 1
                        }else if(dataframe$Timepoint[n] == 'ses-POMVisit3' && dataframe$Timepoint[n-2] == 'ses-POMVisit1'){
                                
                                dataframe$Up3OfTotal.2YearDelta[(n-2):n] <- dataframe$Up3OfTotal[n] - dataframe$Up3OfTotal[n-2]
                                dataframe$Up3OnTotal.2YearDelta[(n-2):n] <- dataframe$Up3OnTotal[n] - dataframe$Up3OnTotal[n-2]
                                dataframe$Up3OfTotal.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OfTotal[n-2], dataframe$Up3OfTotal[n], length(list.TotalOff), alpha = 0.5/length(list.TotalOff))
                                dataframe$Up3OnTotal.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OnTotal[n-2], dataframe$Up3OnTotal[n], length(list.TotalOn), alpha = 0.5/length(list.TotalOn))
                                
                                dataframe$Up3OfBradySum.2YearDelta[(n-2):n] <- dataframe$Up3OfBradySum[n] - dataframe$Up3OfBradySum[n-2]
                                dataframe$Up3OnBradySum.2YearDelta[(n-2):n] <- dataframe$Up3OnBradySum[n] - dataframe$Up3OnBradySum[n-2]
                                dataframe$Up3OfBradySum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OfBradySum[n-2], dataframe$Up3OfBradySum[n], length(list.BradykinesiaOff), alpha = 0.5/length(list.BradykinesiaOff))
                                dataframe$Up3OnBradySum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OnBradySum[n-2], dataframe$Up3OnBradySum[n], length(list.BradykinesiaOn), alpha = 0.5/length(list.BradykinesiaOn))
                                
                                dataframe$Up3OfRestTremAmpSum.2YearDelta[(n-2):n] <- dataframe$Up3OfRestTremAmpSum[n] - dataframe$Up3OfRestTremAmpSum[n-2]
                                dataframe$Up3OnRestTremAmpSum.2YearDelta[(n-2):n] <- dataframe$Up3OnRestTremAmpSum[n] - dataframe$Up3OnRestTremAmpSum[n-2]
                                dataframe$Up3OfRestTremAmpSum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OfRestTremAmpSum[n-2], dataframe$Up3OfRestTremAmpSum[n], length(list.RestTremorOff), alpha = 0.5/length(list.RestTremorOff))
                                dataframe$Up3OnRestTremAmpSum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OnRestTremAmpSum[n-2], dataframe$Up3OnRestTremAmpSum[n], length(list.RestTremorOn), alpha = 0.5/length(list.RestTremorOff))
                                
                                dataframe$Up3OfCompositeTremorSum.1YearDelta[(n-2):n] <- dataframe$Up3OfCompositeTremorSum[n] - dataframe$Up3OfCompositeTremorSum[n-2]
                                dataframe$Up3OnCompositeTremorSum.1YearDelta[(n-2):n] <- dataframe$Up3OnCompositeTremorAmpSum[n] - dataframe$Up3OnCompositeTremorSum[n-2]
                                dataframe$Up3OfCompositeTremorSum.1YearROC[(n-2):n] <- elble.change(dataframe$Up3OfCompositeTremorSum[n-2], dataframe$Up3OfCompositeTremorSum[n], length(list.CompositeTremorOff), alpha = 0.5/length(list.CompositeTremorOff))
                                dataframe$Up3OnCompositeTremorSum.1YearROC[(n-2):n] <- elble.change(dataframe$Up3OnCompositeTremorSum[n-2], dataframe$Up3OnCompositeTremorSum[n], length(list.CompositeTremorrOn), alpha = 0.5/length(list.CompositeTremorOn))
                                
                                
                                dataframe$Up3OfRigiditySum.2YearDelta[(n-2):n] <- dataframe$Up3OfRigiditySum[n] - dataframe$Up3OfRigiditySum[n-2]
                                dataframe$Up3OnRigiditySum.2YearDelta[(n-2):n] <- dataframe$Up3OnRigiditySum[n] - dataframe$Up3OnRigiditySum[n-2]
                                dataframe$Up3OfRigiditySum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OfRigiditySum[n-2], dataframe$Up3OfRigiditySum[n], length(list.RigidityOff), alpha = 0.5/length(list.RigidityOff))
                                dataframe$Up3OnRigiditySum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OnRigiditySum[n-2], dataframe$Up3OnRigiditySum[n], length(list.RigidityOn), alpha = 0.5/length(list.RigidityOn))
                                
                                dataframe$Up3OfPIGDSum.2YearDelta[(n-2):n] <- dataframe$Up3OfPIGDSum[n] - dataframe$Up3OfPIGDSum[n-2]
                                dataframe$Up3OnPIGDSum.2YearDelta[(n-2):n] <- dataframe$Up3OnPIGDSum[n] - dataframe$Up3OnPIGDSum[n-2]
                                dataframe$Up3OfPIGDSum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OfPIGDSum[n-2], dataframe$Up3OfPIGDSum[n], length(list.PIGDOff), alpha = 0.5/length(list.PIGDOff))
                                dataframe$Up3OnPIGDSum.2YearROC[(n-2):n] <- elble.change(dataframe$Up3OnPIGDSum[n-2], dataframe$Up3OnPIGDSum[n], length(list.PIGDOn), alpha = 0.5/length(list.PIGDOn))
                                
                                dataframe$Up3OfPegRLBSum.2YearDelta[(n-2):n] = dataframe$Up3OfPegRLBSum[n] - dataframe$Up3OfPegRLBSum[n-2]
                                dataframe$Up3OnPegRLBSum.2YearDelta[(n-2):n] = dataframe$Up3OnPegRLBSum[n] - dataframe$Up3OnPegRLBSum[n-2]
                                dataframe$Up3OfPegRLBSum.2YearROC[(n-2):n] = elble.change(dataframe$Up3OfPegRLBSum[n-2], dataframe$Up3OfPegRLBSum[n], 1, alpha = 0.5/1)
                                dataframe$Up3OnPegRLBSum.2YearROC[(n-2):n] = elble.change(dataframe$Up3OnPegRLBSum[n-2], dataframe$Up3OnPegRLBSum[n], 1, alpha = 0.5/1)
                                
                                dataframe$STAITraitSum.2YearDelta[(n-2):n] <- dataframe$STAITraitSum[n] - dataframe$STAITraitSum[n-2]
                                dataframe$STAITraitSum.2YearROC[(n-2):n] <- elble.change(dataframe$STAITraitSum[n-2], dataframe$STAITraitSum[n], length(list.STAITrait), alpha = 0.5/length(list.STAITrait))
                                
                                dataframe$STAIStateSum.2YearDelta[(n-2):n] <- dataframe$STAIStateSum[n] - dataframe$STAIStateSum[n-2]
                                dataframe$STAIStateSum.2YearROC[(n-2):n] <- elble.change(dataframe$STAIStateSum[n-2], dataframe$STAIStateSum[n], length(list.STAIState), alpha = 0.5/length(list.STAIState))
                                
                                dataframe$QUIPicdSum.2YearDelta[(n-2):n] <- dataframe$QUIPicdSum[n] - dataframe$QUIPicdSum[n-2]
                                dataframe$QUIPicdSum.2YearROC[(n-2):n] <- elble.change(dataframe$QUIPicdSum[n-2], dataframe$QUIPicdSum[n], length(list.QUIPicd), alpha = 0.5/length(list.QUIPicd))
                                
                                dataframe$QUIPrsSum.2YearDelta[(n-2):n] <- dataframe$QUIPrsSum[n] - dataframe$QUIPrsSum[n-2]
                                dataframe$QUIPrsSum.2YearROC[(n-2):n] <- elble.change(dataframe$QUIPrsSum[n-2], dataframe$QUIPrsSum[n], length(list.QUIPrs), alpha = 0.5/length(list.QUIPrs))
                                
                                dataframe$AES12Sum.2YearDelta[(n-2):n] <- dataframe$AES12Sum[n] - dataframe$AES12Sum[n-2]
                                dataframe$AES12Sum.2YearROC[(n-2):n] <- elble.change(dataframe$AES12Sum[n-2], dataframe$AES12Sum[n], length(list.AES12), alpha = 0.5/length(list.AES12))
                                
                                dataframe$BDI2Sum.2YearDelta[(n-2):n] <- dataframe$BDI2Sum[n] - dataframe$BDI2Sum[n-2]
                                dataframe$BDI2Sum.2YearROC[(n-2):n] <- elble.change(dataframe$BDI2Sum[n-2], dataframe$BDI2Sum[n], length(list.BDI2), alpha = 0.5/length(list.BDI2))
                                
                                dataframe$PDQ39_SingleIndex.2YearDelta[(n-2):n] <- dataframe$PDQ39_SingleIndex[n] - dataframe$PDQ39_SingleIndex[n-2]
                                dataframe$PDQ39_SingleIndex.2YearROC[(n-2):n] <- elble.change(dataframe$PDQ39_SingleIndex[n-2], dataframe$PDQ39_SingleIndex[n], length(list.PDQ39_singleindex), alpha = 0.5/length(list.PDQ39_singleindex))
                                
                                dataframe$TalkProbSum.2YearDelta[(n-2):n] <- dataframe$TalkProbSum[n] - dataframe$TalkProbSum[n-2]
                                dataframe$TalkProbSum.2YearROC[(n-2):n] <- elble.change(dataframe$TalkProbSum[n-2], dataframe$TalkProbSum[n], length(list.TalkProb), alpha = 0.5/length(list.TalkProb))
                                
                                dataframe$VisualProb23Sum.2YearDelta[(n-2):n] <- dataframe$VisualProb23Sum[n] - dataframe$VisualProb23Sum[n-2]
                                dataframe$VisualProb23Sum.2YearROC[(n-2):n] <- elble.change(dataframe$VisualProb23Sum[n-2], dataframe$VisualProb23Sum[n], length(list.VisualProb23), alpha = 0.5/length(list.VisualProb23))
                                
                                dataframe$VisualProb17Sum.2YearDelta[(n-2):n] <- dataframe$VisualProb17Sum[n] - dataframe$VisualProb17Sum[n-2]
                                dataframe$VisualProb17Sum.2YearROC[(n-2):n] <- elble.change(dataframe$VisualProb17Sum[n-2], dataframe$VisualProb17Sum[n], length(list.VisualProb17), alpha = 0.5/length(list.VisualProb17))
                                
                                dataframe$MultipleSessions[(n-2):n] = 1
                        }
                }
                dataframe$MultipleSessions <- as.factor(dataframe$MultipleSessions)
                levels(dataframe$MultipleSessions) <- c('No','Yes')
                return(dataframe)
                
        }
        df6 <- CalculateDiseaseProgression(df5)
        
        # Rearrange variables
        df7 <- df6 %>%
                relocate(pseudonym, Timepoint, Gender, Age, EstDisDurYears, TimeToFUYears, MultipleSessions,
                         Up3OfTotal, Up3OfTotal.1YearDelta, Up3OfTotal.1YearROC, Up3OfTotal.2YearDelta, Up3OfTotal.2YearROC,
                         Up3OnTotal, Up3OnTotal.1YearDelta, Up3OnTotal.1YearROC, Up3OnTotal.2YearDelta, Up3OnTotal.2YearROC,
                         Up3OfBradySum, Up3OfBradySum.1YearDelta, Up3OfBradySum.1YearROC, Up3OfBradySum.2YearDelta, Up3OfBradySum.2YearROC,
                         Up3OnBradySum, Up3OnBradySum.1YearDelta, Up3OnBradySum.1YearROC, Up3OnBradySum.2YearDelta, Up3OnBradySum.2YearROC, 
                         Up3OfRestTremAmpSum, Up3OfRestTremAmpSum.1YearDelta, Up3OfRestTremAmpSum.1YearROC, Up3OfRestTremAmpSum.2YearDelta, Up3OfRestTremAmpSum.2YearROC,
                         Up3OnRestTremAmpSum, Up3OnRestTremAmpSum.1YearDelta, Up3OnRestTremAmpSum.1YearROC, Up3OnRestTremAmpSum.2YearDelta, Up3OnRestTremAmpSum.2YearROC,
                         Up3OfRigiditySum, Up3OfRigiditySum.1YearDelta, Up3OfRigiditySum.1YearROC, Up3OfRigiditySum.2YearDelta, Up3OfRigiditySum.2YearROC,
                         Up3OnRigiditySum, Up3OnRigiditySum.1YearDelta, Up3OnRigiditySum.1YearROC, Up3OnRigiditySum.2YearDelta, Up3OnRigiditySum.2YearROC,
                         Up3OfPIGDSum, Up3OfPIGDSum.1YearDelta, Up3OfPIGDSum.1YearROC, Up3OfPIGDSum.2YearDelta, Up3OfPIGDSum.2YearROC,
                         Up3OnPIGDSum, Up3OnPIGDSum.1YearDelta, Up3OnPIGDSum.1YearROC, Up3OnPIGDSum.2YearDelta, Up3OnPIGDSum.2YearROC,
                         Up3OfPegRLBSum, Up3OfPegRLBSum.1YearDelta, Up3OfPegRLBSum.1YearROC, Up3OfPegRLBSum.2YearDelta, Up3OfPegRLBSum.2YearROC,
                         Up3OnPegRLBSum, Up3OnPegRLBSum.1YearDelta, Up3OnPegRLBSum.1YearROC, Up3OnPegRLBSum.2YearDelta, Up3OnPegRLBSum.2YearROC,
                         STAITraitSum, STAITraitSum.1YearDelta, STAITraitSum.1YearROC, STAITraitSum.2YearDelta, STAITraitSum.2YearROC,
                         STAIStateSum, STAIStateSum.1YearDelta, STAIStateSum.1YearROC, STAIStateSum.2YearDelta, STAIStateSum.2YearROC,
                         QUIPicdSum, QUIPicdSum.1YearDelta, QUIPicdSum.1YearROC, QUIPicdSum.2YearDelta, QUIPicdSum.2YearROC,
                         QUIPrsSum, QUIPrsSum.1YearDelta, QUIPrsSum.1YearROC, QUIPrsSum.2YearDelta, QUIPrsSum.2YearROC,
                         AES12Sum, AES12Sum.1YearDelta, AES12Sum.1YearROC, AES12Sum.2YearDelta, AES12Sum.2YearROC,
                         BDI2Sum, BDI2Sum.1YearDelta, BDI2Sum.1YearROC, BDI2Sum.2YearDelta, BDI2Sum.2YearROC,
                         PDQ39_SingleIndex, PDQ39_SingleIndex.1YearDelta, PDQ39_SingleIndex.1YearROC, PDQ39_SingleIndex.2YearDelta, PDQ39_SingleIndex.2YearROC,
                         TalkProbSum, TalkProbSum.1YearDelta, TalkProbSum.1YearROC, TalkProbSum.2YearDelta, TalkProbSum.2YearROC,
                         VisualProb23Sum, VisualProb23Sum.1YearDelta, VisualProb23Sum.1YearROC, VisualProb23Sum.2YearDelta, VisualProb23Sum.2YearROC,
                         VisualProb17Sum, VisualProb17Sum.1YearDelta, VisualProb17Sum.1YearROC, VisualProb17Sum.2YearDelta, VisualProb17Sum.2YearROC)
        
        # Define the task that was used
        
        
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
        
        outputfile <- paste(bidsdir, 'derivatives/database_clinical_variables_', today(),  '.csv', sep = '')
        if(!dir.exists(dirname(outputfile))){
                dir.create(dirname(outputfile))
        }
        if(file.exists(outputfile)){
                file.remove(outputfile)
        }
        write_csv(df7, outputfile)
        
        #####        
        
}










