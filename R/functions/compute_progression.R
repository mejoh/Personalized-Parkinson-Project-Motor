compute_progression <- function(df, var, nritems, alpha = 0.5){
  
        stopifnot(var %in% colnames(df))
        var <- 'Up3OfTotal'
        
        var.1year.raw <- paste(var, '.1YearDelta', sep='')
        # var.1year.elble <- paste(var, '.1YearROC', sep='')
        var.2year.raw <- paste(var, '.2YearDelta', sep='')
        # var.2year.elble <- paste(var, '.2YearROC', sep='')
        var.Consecutive.raw <- paste(var, '.ConsecutiveDelta', sep='')
  
  # df1 <- df %>%
  #   mutate('{var.1year.raw}' := as.double(NA),
  #          '{var.1year.elble}' := as.double(NA),
  #          '{var.2year.raw}' := as.double(NA),
  #          '{var.2year.elble}' := as.double(NA),
  #          MultipleSessions = NA)
  df1 <- df %>%
          mutate('{var.1year.raw}' := as.double(NA),
                 '{var.2year.raw}' := as.double(NA),
                 '{var.Consecutive.raw}' := as.double(NA),
                 MultipleSessions = NA)
  
  for(n in 1:nrow(df1)){
          if(str_detect(df1$Timepoint[n], 'Visit2') && str_detect(df1$Timepoint[n-1], 'Visit1')){
                  df1[var.1year.raw][(n-1):n,1] <- df1[var][n,1] - df1[var][n-1,1]
                  # df1[var.1year.elble][(n-1):n,1] <- elble_change(df1[var][n-1,1], df1[var][n,1], nritems, alpha = 0.5/nritems, TRUE)
                  df1$MultipleSessions[(n-1):n] <- TRUE
          }else if(str_detect(df1$Timepoint[n], 'Visit3') && str_detect(df1$Timepoint[n-2], 'Visit1')){
                  df1[var.2year.raw][(n-2):n,1] <- df1[var][n,1] - df1[var][n-2,1]
                  # df1[var.2year.elble][(n-2):n,1] <- elble_change(df1[var][n-2,1], df1[var][n,1], nritems, alpha = 0.5/nritems, TRUE)
                  df1$MultipleSessions[(n-2):n] <- TRUE
          }else{
                  df1$MultipleSessions[n] <- FALSE
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

