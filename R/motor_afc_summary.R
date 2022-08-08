dAFC <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc'
fAFC <- dir(dAFC, pattern = 'sub-POMU.*_afc.txt', full.names = TRUE)
df.AFC <- tibble()
for(i in 1:length(fAFC)){
  f <- basename(fAFC[i])
  sub <- str_sub(f, start = 1, end = 24)
  ses <- str_sub(f, start = 26, end = 38)
  subinfo <- tibble(pseudonym=sub,session=ses)
  afc <- read_table(fAFC[i], col_names = c('FWHM_x','FWHM_y','FWHM_z','FWHM_comb'), show_col_types = FALSE, skip = 1)
  df.AFC <- bind_rows(df.AFC, tibble(subinfo,afc))
}
summary <- df.AFC %>% summarise(Avg.FWHM_x = mean(FWHM_x),
                     Avg.FWHM_y = mean(FWHM_y),
                     Avg.FWHM_z = mean(FWHM_z),
                     Avg.FWHM_comb = mean(FWHM_comb),
                     Sd.FWHM_x = sd(FWHM_x),
                     Sd.FWHM_y = sd(FWHM_y),
                     Sd.FWHM_z = sd(FWHM_z),
                     Sd.FWHM_comb = sd(FWHM_comb))
summary <- round(summary, digits=5)
outputname <- '/project/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/afc_FWHMxyz.txt'
vec <- summary[1,1:3]
write_delim(vec, outputname, col_names = FALSE, delim = ' ')
  
  
  
