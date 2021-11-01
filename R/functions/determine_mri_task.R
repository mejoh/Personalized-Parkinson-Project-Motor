determine_mri_task <- function(df, mribidsdir){
  
  df <- df %>%
    mutate(MriNeuroPsychTask = NA,
           MriRespHand = NA)
  
  for(i in 1:nrow(df)){
    sub <- df$pseudonym[i]
    ses <- df$Timepoint[i]
    behfiles <- dir(paste(mribidsdir, sub, ses, 'beh', sep='/'), '.*', full.names = TRUE)
    
    if(sum(str_detect(behfiles, 'task-motor_acq-MB6'))>0){
      df$MriNeuroPsychTask[i] <- 'Motor'
      taskfile <- behfiles[str_detect(behfiles, '.*task-motor_acq-MB6.*.json')]
      taskfile <- taskfile[length(taskfile)] # Ensure last run is taken
      json <- read_json(taskfile)
      df$MriRespHand[i] <- json$RespondingHand$Value
    }else if(sum(str_detect(behfiles, 'task-reward_acq-ME'))>0){
      df$MriNeuroPsychTask[i] <- 'Reward'
    }else{
      df$MriNeuroPsychTask[i] <- NA
    }
    
  }
  
  df
  
}