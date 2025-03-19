## Note
# This script has been deprecated in favor of surface-projected MD analyses
# See normalize2.sh script for details on how the surface projection
# is accomplished

library(tidyverse)
library(fslr)
library(RNifti)
library(mice)
library(miceadds)
library(datawizard)
library(readxl)

# List images of interest
locate_image_files <- function(dir, ptn){
  imgs <- list.files(
    dir, 
    pattern = ptn, 
    full.names = T, recursive = T
    )
}

fp <- '/project/3022026.01/pep/bids/derivatives/qsiprep'
ptn <- '^n3_sub-POMU.*_TensorFWCorrected_dcmp_MD.nii.gz'
df <- tibble(imgs=locate_image_files(fp, ptn))

# Smooth and mask images
smooth_images <- function(df_in, sigma, mask){
  for(i in 1:nrow(df_in)){
    dirname <- dirname(df_in$imgs[i])
    filename <- basename(df_in$imgs[i])
    newname <- paste0(dirname, '/s_', filename)
    fsl_smooth(file = df_in$imgs[i], sigma = sigma, outfile = newname, verbose = T)
    fsl_mask(file = newname, mask = mask, outfile = newname, verbose = T)
  }
}
mask <- '/project/3024006.02/templates/template_50HC50PD/HCP1065_MD_template/T_template0_fsl_mask_ero_2mm.nii.gz'
sigma <- 6 / 2.35
smooth_images(df, sigma, mask)

# Locate new smoothed images of interest
fp <- '/project/3022026.01/pep/bids/derivatives/qsiprep'
ptn <- '^s_n3_sub-POMU.*_TensorFWCorrected_dcmp_MD.nii.gz'
df <- tibble(imgs=locate_image_files(fp, ptn))

# Extract name and visit
extract_name_and_visit <- function(df_in){
  df_in <- df_in %>%
    mutate(
      pseudonym = str_sub(imgs, 50, 73),
      Timepoint = str_sub(imgs, 75, 87)
      )
  df_in
}

df <- extract_name_and_visit(df)

# Add baseline covariates
add_baseline_covariates <- function(df_in, csvfile){
  columns <- c('pseudonym','ParticipantType','Timepoint','Age','Gender','NpsEducYears','YearsSinceDiag','MriNeuroPsychTask')
  csvcontents <- read_csv(
    csvfile, 
    col_select = all_of(columns)
  ) %>%
    filter(
      ParticipantType != 'PD_PIT',
      str_detect(Timepoint,'Visit1')
    ) %>%
    select(-Timepoint)
  df_in <- left_join(
    df_in,
    csvcontents,
    by = c('pseudonym')
  )
  df_in
}

csvfile='/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2023-10-18.csv'
df <- add_baseline_covariates(df, csvfile)

# Add clinical scores
add_clinical_scores <- function(df_in, csvfile){
  columns <- c('pseudonym','ParticipantType','Timepoint','Up3OnBradySum','z_MoCA__total','LEDD')
  csvcontents <- read_csv(
    csvfile, 
    col_select = all_of(columns)
  ) %>%
    filter(
      ParticipantType=='PD_POM',
      Timepoint != 'ses-POMVisit2'
    ) %>%
    mutate(
      TimepointNr = if_else(str_detect(Timepoint,'Visit1'),0,2)
    ) %>%
    pivot_wider(
      id_cols = c('pseudonym'),
      names_from = 'TimepointNr',
      names_prefix = 'T',
      values_from = columns[4:length(columns)]
    ) %>%
    mutate(
      Up3OnBradySum_Delta = Up3OnBradySum_T2 - Up3OnBradySum_T0,
      z_MoCA__total_Delta = z_MoCA__total_T2 - z_MoCA__total_T0,
      LEDD_Delta = LEDD_T2 - LEDD_T0
    )
    
  df_in <- left_join(
    df_in,
    csvcontents,
    by='pseudonym'
  )
  
  df_in
  
}

