library(tidyverse)

cols <- c('pseudonym','ParticipantType','TimepointNr','Age','Gender','NpsEducation','NpsEducYears',
          'MoCASum','NpsMocPhoFlu','NpsMis15wRigTot','NpsMis15WrdDelRec','NpsMis15WrdRecognition',
          'NpsMisBrixton','NpsMisSemFlu','NpsMisModa90','NpsMisWaisRude','NpsMisBenton')
dfClin <- read_csv('P:/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2023-09-18.csv',
                   col_select = all_of(cols))

dfClin.s <- dfClin %>%
    filter(ParticipantType=='PD_POM') %>%
    mutate(Gender = if_else(Gender=='Male',0,1),
           MoCASum = if_else(NpsEducYears<=12, MoCASum-1,MoCASum))

Age <- dfClin.s %>%
    filter(TimepointNr == 0) %>%
    select(pseudonym,Age)
dfClin.s <- dfClin.s %>%
    select(-Age) %>%
    left_join(., Age, by = 'pseudonym') %>%
    relocate(pseudonym,ParticipantType,TimepointNr,Age) %>%
    mutate(Age = Age+TimepointNr)

# ANDI: MoCASum, NpsMocPhoFlu, NpsMis15..., NpsMisBrixton, NpsMisSemFlu
# Format: Row=Variable, Col=Subject. Each col separated by an 'Opmerkingen #' field.
df.andi <- dfClin.s %>%
    select(pseudonym,TimepointNr,Age,Gender,NpsEducation,
           NpsMis15wRigTot,NpsMis15WrdDelRec,NpsMis15WrdRecognition,NpsMisSemFlu,
           NpsMocPhoFlu,NpsMisBrixton,MoCASum)

reformat2andi <- function(df){
    
    s <- nrow(df)
    cn <- colnames(df)
    dat <- tibble('Waarde'=cn)
    
    for(n in 1:s){
        
        s_dat <- tibble(pid = rep(NA,length(cn)),
                        oid = rep('',length(cn)))
        colnames(s_dat) <- c(paste0('Patient_',n),paste0('Opmerking_',n))
        
        for(r in 1:nrow(s_dat)){
            s_dat[r,1] <- df[n,] %>% select(cn[r]) %>% as.character()
        }
        
        dat <- bind_cols(dat, s_dat)
    }
    
    dat
    
}

df.andi.T0 <- df.andi %>% filter(TimepointNr==0) %>% select(-TimepointNr) %>% reformat2andi()     
df.andi.T1 <- df.andi %>% filter(TimepointNr==1) %>% select(-TimepointNr) %>% reformat2andi() 
df.andi.T2 <- df.andi %>% filter(TimepointNr==2) %>% select(-TimepointNr) %>% reformat2andi()  
df.andi.Tall <- bind_rows(df.andi.T0,df.andi.T1,df.andi.T2)
write_csv(df.andi.T0,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/andi_T0.csv')
write_csv(df.andi.T1,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/andi_T1.csv')
write_csv(df.andi.T2,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/andi_T2.csv')
write_csv(df.andi.Tall,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/andi_Tall.csv')

# NON-ANDI: NpsMisModa90, NpsMisWaisRude, NpsMisBenton
# Format: Row=Subject, Col=Variable
df.nandi <- dfClin.s %>%
    select(pseudonym,TimepointNr,Age,Gender,NpsEducation,
           NpsMisModa90,NpsMisWaisRude,NpsMisBenton)
df.nandi.T0 <- df.nandi %>% filter(TimepointNr==0)  
df.nandi.T1 <- df.nandi %>% filter(TimepointNr==1)     
df.nandi.T2 <- df.nandi %>% filter(TimepointNr==2)    
df.nandi.Tall <- bind_rows(df.nandi.T0,df.nandi.T1,df.nandi.T2)
write_csv(df.nandi.T0,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/not_andi_T0.csv')
write_csv(df.nandi.T1,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/not_andi_T1.csv')
write_csv(df.nandi.T2,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/not_andi_T2.csv')
write_csv(df.nandi.Tall,'P:/3024006.02/Data/Subtyping/Adjusted_Neuropsych_Scores/AllVisits/not_andi_Tall.csv')
