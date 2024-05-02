# Function - Input: data, design, model

library(tidyverse)
library(RNifti)
library(tidymodels)
library(multilevelmod)
library(lme4)
library(lmerTest)
library(broom.mixed)
library(parallel)
library(car)

opts <- options()
options(contrasts = c('contr.Sum','contr.Poly'))
if(!exists('n_cores')){
        n_cores <- detectCores()
}
options(mc.cores = n_cores)

# Define directories
root <- '/project/3024006.02/Analyses/motor_task/Group'

# Locate files
con <- c('con_0001', 'con_0005')
ses <- c('ses-Visit1', 'ses-Visit2')
files <- c()
for(c in con){
  for(s in ses){
    files <- c(files,
               list.files(path = paste(root, c, s, sep = '/'),
                          pattern = '.nii',
                          recursive = T,
                          full.names = T)
    )
  }
}

# Initialize data frame
df <- tibble(files = files) %>%
  mutate(pseudonym = str_sub(files, start = 74, end = 97),
         ParticipantType = str_sub(files, start = 67, end = 72),
         Timepoint = str_sub(files, start = 56, end = 65),
         contrast = str_sub(files, start = 47, end = 54),
         swap = as.character(str_detect(files, 'L2Rswap')),
         image = str_sub(files, start = 67, end = -1L))

# Select levels
df <- df %>%
  filter(ParticipantType == 'HC_PIT' | ParticipantType == 'PD_POM',
         Timepoint == 'ses-Visit1' | Timepoint == 'ses-Visit2',
         contrast == 'con_0001' | contrast == 'con_0005',
         swap == TRUE | swap == FALSE)

# Create design
design <- df %>%
  select(pseudonym, ParticipantType, Timepoint, contrast)

read_clinical_metrics <- function(filename, clinical_metrics){
        
        df <- read_csv(filename,
                       col_select = all_of(clinical_metrics)) 
        
        df <- df %>%
                mutate(Subtype_DiagEx3_DisDurSplit.MCI = if_else(ParticipantType=='HC_PIT','0_Healthy',Subtype_DiagEx3_DisDurSplit.MCI),
                       TimepointNr = if_else(ParticipantType == 'HC_PIT' & TimepointNr == 1, 2, TimepointNr)) %>%
                filter(TimepointNr != 1)
        
        ba_subtypes <- df %>%
                filter(TimepointNr == 0) %>%
                select(pseudonym,ParticipantType,
                       Subtype_DiagEx3_DisDurSplit.MCI) %>%
                rename(Subtype_DiagEx3_DisDurSplit.MCI_ba = Subtype_DiagEx3_DisDurSplit.MCI)
        
        df <- df %>%
                select(-Subtype_DiagEx3_DisDurSplit.MCI) %>%
                left_join(ba_subtypes, by = c('pseudonym','ParticipantType'))
        
        df$Subtype_DiagEx3_DisDurSplit.MCI_ba[is.na(df$Subtype_DiagEx3_DisDurSplit.MCI_ba)] <- '4_Undefined'
        
        source("~/scripts/Personalized-Parkinson-Project-Motor/R/functions/retrieve_resphand.R")
        resp_hand <- retrieve_resphand() %>%
                mutate(TimepointNr = if_else(str_detect(Timepoint,'Visit1'),0,2),
                       ParticipantType = Group) %>%
                select(-c(Group,Timepoint))
        
        df <- df %>%
                left_join(., resp_hand, by = c('pseudonym','ParticipantType','TimepointNr'))
        
        df <- df %>%
                mutate(RespHandIsDominant = if_else(PrefHand == RespondingHand,'TRUE','FALSE')) %>%
                select(-c(PrefHand,RespondingHand))
        
        df
        
}
clinical_metrics <- c('pseudonym','ParticipantType','TimepointNr','Age','Gender','NpsEducYears','PrefHand',
                      'Subtype_DiagEx3_DisDurSplit.MCI')
df_clin <- read_clinical_metrics('/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2023-10-18.csv', 
                                 clinical_metrics) %>%
        mutate(Timepoint = if_else(TimepointNr==0,'ses-Visit1','ses-Visit2')) %>%
        select(-TimepointNr)

design <- design %>%
        left_join(., df_clin, by = c('pseudonym','ParticipantType','Timepoint'))

# Mask
mask <- readNifti('/project/3024006.02/Analyses/BRAIN_2023/fMRI/Group_comparisons/HcOn_x_ExtInt2Int3Catch_NoOutliers/x_HCgtPD_Mean_Mask.nii')
mask_dims <- dim(mask)
len <- mask_dims[1] * mask_dims[2] * mask_dims[3]
mask_vector <- as.vector(mask)
mask_idx <- which(mask_vector > 0)

# Read nii > Vectorize > Store in df
nifti <- tibble(voxeldata = list())
for(n in 1:nrow(df)){
  print(paste(df$pseudonym[n], df$ParticipantType[n], df$Timepoint[n], df$contrast[n]))
  tmp <- tibble(voxeldata = list(readNifti(df$files[n]) %>% as.vector()))
  nifti <- bind_rows(nifti,tmp)
}
df <- bind_cols(design, nifti)

