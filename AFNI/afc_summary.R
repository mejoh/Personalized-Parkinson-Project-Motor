library(tidyverse)
dAFC <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc'
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

con_0001 <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/Group/con_0001/'
v1 <- tibble(file=dir(paste(con_0001,'ses-Visit1',sep=''))) %>%
  mutate(pseudonym=str_sub(file,8,31),session=str_sub(file,33,45))
v2 <- tibble(file=dir(paste(con_0001,'ses-Visit2',sep=''))) %>%
  mutate(pseudonym=str_sub(file,8,31),session=str_sub(file,33,45))
analyzed <- bind_rows(v1,v2) %>% select(-file)

# Exclude sessions that were not inlcuded in analyses
df.AFC$include <- NA
for(n in 1:nrow(df.AFC)){
  
  s <- df.AFC$pseudonym[n]
  v <- df.AFC$session[n]
  
  test <- analyzed %>% filter(pseudonym==s & session==v)
  
  if(nrow(test)>0){
    df.AFC$include[n] <- 1
  }else{
    df.AFC$include[n] <- 0
  }
  
}
df.AFC <- df.AFC %>% filter(include==1)

pairs(df.AFC[,3:6]) %>% print()
summary(df.AFC[,3:6]) %>% print()
axis.x <- ggplot(df.AFC, aes(x=FWHM_x)) + 
  geom_density(alpha=0.5,trim=TRUE)
axis.y <- ggplot(df.AFC, aes(x=FWHM_y)) + 
  geom_density(alpha=0.5,trim=TRUE)
axis.z <- ggplot(df.AFC, aes(x=FWHM_z)) + 
  geom_density(alpha=0.5,trim=TRUE)
axis.comb <- ggplot(df.AFC, aes(x=FWHM_comb)) + 
  geom_density(alpha=0.5,trim=TRUE)
p <- ggarrange(axis.x, axis.y, axis.z, axis.comb, ncol = 4, nrow = 1)
print(p)

summary <- df.AFC %>%
        summarise(Avg.FWHM_x = median(FWHM_x),
                     Avg.FWHM_y = median(FWHM_y),
                     Avg.FWHM_z = median(FWHM_z),
                     Avg.FWHM_comb = median(FWHM_comb),
                     Sd.FWHM_x = sd(FWHM_x),
                     Sd.FWHM_y = sd(FWHM_y),
                     Sd.FWHM_z = sd(FWHM_z),
                     Sd.FWHM_comb = sd(FWHM_comb))
summary <- round(summary, digits=5)
outputname <- 'P:/3024006.02/Analyses/DurAvg_ReAROMA_PMOD_TimeDer_Trem/afc/afc_FWHMxyz.txt'
vec <- summary[1:3]
write_delim(vec, outputname, col_names = FALSE, delim = ' ')
  
  
  
