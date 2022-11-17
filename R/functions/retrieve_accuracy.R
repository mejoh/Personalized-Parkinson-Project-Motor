retrieve_accuracy <- function(Subj, Visit, dAna='P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem', threshold=0.33){
  
  library(R.matlab)
  
  # Subj <- 'sub-POMUFEFFE5FD3BE56D30'
  # Visit <- 'ses-PITVisit1'
  # dAna <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem'
  
  ptn <- '.*_events.mat'
  d1st <- file.path(dAna, Subj, Visit)
  events <- dir(d1st, pattern=ptn, full.names = TRUE)
  events <- events[length(events)]
  events <- readMat(events)
  
  correct_ext <- events$onsets[[2]][[1]] %>% length()
  perc <- (correct_ext / 60)*100
  
  perc
  
}