p1 <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-24-Mar-2021.csv')
p2 <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-13-Jun-2022.csv') #%>%
  #mutate(cName = str_replace(cName, 'POMVisit','Visit'))
t1 <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-24-Mar-2021.csv')
t2 <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-13-Jun-2022.csv') #%>%
  #mutate(cName = str_replace(cName, 'POMVisit','Visit'))

# p <- bind_rows(p1,p2)
# t <- bind_rows(t1,t2)
# write_csv(p, 'P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-24-Mar-2021_and_13-Jun-2022.csv')
# write_csv(t, 'P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-24-Mar-2021_and_13-Jun-2022.csv')

p <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Peak_check-24-Mar-2021_and_13-Jun-2022.csv')
t <- read_csv('P:/3024006.02/Analyses/EMG/motor/manually_checked/Martin/Tremor_check-24-Mar-2021_and_13-Jun-2022.csv')

df <- t %>%
  mutate(jpg = basename(cName)) %>%
  select(cVal, jpg) %>%
  mutate(pseudonym = str_sub(jpg, 1, 24),
         TimepointNr = if_else(str_detect(jpg, 'Visit1'),0,2),
         Axis = str_extract(jpg,"(?<=acc_).*(?=.jpg)"))

df %>%
  select(TimepointNr) %>%
  table()

df %>%
  select(Axis, TimepointNr) %>%
  group_by(TimepointNr) %>%
  table()

df %>%
  select(TimepointNr, cVal) %>%
  group_by(TimepointNr) %>%
  table()

df %>%
  filter(TimepointNr == 2,
         cVal == 1,
         str_detect(jpg, 'ses-POM'))
