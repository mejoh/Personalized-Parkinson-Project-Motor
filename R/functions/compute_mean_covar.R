compute_mean_covar <- function(Subj, Visit, dAna='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem', measure='framewise_displacement'){
  
  library(R.matlab)
  
  # Subj <- 'sub-POMUFEFFE5FD3BE56D30'
  # Visit <- 'ses-PITVisit1'
  # dAna <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem'
  # measure <- 'framewise_displacement'
  
  ptn <- '_desc-confounds_timeseries.*.mat'
  d1st <- file.path(dAna, Subj, Visit)
  confs <- dir(d1st, pattern=ptn, full.names = TRUE)
  confs <- confs[length(confs)]
  confs <- readMat(confs)
  
  varnames <- confs$names %>% unlist()
  idx <- which(varnames == measure)
  ts <- confs$R[,idx]
  avg <- mean(ts, na.rm = TRUE)
  
  avg
  
}
