# 

source('M:/scripts/Personalized-Parkinson-Project-Motor/R/MotorTaskDatabase.R')
Data_longPIT <- MotorTaskDatabase('3024006.01')
Data_longPOM <- MotorTaskDatabase('3022026.01')
Data_long <- bind_rows(Data_longPIT, Data_longPOM)
Data_long <- Data_long[complete.cases(Data_long), ]
Data_wide <- Data_long %>%
             pivot_wider(names_from = Condition,
                         values_from = c(Response.Time, Percentage.Correct))

Data_summary <- Data_long %>%
        dplyr::group_by(Group, Condition) %>%
        dplyr::summarise(n = n(), 
                         rt_mean = mean(Response.Time), rt_sd = sd(Response.Time),
                         accuracy_mean = mean(Percentage.Correct), accuracy_sd = sd(Percentage.Correct)) %>%
        dplyr::mutate(rt_se = rt_sd/sqrt(n), rt_ci = 2*rt_se,
                      accuracy_se = accuracy_sd/sqrt(n), accuracy_ci = 2*accuracy_se)

##### Plots #####

##### Violin #####

library(cowplot)
library(dplyr)
library(readr)
library(ggplot2)
source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")

RT_p1 <- ggplot(Data_long, aes(x = Condition, y = Response.Time, fill = Group)) +
        geom_flat_violin(aes(fill = Group),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = NA)+
        geom_point(aes(x = as.numeric(Condition)-.15, y = Response.Time, colour = Group),position = position_jitter(width = .05), size = .25, shape = 20)+
        geom_boxplot(aes(x = Condition, y = Response.Time, fill = Group),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
        geom_line(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = rt_mean, group = Group, colour = Group), linetype = 3)+
        geom_point(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = rt_mean, group = Group, colour = Group), shape = 18) +
        geom_errorbar(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = rt_mean, group = Group, colour = Group, ymin = rt_mean-rt_se, ymax = rt_mean+rt_se), width = .05)+
        scale_colour_brewer(palette = "Dark2")+
        scale_fill_brewer(palette = "Dark2")+
        ggtitle("Response time ~ Condition by Group")

RT_p2 <- ggplot(Data_long, aes(x = Group, y = Response.Time, fill = Condition)) +
        geom_flat_violin(aes(fill = Condition),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = NA)+
        geom_point(aes(x = as.numeric(Group)-.15, y = Response.Time, colour = Condition),position = position_jitter(width = .05), size = .25, shape = 20)+
        geom_boxplot(aes(x = Group, y = Response.Time, fill = Condition),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
        geom_line(data = Data_summary, aes(x = as.numeric(Group)+.1, y = rt_mean, group = Condition, colour = Condition), linetype = 3)+
        geom_point(data = Data_summary, aes(x = as.numeric(Group)+.1, y = rt_mean, group = Condition, colour = Condition), shape = 18) +
        geom_errorbar(data = Data_summary, aes(x = as.numeric(Group)+.1, y = rt_mean, group = Condition, colour = Condition, ymin = rt_mean-rt_se, ymax = rt_mean+rt_se), width = .05)+
        scale_colour_brewer(palette = "Dark2")+
        scale_fill_brewer(palette = "Dark2")+
        ggtitle("Group ~ Response time by Condition") +
        coord_flip()

ACC_p1 <- ggplot(Data_long, aes(x = Condition, y = Percentage.Correct, fill = Group)) +
        geom_flat_violin(aes(fill = Group),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = NA)+
        geom_point(aes(x = as.numeric(Condition)-.15, y = Percentage.Correct, colour = Group),position = position_jitter(width = .05), size = .25, shape = 20)+
        geom_boxplot(aes(x = Condition, y = Percentage.Correct, fill = Group),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
        geom_line(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = accuracy_mean, group = Group, colour = Group), linetype = 3)+
        geom_point(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = accuracy_mean, group = Group, colour = Group), shape = 18) +
        geom_errorbar(data = Data_summary, aes(x = as.numeric(Condition)+.1, y = accuracy_mean, group = Group, colour = Group, ymin = accuracy_mean-accuracy_se, ymax = accuracy_mean+accuracy_se), width = .05)+
        scale_colour_brewer(palette = "Dark2")+
        scale_fill_brewer(palette = "Dark2")+
        ggtitle("Accuracy ~ Condition by Group")

