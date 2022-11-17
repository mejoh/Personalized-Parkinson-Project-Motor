library(tidyverse)
library(readxl)
fCastor <- 'P:/3022026.01/documents/PIT_Reports_production_AgeGenderPType.xlsx'
dCastor <- read_excel(fCastor)
df <- dCastor %>%
        select(Gender_1, Age_1, ParticipantType_1) %>%
        mutate(Gender_1 = if_else(Gender_1 == 1, 'M', 'F'),
               ParticipantType_1 = if_else(ParticipantType_1 == 1, 'Patient', 'Control'),
               Age_1 = as.numeric(Age_1))
df <- df[complete.cases(df), ]
df %>%
        group_by(ParticipantType_1) %>%
        summarise(Avg.Age = mean(Age_1), SD.Age = sd(Age_1), n = n())
df %>%
        select(ParticipantType_1, Gender_1) %>%
        table
