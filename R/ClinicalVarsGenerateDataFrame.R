## Wrapper script for ClinicalVarsDatabse and ClinicalVarsPreprocessing

ClinicalVarsGenerateDataFrame <- function(rerun = FALSE){

##### Generate data frame ####

if(rerun == TRUE){
source('M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinicalVarsDatabase.R')
df_v1 <- ClinicalVarsDatabase('ses-Visit1')
df_v2 <- ClinicalVarsDatabase('ses-Visit2')
save(df_v1, df_v2, file = "M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinVars.RData")
}else{
load("M:/scripts/Personalized-Parkinson-Project-Motor/R/ClinVars.RData")
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

# Subset by task
#df2 <- df2 %>%
#        filter(MriNeuroPsychTask == 'Motor')

#####

# Export data
#pth <- "P:/3022026.01/analyses/nina/"
#fname <- paste(pth, "CastorData2.csv", sep = '')
#write_csv(df2, fname)

print(df2)

}