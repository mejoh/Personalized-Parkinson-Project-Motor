source("/home/sysneu/marjoh/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
source("/home/sysneu/marjoh/scripts/RainCloudPlots/tutorial_R/summarySE.R")
library(cowplot)
library(readr)
library(tidyverse)

datafile <- '/project/3022026.01/pep/bids/derivatives/database_motor_task_2021-08-04.csv'
data <- read_csv(datafile)
data <- data %>%
  filter(Timepoint == 'ses-POMVisit1' | Timepoint == 'ses-PITVisit1') %>%
  filter(Group == 'PD_POM' | Group == 'HC_PIT') %>%
  filter(Poor.Performance == 'No') %>%
  filter(Condition != 'Catch') %>%
  select(pseudonym, Group, Condition, Response.Time) %>%
  mutate(Group = as.factor(Group),
         Condition = as.factor(Condition))

sumrepdat <- summarySE(data, measurevar = "Response.Time",
                       groupvars=c("Group", "Condition"))

p11 <- ggplot(data, aes(x = Condition, y = Response.Time, fill = Group)) +
  geom_flat_violin(aes(fill = Group),position = position_nudge(x = .1, y = 0), adjust = 1.5, trim = FALSE, alpha = .5, colour = NA)+
  geom_point(aes(x = as.numeric(Condition)-.1, y = Response.Time, colour = Group),position = position_jitterdodge(jitter.width = .04, dodge.width = .05), size = .25, shape = 20)+
  geom_boxplot(aes(x = Condition, y = Response.Time, fill = Group),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
  geom_line(data = sumrepdat, aes(x = as.numeric(Condition)+.1, y = Response.Time_mean, group = Group, colour = Group), linetype = 3)+
  geom_point(data = sumrepdat, aes(x = as.numeric(Condition)+.1, y = Response.Time_mean, group = Group, colour = Group), shape = 18) +
  geom_errorbar(data = sumrepdat, aes(x = as.numeric(Condition)+.1, y = Response.Time_mean, group = Group, colour = Group, ymin = Response.Time_mean-se, ymax = Response.Time_mean+se), width = .05)+
  scale_colour_brewer(palette = "Dark2")+
  scale_fill_brewer(palette = "Dark2")+
  ggtitle("Figure R11: Repeated Measures - Factorial (Extended)")+
  coord_cartesian(xlim = c(1.2, NA), clip = "off") +
  theme_cowplot()
#ggsave('11repanvplot2.png', width = w, height = h)