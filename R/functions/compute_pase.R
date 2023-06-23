# Calculate a score for the Physical Activity Scale for the Elderly
# questionnaire.

# -
# Items
# -
# Original item order               # Corresponding items in Castor
# 02 Walk outside home			           PaseVr02
# 03 Light sport				                PaseVr04 (03b is 04a)
# 04 Moderate sport			              PaseVr05
# 05 Strenuous sport			             PaseVr06
# 06 Muscle strenght			             PaseVr07
# 07 Light housework			             PaseVr08
# 08 Heavy housework			             PaseVr09
# 09a Home repairs			               PaseVr10a
# 09b Lawn work				                 PaseVr10b
# 09c Outdoor gardening			          PaseVr10c
# 09d Caring for another person		   PaseVr10d
# 10 Work for pay or as volunteer		 PaseVr11

# -
# Original PASE score calculation
# -
# RECODE Q2, Q3, Q4, Q5, Q6 (0=0)(1 =1.5)(2=3.5)(3=6)(ELSE = -1) 
# RECODE Q2A, Q3B, Q4B, Q5B, Q6B (1=.5)(2=1.5)(3=3)(4=5) 
# COMPUTE Q2 = Q2 * Q2A/7. 
# COMPUTE Q3 = Q3 * Q3B/7. 
# COMPUTE Q4 = Q4 * Q4B/7. 
# COMPUTE Q5 = Q5 * Q5B/7. 
# COMPUTE Q6 = Q6 * Q6B/7. 
# RECODE Q7, Q8, Q9A, Q9B, Q9C, Q9D (1=0)(2=1)(ELSE = -1) 
# RECODE Q10 (1=0) IF (Q10B = 1) Q10 = 0. IF (Q10B ≥ 2) Q10 = Q10A/7. 
# COMPUTE PASE = 20*Q2 + 21 *Q3 + 23*(Q4 + Q5) + 30*Q6 +  25*(Q7 + Q8) + 30*Q9A + 36*Q9B + 20*Q9C + 35*Q9D + 21*Q10. 

# -
# Adapted PASE score calculation
# -
# RECODE Q2, Q4, Q5, Q6, Q7 (0=0)(1 =1.5)(2=3.5)(3=6)(ELSE = -1) 
# RECODE Q2A, Q4A, Q5B, Q6B, Q7B (1=.5)(2=1.5)(3=3)(4=5) 
# COMPUTE Q2 = Q2 * Q2A/7. 
# COMPUTE Q4 = Q4 * Q4B/7. 
# COMPUTE Q5 = Q5 * Q5A/7. 
# COMPUTE Q6 = Q6 * Q6B/7. 
# COMPUTE Q7 = Q7 * Q7B/7. 
# RECODE Q8, Q9, Q10A, Q10B, Q10C, Q10D (2=0)(1=1)(ELSE = -1)   # Response options were reversed in Castor
# RECODE Q11 (2=0) IF (Q11B = 0) Q11 = 0. IF (Q11B ≥ 1) Q11 = Q11A/7. # Response options for 11 were reversed in Castor. 11b ranges from 0-3 rather than original 1-4
# COMPUTE PASE = 20*Q2 + 21 *Q4 + 23*(Q5 + Q6) + 30*Q7 +  25*(Q8 + Q9) + 30*Q10A + 36*Q10B + 20*Q10C + 35*Q10D + 21*Q11. 

compute_pase <- function(df){
 
 library(tidyverse)
 
 # For debugging:
 # selection <- c("pseudonym", "ParticipantType", "TimepointNr", "Age", "Gender", "PaseVr01", "PaseVr02", "PaseVr02a", "PaseVr02b", "PaseVr03", "PaseVr04", 
 #                "PaseVr04a", "PaseVr05", "PaseVr05a", "PaseVr05b", "PaseVr06", "PaseVr06a", "PaseVr06b",
 #                "PaseVr07", "PaseVr07a", "PaseVr07b", "PaseVr08", "PaseVr09", "PaseVr10a", "PaseVr10b",
 #                "PaseVr10c", "PaseVr10d", "PaseVr11", "PaseVr11a", "PaseVr11b")
 # dfClin.ss <- dfClin %>%
 #  filter(ParticipantType=='PD_POM') %>%
 #  select(all_of(selection))
 
 recode1 <- function(input){
  # Response options:
  # 0 = Never
  # 1 = Seldom
  # 2 = Sometimes
  # 3 = Often
  case_match(input,
             0 ~ 0,
             1 ~ 1.5, 
             2 ~ 3.5, 
             3 ~ 6)
 }
 recode2 <- function(input){
  # Response options:
  # 0 = x < 1 h
  # 1 = x > 1 & < 2 h
  # 2 = x > 2 & < 4 h
  # 3 = x > 4 h
  # Note: Original ranges from 1-4, not 0-3
  case_match(input,
             0 ~ .5, 
             1 ~ 1.5, 
             2 ~ 3,
             3 ~ 5)
 }
 recode3 <- function(input){
  # Response options:
  # 1 = Yes
  # 2 = No
  # NOTE: Reversed from original
  case_match(input,
             1 ~ 1,
             2 ~ 0)
 }
 
 df1 <- df %>%
  mutate(across(c('PaseVr02','PaseVr04','PaseVr05','PaseVr06','PaseVr07'), recode1),
         across(c('PaseVr02a','PaseVr04a','PaseVr05b','PaseVr06b','PaseVr07b'), recode2),
         PaseVr02 = if_else(!is.na(PaseVr02a), PaseVr02 * PaseVr02a/7, PaseVr02),
         PaseVr04 = if_else(!is.na(PaseVr04a), PaseVr04 * PaseVr04a/7, PaseVr04),
         PaseVr05 = if_else(!is.na(PaseVr05b), PaseVr05 * PaseVr05b/7, PaseVr05),
         PaseVr06 = if_else(!is.na(PaseVr06b), PaseVr06 * PaseVr06b/7, PaseVr06),
         PaseVr07 = if_else(!is.na(PaseVr07b), PaseVr07 * PaseVr07b/7, PaseVr07),
         across(c('PaseVr08','PaseVr09','PaseVr10a','PaseVr10b','PaseVr10c','PaseVr10d'), recode3),
         PaseVr11 = if_else(PaseVr11==2 | (!is.na(PaseVr11b) & PaseVr11b<1), 0, PaseVr11),
         PaseVr11 = if_else(PaseVr11 == 1 & PaseVr11b>=1, PaseVr11a/7, PaseVr11),
         PASE = 20*PaseVr02 + 21 *PaseVr04 + 23*(PaseVr05 + PaseVr06) + 30*PaseVr07 + 
          25*(PaseVr08 + PaseVr09) + 30*PaseVr10a + 36*PaseVr10b + 20*PaseVr10c + 35*PaseVr10d + 21*PaseVr11
  )
 # 
 # df1 <- df1 %>%
 #         mutate(Outlier = 0,
 #                Outlier = if_else(PASE > mean(PASE,na.rm=T)+3*sd(PASE,na.rm=T), 1, Outlier),
 #                Outlier = if_else(PASE < mean(PASE,na.rm=T)-3*sd(PASE,na.rm=T), 1, Outlier),
 #                PASE = if_else(Outlier == 1, NA, PASE))
 
 df1 %>%
         select(pseudonym, ParticipantType, TimepointNr, PASE)
 
}
