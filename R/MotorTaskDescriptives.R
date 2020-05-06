source('P:/3024006.01/users/marjoh/scripts/R/pit_motor-behav/MotorTaskDatabase.R')
Data_long <- MotorTaskDatabase()
Data_wide <- Data_long %>%
             pivot_wider(names_from = Condition,
                         values_from = c(Reaction.Time, Percentage.Correct))

### Plots ###
#############
# Percentage correct ~ Reaction time facetted by group and condition
a <- ggplot(Data_long, aes(Reaction.Time, Percentage.Correct))
a + geom_point(size = 4, alpha = 1/3) + 
    facet_grid(Condition~Group) + 
    geom_smooth(method = 'lm', se = FALSE, col = 'red', lwd = 1)

# Boxplot of Reaction.Time/Percentage.Correct ~ Condition labelled by Group
c <- ggplot(Data_long, aes(Condition, Reaction.Time, color = Group))
c + geom_boxplot()

c <- ggplot(Data_long, aes(Condition, Percentage.Correct, color = Group))
c + geom_boxplot()

# Density plot of Reaction.Time/Percentage.Correct labelled by group
d <- ggplot(Data_long, aes(Reaction.Time, color = Condition, fill = Condition))
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
#############

### Clustering ###
##################
library(dendextend)
distMat <- dist(Data_wide[,6])
hc <- hclust(distMat)
dend <- as.dendrogram(hc)
colors_to_use <- as.numeric(Data_wide$Group)
colors_to_use <- colors_to_use[order.dendrogram(dend)]
labels_colors(dend) <- colors_to_use
plot(dend)
##################