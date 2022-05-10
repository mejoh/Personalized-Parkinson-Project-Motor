detect_xstudy_participation <- function(df){
  
  POM <- df %>% filter(Timepoint=='ses-POMVisit1') %>% select(pseudonym) %>% unique()
  PIT <- df %>% filter(Timepoint=='ses-PITVisit1') %>% filter(ParticipantType=='PD_PIT') %>% select(pseudonym) %>% unique()
  
  All_subs <- c(POM$pseudonym, PIT$pseudonym)
  All_subs_duplicates <- All_subs[duplicated(All_subs)]
  
  df1 <- df %>%
    mutate(CrossStudyParticipation = FALSE)
  
  for(t in 1:nrow(df1)){
    s <- df1$pseudonym[t]
    if(sum(str_count(All_subs_duplicates, s))>0){
      df1$CrossStudyParticipation[t] <- TRUE
    }else{
      df1$CrossStudyParticipation[t] <- FALSE
    }
  }
  
  df1
  
}