csvfile='/project/3022026.01/pep/ClinVars_10-08-2023/derivatives/merged_manipulated_2023-10-18.csv'
df <- add_clinical_scores(df, csvfile)

# Impute missing values
impute_missing <- function(df_in){
  
  dat_healthy <- df_in %>%
    filter(str_detect(Timepoint,'Visit1')) %>%
    select(pseudonym,ParticipantType,Age,Gender,NpsEducYears,MriNeuroPsychTask)
  
  isna <- apply(dat_healthy, 2, is.na) %>% colSums()
  missing_perc <- round(isna/nrow(dat_healthy), digits = 3)*100
  print(missing_perc)
  dat_healthy <- dat_healthy %>%
    mice(
      m=5,
      maxit = 10,
      method='pmm',
      seed=157,
      print=FALSE
    ) %>%
    complete() %>%
    as_tibble() %>%
    filter(ParticipantType=='HC_PIT')
  
  dat_patient <- df_in %>%
    filter(str_detect(Timepoint,'Visit1'),
           ParticipantType == 'PD_POM') %>%
    select(pseudonym,ParticipantType,Age,Gender,NpsEducYears,YearsSinceDiag,MriNeuroPsychTask,
           starts_with('Up3On'),starts_with('z_MoCA'),starts_with('LEDD'))
  
  isna <- apply(dat_patient, 2, is.na) %>% colSums()
  missing_perc <- round(isna/nrow(dat_patient), digits = 3)*100
  print(missing_perc)
  dat_patient <- dat_patient %>%
    mice(
      m=5,
      maxit = 10,
      method='pmm',
      seed=157,
      print=FALSE
    ) %>%
    complete() %>%
    as_tibble()
  
  dat_final <- bind_rows(dat_healthy,
                         dat_patient)
  
  df_in <- df_in %>%
    select(imgs,pseudonym,Timepoint,ParticipantType) %>%
    left_join(dat_final, by = c('pseudonym','ParticipantType'))
    
  df_in

}

df <- impute_missing(df)

# Exclude subjects based on QC
exclude_poor_quality <- function(df_in, xlsxfile) {
  exclusions <- read_excel(xlsxfile) %>%
    filter(retain == 'N') %>%
    select(pseudonym,session) %>%
    distinct() %>%
    mutate(Exclusion = 1) %>%
    rename(Timepoint = session)
  
  df_in <- df_in %>%
    left_join(exclusions, by = c('pseudonym','Timepoint')) %>%
    mutate(Exclusion = if_else(is.na(Exclusion),0,Exclusion)) %>%
    filter(Exclusion != 1) %>%
    select(-Exclusion)
  
  df_in
}

xlsxfile <- '/project/3024006.02/Analyses/MJF_FreeWater/QC/MD/Exclusions_and_Outliers.xlsx'
df <- exclude_poor_quality(df, xlsxfile)
# df <- df %>% filter(MriNeuroPsychTask=='Motor') %>% select(-MriNeuroPsychTask)

# Write input file for AFNI (group comparisons)
afni_write_covars <- function(df_in,outputfile){
  csvcontents <- df_in %>%
    mutate(TimepointNr=if_else(str_detect(Timepoint,'Visit1'),'T0','T1')) %>%
    select(pseudonym,TimepointNr,ParticipantType,Age,Gender,NpsEducYears,imgs) %>%
    rename(Subj=pseudonym,InputFile=imgs) %>%
    na.omit()
  write_delim(csvcontents, outputfile,delim='\t')
}

outputfile <- '/project/3024006.02/Analyses/MJF_FreeWater/data/AFNI/MD/HCvsPD_MD.txt'
afni_write_covars(df, outputfile)

# Write input file for FSL (brain-clinical correlations)
  # 4D image
  # Delta image
  # Covariate file to copy into fsl_glm gui (centered)
      # NOTE: T0 is perfectly centered, T2 is not entirely,
      # but I will ignore this for practical purposes
  # Command
