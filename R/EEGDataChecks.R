##### TREMOR #####

# Check how many participants have a 3-8Hz tremor

# Extract subject and visit
peak_check <- read_csv('P:/3022026.01/analyses/EMG/motor/manually_checked/Martin/Peak_check-09-Nov-2020.csv')
tremor_check <- read_csv('P:/3022026.01/analyses/EMG/motor/manually_checked/Martin/Tremor_check-09-Nov-2020.csv')
subjects <- peak_check %>%
        mutate(pseudonym = str_extract(cName, 'sub-POMU(.?)*Visit[:digit:]')) %>%
        select(pseudonym) %>%
        separate(pseudonym, sep='-ses-', into=c('pseudonym','visit')) %>%
        mutate(visit = as.factor(visit))

# Extract peak
RegDir <- 'P:/3022026.01/analyses/EMG/motor/processing/prepemg/Regressors/ZSCORED/'
RegDir.contents <- dir(RegDir)
regressors <- as_tibble(RegDir.contents) %>%
        mutate(sel = str_detect(value, 'Hz_regressors_log.jpg')) %>%
        filter(sel == TRUE) %>%
        mutate(Hz = str_extract(value, '(?<=_)[:digit:](?=Hz)'),
               Hz = as.double(Hz)) %>%
        select(Hz)

dat <- bind_cols(subjects,
                 peak=as.factor(peak_check$cVal),
                 tremor=as.factor(tremor_check$cVal),
                 Hz=regressors$Hz)

# Summary
dat %>%
        select(peak,tremor) %>%
        group_by(peak, tremor) %>%
        summarise(n = n())
dat %>%
        select(visit, tremor) %>%
        group_by(visit, tremor) %>%
        summarise(n=n())

# Histogram
dat %>% ggplot(., aes(x=Hz, fill = tremor)) +
        geom_histogram(stat = 'count') +
        geom_vline(xintercept = 2.5) + 
        geom_vline(xintercept = 8.5)

# Percentage of participants with 'tremor' in 3-8Hz range
percentage_tremor <- dat %>% 
        filter(peak==1,tremor==1,Hz > 2, Hz < 9) %>%
        nrow / nrow(dat) * 100
cat('Participants with 3-8Hz tremor: ', percentage_tremor, '%')

#####

