library(tidyverse)
fname <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/con_combined_disease_dataTable.txt'
outdir <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/Longitudinal/neuropointillist/disease'

df <- read_tsv(fname) %>%
  rename(idnum = Subj)  # idnum is internal to npoint

# Covars
# idnum,group,time,age,sex
# If there are multiple conditions, then we need to collapse across conditions
# Time-varying, condition-static
covars <- df %>%
  select(idnum,Group,TimepointNr,Age.gmc,MeanFD.cwc,MeanFD.cmc,Sex) %>%
  group_by(idnum, TimepointNr) %>%
  filter(row_number()==1) %>%
  ungroup()
write_csv(covars, file.path(outdir, 'covars.csv'))

# Setfilenames
# one image path per row
# Condition-varying, time-static
setfilename.T0 <- df %>%
  filter(TimepointNr=='T0') %>%
  select(InputFile)
write_csv(setfilename.T0, file.path(outdir, 'setfilenames1.txt'), col_names = FALSE)
setfilename.T1 <- df %>%
  filter(TimepointNr=='T1') %>%
  select(InputFile)
write_csv(setfilename.T1, file.path(outdir, 'setfilenames2.txt'), col_names = FALSE)

# Setlabels
# idnum,group,time,choice
# Condition-varying, time-static
setlabels.T0 <- df %>%
  filter(TimepointNr=='T0') %>%
  select(idnum,Group,TimepointNr,trial_type)
write_csv(setlabels.T0, file.path(outdir, 'setlabels1.csv'))
setlabels.T1 <- df %>%
  filter(TimepointNr=='T1') %>%
  select(idnum,Group,TimepointNr,trial_type)
write_csv(setlabels.T1, file.path(outdir, 'setlabels2.csv'))