ACC_p2 <- ggplot(Data_long, aes(x = Group, y = Percentage.Correct, fill = Condition)) +
        geom_flat_violin(aes(fill = Condition),position = position_nudge(x = .1, y = 0), adjust = 1, trim = FALSE, alpha = .5, colour = NA)+
        geom_point(aes(x = as.numeric(Group)-.15, y = Percentage.Correct, colour = Condition),position = position_jitter(width = .05), size = .25, shape = 20)+
        geom_boxplot(aes(x = Group, y = Percentage.Correct, fill = Condition),outlier.shape = NA, alpha = .5, width = .1, colour = "black")+
        geom_line(data = Data_summary, aes(x = as.numeric(Group)+.1, y = accuracy_mean, group = Condition, colour = Condition), linetype = 3)+
        geom_point(data = Data_summary, aes(x = as.numeric(Group)+.1, y = accuracy_mean, group = Condition, colour = Condition), shape = 18) +
        geom_errorbar(data = Data_summary, aes(x = as.numeric(Group)+.1, y = accuracy_mean, group = Condition, colour = Condition, ymin = accuracy_mean-accuracy_se, ymax = accuracy_mean+accuracy_se), width = .05)+
        scale_colour_brewer(palette = "Dark2")+
        scale_fill_brewer(palette = "Dark2")+
        ggtitle("Group ~ Accuracy by Condition") +
        coord_flip()

all_plot <- plot_grid(RT_p1, RT_p2, ACC_p1, ACC_p2, labels = 'AUTO', nrow = 2, ncol = 2)
title <- ggdraw() + 
        draw_label("Motor task performance",
                   fontface = 'bold')
all_plot_final <- plot_grid(title, all_plot, ncol = 1, rel_heights = c(0.1, 1))
all_plot_final

#####

##### Assorted plots #####
# Percentage correct ~ Response time facetted by group and condition
a <- ggplot(Data_long, aes(Response.Time, Percentage.Correct))
a + geom_point(size = 4, alpha = 1/3) + 
    facet_grid(Condition~Group) + 
    geom_smooth(method = 'lm', se = FALSE, col = 'red', lwd = 1)

# Boxplot of Response.Time/Percentage.Correct ~ Condition labelled by Group
c <- ggplot(Data_long, aes(Condition, Response.Time, color = Group))
c + geom_boxplot()

c <- ggplot(Data_long, aes(Condition, Percentage.Correct, color = Group))
c + geom_boxplot()

# Density plot of Response.Time/Percentage.Correct labelled by group
d <- ggplot(Data_long, aes(Response.Time, color = Condition, fill = Condition))
d + geom_density(alpha = 1/2, lwd = 1) +
    facet_grid(.~Group)

d <- ggplot(Data_long, aes(Percentage.Correct, color = Condition, fill = Condition))
d + geom_density(alpha = 1/2, lwd = 1) +
    facet_grid(.~Group)

# Count of Responding.Hand by Group
b <- ggplot(subset(Data_long, Condition == 'Ext'), aes(Responding.Hand))
b + geom_bar() +
    facet_grid(.~Group)

# Pairs plot
pairs(Data_wide[,2:9])
#####

##### Clustering #####
library(dendextend)
distMat <- dist(Data_wide[,6])
hc <- hclust(distMat)
dend <- as.dendrogram(hc)
colors_to_use <- as.numeric(Data_wide$Group)
colors_to_use <- colors_to_use[order.dendrogram(dend)]
labels_colors(dend) <- colors_to_use
plot(dend)
#####