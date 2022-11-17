library(tidyverse)

# Load quality check files
f1 = 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0001/Group.txt'
f2 = 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0002/Group.txt'
f3 = 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/con_0003/Group.txt'
f4 = 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/QC/ResMS/Group.txt'
dat1 <- read_csv(f1)
dat2 <- read_csv(f2)
dat3 <- read_csv(f3)
dat4 <- read_csv(f4)

# Summarise and locate outliers
dat1.summary <- dat1 %>% group_by(Visit) %>%
        summarise(n=n(), avg=mean(GrandMean), sd=sd(GrandMean))
dat1.outliers <- dat1 %>%
        filter(Outlier == 1) %>%
        mutate(Sub = paste('sub-',Sub, sep=''))

dat2.summary <- dat2 %>% group_by(Visit) %>%
        summarise(n=n(), avg=mean(GrandMean), sd=sd(GrandMean))
dat2.outliers <- dat2 %>%
        filter(Outlier == 1) %>%
        mutate(Sub = paste('sub-',Sub, sep=''))

dat3.summary <- dat3 %>% group_by(Visit) %>%
        summarise(n=n(), avg=mean(GrandMean), sd=sd(GrandMean))
dat3.outliers <- dat3 %>%
        filter(Outlier == 1) %>%
        mutate(Sub = paste('sub-',Sub, sep=''))

dat4.summary <- dat4 %>% group_by(Visit) %>%
        summarise(n=n(), avg=mean(GrandMean), sd=sd(GrandMean))
dat4.outliers <- dat4 %>%
        filter(Outlier == 1) %>%
        mutate(Sub = paste('sub-',Sub, sep=''))

dat1.summary
dat1.outliers
dat2.summary
dat2.outliers
dat3.summary
dat3.outliers
dat4.summary
dat4.outliers

# Check which participants have both PIT and POM data (mainly used for OffOn comparison)
analysis.dir <- 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/'
for(n in dat1.outliers$Sub){
        d <- paste(analysis.dir,n,sep='')
        print(n)
        print(dir(d))
}
analysis.dir <- 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/'
for(n in dat2.outliers$Sub){
        d <- paste(analysis.dir,n,sep='')
        print(n)
        print(dir(d))
}
analysis.dir <- 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/'
for(n in dat3.outliers$Sub){
        d <- paste(analysis.dir,n,sep='')
        print(n)
        print(dir(d))
}
analysis.dir <- 'P:/3022026.01/analyses/motor/DurAvg_ReAROMA_PMOD_TimeDer/'
for(n in dat4.outliers$Sub){
        d <- paste(analysis.dir,n,sep='')
        print(n)
        print(dir(d))
}