fsl_4Dimages_and_designs_and_cmds <- function(df_in,outputfolder){
  
  # Select data
  dat <- df_in %>%
    filter(ParticipantType=='PD_POM') %>%
    mutate(Timepoint=if_else(str_detect(Timepoint,'Visit1'),'T0','T2'),
           Gender = if_else(Gender == 'Male',0,1))
  
  # Center numeric variables
  reference_T0 <- dat %>% filter(Timepoint=='T0')
  reference_T2 <- dat %>% filter(Timepoint=='T2')
  dat <- center(dat, select = c('Age','Gender','NpsEducYears','YearsSinceDiag',
                'Up3OnBradySum_T0','Up3OnBradySum_Delta',
                'z_MoCA__total_T0','z_MoCA__total_Delta',
                'LEDD_T0','LEDD_Delta'),
                reference = reference_T0)
  
  dat <- center(dat, select = c('Up3OnBradySum_T2','z_MoCA__total_T2','LEDD_T2'),
                reference = reference_T2)
  
  # Widen
  dat_wide <- dat %>%
    pivot_wider(id_cols = c('pseudonym','Age','Gender','NpsEducYears','YearsSinceDiag',
                            'Up3OnBradySum_T0','Up3OnBradySum_T2','Up3OnBradySum_Delta',
                            'z_MoCA__total_T0','z_MoCA__total_T2','z_MoCA__total_Delta',
                            'LEDD_T0','LEDD_T2','LEDD_Delta'),
                names_from = 'Timepoint',
                names_prefix = 'imgs_',
                values_from = 'imgs') %>%
    mutate(mean=1,
           vxlEV=1) %>%
    mutate(across(where(is.numeric), \(x) round(x, digits=5)))
  
  # Baseline
  full_ba <- dat_wide %>% select(-c(ends_with('_T2'),ends_with('Delta'),vxlEV)) %>% na.omit()
  full_ba %>% select(imgs_T0) %>% write.table(., paste0(outputfolder,'/imgs__T0_full.txt'), col.names = F, row.names = F, quote = F)
  full_ba %>% select(-c(pseudonym,imgs_T0)) %>% write.table(., paste0(outputfolder,'/covs__T0_full.txt'), col.names = F, row.names = F, quote = F)
  full_ba %>% select(-c(pseudonym,imgs_T0,z_MoCA__total_T0,LEDD_T0)) %>% write.table(., paste0(outputfolder,'/covs__T0_full_brady.txt'), col.names = F, row.names = F, quote = F)
  full_ba %>% select(-c(pseudonym,imgs_T0,Up3OnBradySum_T0,LEDD_T0)) %>% write.table(., paste0(outputfolder,'/covs__T0_full_moca.txt'), col.names = F, row.names = F, quote = F)
  full_ba %>% select(-c(pseudonym,imgs_T0,Up3OnBradySum_T0,z_MoCA__total_T0)) %>% write.table(., paste0(outputfolder,'/covs__T0_full_ledd.txt'), col.names = F, row.names = F, quote = F)
  fsl_merge(infiles = full_ba$imgs_T0, outfile = paste0(outputfolder,'/imgs__T0_full.nii.gz'), direction = 't')
  cmd_full <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T0_full -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_3ClinScore.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_3ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T0_full.txt')
  cmd_full_brady <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T0_full_brady -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_brady.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_brady, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T0_full_brady.txt')
  cmd_full_moca <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T0_full_moca -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_moca.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_moca, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T0_full_moca.txt')
  cmd_full_ledd <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T0_full_ledd -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_ledd.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T0/full_sample/T0_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_ledd, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T0_full_ledd.txt')
  
  # Follow-up
  full_fu <- dat_wide %>% select(-c(ends_with('_T0'),ends_with('Delta'),vxlEV)) %>% na.omit()
  full_fu %>% select(imgs_T2) %>% write.table(., paste0(outputfolder,'/imgs__T2_full.txt'), col.names = F, row.names = F, quote = F)
  full_fu %>% select(-c(pseudonym,imgs_T2)) %>% write.table(., paste0(outputfolder,'/covs__T2_full.txt'), col.names = F, row.names = F, quote = F)
  full_fu %>% select(-c(pseudonym,imgs_T2,z_MoCA__total_T2,LEDD_T2)) %>% write.table(., paste0(outputfolder,'/covs__T2_full_brady.txt'), col.names = F, row.names = F, quote = F)
  full_fu %>% select(-c(pseudonym,imgs_T2,Up3OnBradySum_T2,LEDD_T2)) %>% write.table(., paste0(outputfolder,'/covs__T2_full_moca.txt'), col.names = F, row.names = F, quote = F)
  full_fu %>% select(-c(pseudonym,imgs_T2,Up3OnBradySum_T2,z_MoCA__total_T2)) %>% write.table(., paste0(outputfolder,'/covs__T2_full_ledd.txt'), col.names = F, row.names = F, quote = F)
  fsl_merge(infiles = full_fu$imgs_T2, outfile = paste0(outputfolder,'/imgs__T2_full.nii.gz'), direction = 't')
  cmd_full <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2_full -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_3ClinScore.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_3ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2_full.txt')
  cmd_full_brady <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2_full_brady -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_brady.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_brady, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2_full_brady.txt')
  cmd_full_moca <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2_full_moca -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_moca.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_moca, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2_full_moca.txt')
  cmd_full_ledd <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2_full.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2_full_ledd -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_ledd.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2/full_sample/T2_fs_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_ledd, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2_full_ledd.txt')
  
  rbind(c(0,0,0,0,1,0),
        c(0,0,0,0,-1,0)) %>% write.table(., paste0(outputfolder,'/cons__T0nT2_1ClinScore.txt'), col.names = F, row.names = F, quote = F)
  rbind(c(0,0,0,0, 1,0,0,0),
        c(0,0,0,0,-1,0,0,0),
        c(0,0,0,0,0, 1,0,0),
        c(0,0,0,0,0,-1,0,0),
        c(0,0,0,0,0,0, 1,0),
        c(0,0,0,0,0,0,-1,0)) %>% write.table(., paste0(outputfolder,'/cons__T0nT2_3ClinScore.txt'), col.names = F, row.names = F, quote = F)
  
  # Delta
  complete_cases <- dat_wide %>% na.omit()
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'))) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('z_MoCA__total'),contains('LEDD'))) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_brady_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('Up3OnBradySum'),contains('LEDD'))) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_moca_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('Up3OnBradySum'),contains('z_MoCA__total'))) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_ledd_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),vxlEV)) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('z_MoCA__total'),contains('LEDD'),vxlEV)) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_brady.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('Up3OnBradySum'),contains('LEDD'),vxlEV)) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_moca.txt'), col.names = F, row.names = F, quote = F)
  complete_cases %>% select(-c(pseudonym,imgs_T0,imgs_T2,ends_with('_T2'),contains('Up3OnBradySum'),contains('z_MoCA__total'),vxlEV)) %>% write.table(., paste0(outputfolder,'/covs__T2subT0_complete_ledd.txt'), col.names = F, row.names = F, quote = F)
  fsl_merge(infiles = complete_cases$imgs_T0, outfile = paste0(outputfolder,'/imgs__T0_complete.nii.gz'), direction = 't')
  fsl_merge(infiles = complete_cases$imgs_T2, outfile = paste0(outputfolder,'/imgs__T2_complete.nii.gz'), direction = 't')
  
  fsl_maths(file = paste0(outputfolder,'/imgs__T0_complete.nii.gz'), outfile = paste0(outputfolder,'/imgs__T0_complete_Tmean.nii.gz'), opts = '-Tmean', verbose=T)
  fsl_sub(file = paste0(outputfolder,'/imgs__T0_complete.nii.gz'), file2 = paste0(outputfolder,'/imgs__T0_complete_Tmean.nii.gz'), outfile = paste0(outputfolder,'/imgs__T0_complete_demean.nii.gz'), verbose = T)
  fsl_sub(file = paste0(outputfolder,'/imgs__T2_complete.nii.gz'), file2 = paste0(outputfolder,'/imgs__T0_complete.nii.gz'), outfile = paste0(outputfolder,'/imgs__T2subT0_complete.nii.gz'), verbose = T)
  
  cmd_full <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_vxlEV -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_3ClinScore_vxlEV.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_3ClinScore_vxlEV.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp --vxl=12 --vxf=/project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_complete_demean.nii.gz
  "
  write_lines(cmd_full, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_vxlEV.txt')
  cmd_full_brady <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_brady_vxlEV -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_brady_vxlEV.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore_vxlEV.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp --vxl=8 --vxf=/project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_complete_demean.nii.gz
  "
  write_lines(cmd_full_brady, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_brady_vxlEV.txt')
  cmd_full_moca <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_moca_vxlEV -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_moca_vxlEV.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore_vxlEV.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp --vxl=8 --vxf=/project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_complete_demean.nii.gz
  "
  write_lines(cmd_full_moca, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_moca_vxlEV.txt')
  cmd_full_ledd <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_ledd_vxlEV -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_ledd_vxlEV.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore_vxlEV.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp --vxl=8 --vxf=/project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T0_complete_demean.nii.gz
  "
  write_lines(cmd_full_ledd, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_ledd_vxlEV.txt')
  
  cmd_full <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_3ClinScore.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_3ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete.txt')
  cmd_full_brady <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_brady -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_brady.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_brady, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_brady.txt')
  cmd_full_moca <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_moca -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_moca.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_moca, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_moca.txt')
  cmd_full_ledd <- "
  randomise_parallel -1 -i /project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD/imgs__T2subT0_complete.nii.gz -o /project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/rand_T2subT0_complete_ledd -d /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_ledd.mat -t /project/3024006.02/Analyses/MJF_FreeWater/designs/MD/T2subT0/T2subT0_1ClinScore.con -m /project/3024006.02/Analyses/MJF_FreeWater/masks/bi_full_clincorr_bg_mask_cropped_MD.nii.gz -n 5000 -c 3.1 -T -R --uncorrp
  "
  write_lines(cmd_full_ledd, '/project/3024006.02/Analyses/MJF_FreeWater/stats/FSL/MD/cmd__rand_T2subT0_complete_ledd.txt')
  
  rbind(c(0,0,0,0,0, 1,0),
        c(0,0,0,0,0,-1,0)) %>% write.table(., paste0(outputfolder,'/cons__T2subT0_1ClinScore.txt'), col.names = F, row.names = F, quote = F)
  rbind(c(0,0,0,0,0, 1,0,0),
        c(0,0,0,0,0,-1,0,0)) %>% write.table(., paste0(outputfolder,'/cons__T2subT0_1ClinScore_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  rbind(c(0,0,0,0,0, 1,0,0,0,0,0),
        c(0,0,0,0,0,-1,0,0,0,0,0),
        c(0,0,0,0,0,0,0, 1,0,0,0),
        c(0,0,0,0,0,0,0,-1,0,0,0),
        c(0,0,0,0,0,0,0,0,0, 1,0),
        c(0,0,0,0,0,0,0,0,0,-1,0)) %>% write.table(., paste0(outputfolder,'/cons__T2subT0_3ClinScore.txt'), col.names = F, row.names = F, quote = F)
  rbind(c(0,0,0,0,0, 1,0,0,0,0,0,0),
        c(0,0,0,0,0,-1,0,0,0,0,0,0),
        c(0,0,0,0,0,0,0, 1,0,0,0,0),
        c(0,0,0,0,0,0,0,-1,0,0,0,0),
        c(0,0,0,0,0,0,0,0,0, 1,0,0),
        c(0,0,0,0,0,0,0,0,0,-1,0,0)) %>% write.table(., paste0(outputfolder,'/cons__T2subT0_3ClinScore_vxlEV.txt'), col.names = F, row.names = F, quote = F)
  
}

outputfolder <- '/project/3024006.02/Analyses/MJF_FreeWater/data/FSL/MD'
fsl_4Dimages_and_designs_and_cmds(df, outputfolder)














