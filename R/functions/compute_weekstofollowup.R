compute_weekstofollowup <- function(df){
  
  df1 <- df %>%
    mutate(WeeksToFollowUp = NA) %>%
    arrange(pseudonym, Timepoint)
  
  # for(n in 1:nrow(df1)){
  #   if(df1$Timepoint[n] =='ses-POMVisit1'){
  #     df1$WeeksToFollowUp[n] = 0
  #   }else if(df1$Timepoint[n] =='ses-POMVisit2' & !is.na(df1$WeeksSinceVisit1[n])){
  #     df1$WeeksToFollowUp[n] = df1$WeeksSinceVisit1[n]
  #   }else if(df1$Timepoint[n] =='ses-POMVisit3' & !is.na(df1$WeeksSinceVisit1[n]) & !is.na(df1$WeeksSinceVisit2[n])){
  #     df1$WeeksToFollowUp[n] = df1$WeeksSinceVisit1[n] + df1$WeeksSinceVisit2[n]
  #   }else if(df1$Timepoint[n] =='ses-PITVisit1'){
  #     df1$WeeksToFollowUp[n] = 0
  #   }else if(df1$Timepoint[n] =='ses-PITVisit2'){
  #     if(df1$Timepoint[n-1] =='ses-PITVisit1'){
  #       df1$WeeksToFollowUp[n] <- round(as.integer(dmy_hm(df1$StartSession[n]) - dmy_hm(df1$StartSession[n-1])) / 7)    
  #     }
  #   }else{
  #     df1$WeeksToFollowUp[n] = NA
  #   }
  # }
  
  for(n in 1:nrow(df1)){
          if(df1$Timepoint[n] =='ses-POMVisit1'){
                  df1$WeeksToFollowUp[n] = 0
          }else if(df1$Timepoint[n] =='ses-POMVisit2' & !is.na(df1$WeeksSinceLastVisit[n])){
                  df1$WeeksToFollowUp[n] = 0 + df1$WeeksSinceLastVisit[n]
          }else if(df1$Timepoint[n] =='ses-POMVisit3' & df1$Timepoint[n-1] =='ses-POMVisit2' & !is.na(df1$WeeksSinceLastVisit[n-1]) & !is.na(df1$WeeksSinceLastVisit[n])){
                  df1$WeeksToFollowUp[n] = 0 + df1$WeeksSinceLastVisit[n-1] + df1$WeeksSinceLastVisit[n]
          }else if(df1$Timepoint[n] =='ses-POMVisit3' & df1$Timepoint[n-1] =='ses-POMVisit1' & !is.na(df1$WeeksSinceLastVisit[n])){
                  df1$WeeksToFollowUp[n] = 0 + df1$WeeksSinceLastVisit[n]
          }else if(df1$Timepoint[n] =='ses-PITVisit1'){
                  df1$WeeksToFollowUp[n] = 0
          }else if(df1$Timepoint[n] =='ses-PITVisit2'){
                  if(df1$Timepoint[n-1] =='ses-PITVisit1'){
                          df1$WeeksToFollowUp[n] <- round(as.integer(dmy_hm(df1$StartSession[n]) - dmy_hm(df1$StartSession[n-1])) / 7)    
                  }
          }else{
                  df1$WeeksToFollowUp[n] = NA
          }
  }
  
  df1
  
}
