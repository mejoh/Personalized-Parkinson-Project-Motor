## Function for generating data frame

ClinicalVarsGenerateDataFrame <- function(rerun = FALSE){

##### Generate data frame ####

if(rerun == TRUE){
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsDatabase.R')
df_v1 <- ClinicalVarsDatabase('Castor.Visit1')
df_v2 <- ClinicalVarsDatabase('Castor.Visit2')
save.image("M:/scripts/Personalized-Parkinson-Project-Motor/R/visit1_visit2_environment3.RData")
}else{
load("M:/scripts/Personalized-Parkinson-Project-Motor/R/visit1_visit2_environment3.RData")
}
#####

##### Preprocess data frame #####
# Sort data frame
library(tidyverse)
df2_v1 <- df_v1 %>%
        arrange(pseudonym, timepoint)

df2_v2 <- df_v2 %>%
        arrange(pseudonym, timepoint)

# Merge data frames
df2 <- full_join(df2_v1, df2_v2) %>%
        arrange(pseudonym, timepoint)

# Select vars and generate additional ones
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsPreprocessing.R')
df2 <- ClinicalVarsPreprocessing(df2)

print(df2)

}