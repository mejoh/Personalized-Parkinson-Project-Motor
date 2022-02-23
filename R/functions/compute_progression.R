compute_progression <- function(df, var, alpha = 0.5){
        
        cat('\n', 'Computing progression for', var, '\n')
        stopifnot('Progression cannot be computed, please review varlist.' = var %in% colnames(df))
        #var <- 'Up3OfTotal'
        
        var.1year.raw <- paste(var, '.1YearDelta', sep='')
        var.1year.elble <- paste(var, '.1YearElble', sep='')
        var.1year.log <- paste(var, '.1YearLogDelta', sep='')
        var.2year.raw <- paste(var, '.2YearDelta', sep='')
        var.2year.elble <- paste(var, '.2YearElble', sep='')
        var.2year.log <- paste(var, '.2YearLogDelta', sep='')
        var.Consecutive.raw <- paste(var, '.ConsecutiveDelta', sep='')
        var.Consecutive.log <- paste(var, '.ConsecutiveLogDelta', sep='')
        var.Consecutive.elble <- paste(var, '.ConsecutiveElble', sep='')
        
        df1 <- df %>%
                mutate('{var.1year.raw}' := as.double(NA),
                       '{var.2year.raw}' := as.double(NA),
                       '{var.Consecutive.raw}' := as.double(NA),
                       '{var.1year.log}' := as.double(NA),
                       '{var.2year.log}' := as.double(NA),
                       '{var.Consecutive.log}' := as.double(NA),
                       '{var.1year.elble}' := as.double(NA),
                       '{var.2year.elble}' := as.double(NA),
                       '{var.Consecutive.elble}' := as.double(NA),
                       MultipleSessions = NA)
        
        for(n in 1:nrow(df1)){
                if(str_detect(df1$Timepoint[n], 'Visit2') && str_detect(df1$Timepoint[n-1], 'Visit1')){
                        t1 <- df1[var][n,1]
                        t0 <- df1[var][n-1,1]
                        df1[var.1year.raw][(n-1):n,1] <- t1 - t0
                        df1[var.1year.log][(n-1):n,1] <- log(t1) - log(t0)    # Relative changes appear as absolute changes on the log scale
                        df1$MultipleSessions[(n-1):n] <- TRUE
                }else if(str_detect(df1$Timepoint[n], 'Visit3') && str_detect(df1$Timepoint[n-2], 'Visit1')){
                        t1 <- df1[var][n,1]
                        t0 <- df1[var][n-2,1]
                        df1[var.2year.raw][(n-2):n,1] <- t1 - t0
                        df1[var.2year.log][(n-2):n,1] <- log(t1) - log(t0)
                        df1$MultipleSessions[(n-2):n] <- TRUE
                }else{
                        df1$MultipleSessions[n] <- FALSE
                }
        }
        
        var.nritems <- paste(var,'.NrItems',sep='')
        if(var.nritems %in% colnames(df)){
                for(n in 1:nrow(df1)){
                        nritems <- df1[var.nritems][n,]
                        if(str_detect(df1$Timepoint[n], 'Visit2') && str_detect(df1$Timepoint[n-1], 'Visit1')){
                                t1 <- df1[var][n,1]
                                t0 <- df1[var][n-1,1]
                                df1[var.1year.elble][(n-1):n,1] <- elble_change(t0, t1, nritems, alpha = 0.5/nritems, TRUE)
                        }else if(str_detect(df1$Timepoint[n], 'Visit3') && str_detect(df1$Timepoint[n-2], 'Visit1')){
                                t1 <- df1[var][n,1]
                                t0 <- df1[var][n-2,1]
                                df1[var.2year.elble][(n-2):n,1] <- elble_change(t0, t1, nritems, alpha = 0.5/nritems, TRUE)
                        }
                }       
        }
        
        
        for(n in 1:nrow(df1)){
                if(str_detect(df1$Timepoint[n], 'Visit1')){
                        df1[var.Consecutive.raw][n,1] <- 0  
                }else if(str_detect(df1$Timepoint[n], 'Visit2') && str_detect(df1$Timepoint[n-1], 'Visit1')){
                        df1[var.Consecutive.raw][n,1] <- df1[var][n,1] - df1[var][n-1,1]
                }else if(str_detect(df1$Timepoint[n], 'Visit3') && str_detect(df1$Timepoint[n-1], 'Visit2')){
                        df1[var.Consecutive.raw][n,1] <- df1[var][n,1] - df1[var][n-1,1]
                }
        }
        
        df1
        
}