# Fit model for each voxel in mask

extract_idx <- function(vec,idx){
  x <- vec[idx]
  x
}
  # Model
lmer_mod <- 
  linear_reg() %>%
  set_engine('lmer') %>%
  set_mode('regression')

  # Recipe
df <- df %>%
        mutate(y = NA)
lmer_rec <- 
  recipe(y ~ ParticipantType + Timepoint + contrast + Age + Gender + NpsEducYears + RespHandIsDominant + pseudonym, data = df) %>%
  add_role(pseudonym, new_role = 'exp_unit') %>%
  step_interact(terms = ~ ParticipantType:Timepoint:contrast) %>%
  step_zv(all_predictors(), -has_role('exp_unit'))

  # Workflow
lmer_wflow <-
  workflow() %>%
  add_model(lmer_mod, formula = y ~ ParticipantType*Timepoint*contrast + Age + Gender + NpsEducYears + RespHandIsDominant + (1|pseudonym)) %>%
  add_recipe(lmer_rec)

  # Voxel-wise analysis
v <- mask_vector*0
df.stat <- tibble(est_group = v,
                  est_time = v,
                  est_con = v,
                  est_group_x_time = v,
                  est_group_x_con = v,
                  est_time_x_con = v,
                  est_group_x_time_x_con = v,
                  chisq_group = v,
                  chisq_time = v,
                  chisq_con = v,
                  chisq_group_x_time = v,
                  chisq_group_x_con = v,
                  chisq_time_x_con = v,
                  chisq_group_x_time_x_con = v,
                  p_group = v,
                  p_time = v,
                  p_con = v,
                  p_group_x_time = v,
                  p_group_x_con = v,
                  p_time_x_con = v,
                  p_group_x_time_x_con = v,
                  resid = v)
for(k in mask_idx){
  
  print(k)
  
  # Assemble data
  tmp <- tibble(y = sapply(df$voxeldata, extract_idx, k)) %>%
    bind_cols(design)
  
  # Fit
  lmer_fit <-
    lmer_wflow %>%
    fit(data = tmp)
  
  # Results
  lmer_res <- 
    tidy(lmer_fit, conf.int = T)
  
  # Convert to get lmerTest p-values
  lmer_res_alt <-
    lmer_fit %>%
    extract_fit_engine() %>%
    as_lmerModLmerTest()
  s <- summary(lmer_res_alt)
  a <- Anova(lmer_res_alt, type = 'III')
  r <- resid(lmer_res_alt)
  
  # Store results
  df.stat$est_group[k] <- lmer_res$estimate[2]
  df.stat$est_time[k] <- lmer_res$estimate[3]
  df.stat$est_con[k] <- lmer_res$estimate[4]
  df.stat$est_group_x_time[k] <- lmer_res$estimate[9]
  df.stat$est_group_x_time[k] <- lmer_res$estimate[10]
  df.stat$est_time_x_con[k] <- lmer_res$estimate[11]
  df.stat$est_group_x_time_x_con[k] <- lmer_res$estimate[12]
  
  df.stat$chisq_group[k] <- a$Chisq[2]
  df.stat$chisq_time[k] <- a$Chisq[3]
  df.stat$chisq_con[k] <- a$Chisq[4]
  df.stat$chisq_group_x_time[k] <- a$Chisq[9]
  df.stat$chisq_group_x_time[k] <- a$Chisq[10]
  df.stat$chisq_time_x_con[k] <- a$Chisq[11]
  df.stat$chisq_group_x_time_x_con[k] <- a$Chisq[12]
  
  df.stat$p_group[k] <- a$`Pr(>Chisq)`[2]
  df.stat$p_time[k] <- a$`Pr(>Chisq)`[3]
  df.stat$p_con[k] <- a$`Pr(>Chisq)`[4]
  df.stat$p_group_x_time[k] <- a$`Pr(>Chisq)`[9]
  df.stat$p_group_x_time[k] <- a$`Pr(>Chisq)`[10]
  df.stat$p_time_x_con[k] <- a$`Pr(>Chisq)`[11]
  df.stat$p_group_x_time_x_con[k] <- a$`Pr(>Chisq)`[12]
  
  df.stat$resid[k] <- lmer_res$estimate[14]
  
}

for(c in 1:ncol(df.stat)){
        writeNifti(array(df.stat %>% pull(colnames(df.stat[c])), mask_dims), 
                   paste0('/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Rvoxwise/', colnames(df.stat)[c], '.nii.gz'), 
                   template = mask, 
                   datatype = 'float')
}

# Write to file
writeNifti(array(df.stat$est_group, mask_dims), 
          '/project/3024006.02/Analyses/motor_task/Group/Longitudinal/Rvoxwise/est_group.nii.gz', 
          template = mask, 
          datatype = 'float')





y <- vector(mode="numeric", length=len)
y[mask.vertices] <- voxeldata
writeNifti(array(y, mask.dims), outputfilename, template=mask,datatype="float")



