source('M:/scripts/Personalized-Parkinson-Project-Motor/R/CombinedDatabase.R')
df <- CombinedDatabase()

source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
library(tidyverse)
library(cowplot)

##### Summary stats #####

##
#df %>% group_by(timepoint) %>% summarise(Off = mean(Up3OfTotal, na.rm = TRUE), On = mean(Up3OnTotal, na.rm = TRUE))
#df %>% group_by(timepoint) %>% summarise(missing = sum(is.na(Up3OfTotal)), n = n())

#####

##### General plotting #####

# Box plots for exploring Time x Group interactions (e.g. effect of medication)
SessionByGroupBoxPlots <- function(dataframe, x, groups){
        
        library(reshape2)
        
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint == 'V1' | timepoint == 'V2') %>%
                select(c(pseudonym, timepoint, !!groups)) %>%
                melt(id.vars = c('pseudonym', 'timepoint'), variable.name = 'group') %>%
                tibble        
                
        g_SbyGbox <- dataframe %>%
                ggplot(aes(timepoint, value, fill = group)) +
                geom_boxplot(lwd = 1, outlier.size = 3) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        g_SbyGdens <- dataframe %>%
                ggplot(aes(value, colour = timepoint)) +
                geom_density(data = dataframe %>% filter(timepoint=='V1'), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                geom_density(data = dataframe %>% filter(timepoint=='V2'), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_SbyGbox, g_SbyGdens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label('Time x Group interaction plot', fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
x <- c('timepoint')
groups <- c('Up3OfTotal', 'Up3OnTotal')
SessionByGroupBoxPlots(df, x, groups)

# Box and density plots for exploring variables from multiple sessions
MultipleSessionBoxDensPlots <- function(dataframe, x, y){
        
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint == 'V1' | timepoint == 'V2')
       
         g_box <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) + 
                geom_boxplot(lwd=1, outlier.size = 3, fill = 'darkgrey') + 
                theme_cowplot(font_size = 25)
        
        g_dens <- dataframe %>%
                ggplot(aes_string(y, fill = x)) +
                geom_density(alpha = 1/2, lwd = 1) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_box, g_dens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label(y, fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('timepoint')
for(n in unique(y)){
        g <- MultipleSessionBoxDensPlots(df, x, n)
        print(g)
}

# Box and density plots for exploring variables from single sessions
SingleSessionBoxDensPlots <- function(dataframe, y, visit){
        
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_box <- ggplot(dataframe, aes_string(x = "''", y = y)) +
                geom_boxplot(lwd = 1, fill = 'darkgrey', outlier.size = 3) +
                theme_cowplot(font_size = 25)
        
        g_dens <- ggplot(dataframe, aes_string(y)) +
                geom_density(alpha = 1/2, lwd = 1, fill = 'darkgrey') +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_box, g_dens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label(paste(y, '   Timepoint =', visit), fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
visit = c('V1')
for(n in unique(y)){
        g <- SingleSessionBoxDensPlots(df, n, visit)
        print(g)
}

# Bar graphs for exploring frequencies
SingleSessionBarPlots <- function(dataframe, y, visit){
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_bar <- dataframe %>%
                ggplot(aes_string(y)) +
                geom_bar(colour = 'darkgrey') +
                theme_cowplot(font_size = 25) +
                labs(title = paste(y, '   Timepoint =', visit))
        g_bar
}
y <- c('Gender')
visit <- c('V1')
for(n in unique(y)){
        g <- SingleSessionBarPlots(df, n, visit)
        print(g)
}

# Scatter plots for exploring relationships between disease progression and duration, tagged with timepoint
ScatterPlotsComplex <- function(dataframe, y, x, group){
        dataframe <- dataframe %>%
                filter(timepoint == 'V1' | timepoint == 'V2') %>%
                mutate(EstDisDurYears = EstDisDurYears + TimeToFUYears)
                
        g_scatter1 <- dataframe %>%
                ggplot(aes_string(x = x, y = y, colour = group)) + 
                geom_point(size = 3) +
                geom_line(aes(group = pseudonym), color = 'darkgrey', lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25)
        
        progvar <- paste(y, '.1YearProg', sep = '')
        
        g_scatter2 <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) + 
                geom_point(size = 3) +
                geom_line(aes_string(group = 'pseudonym', color=progvar), lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient2(low = 'blue', high = 'red')
        
        mean_progression <- mean(unlist(dataframe[, colnames(dataframe) == progvar]), na.rm = TRUE)
        
        g_scatter3 <- dataframe %>% filter(timepoint == 'V2') %>%
                ggplot(aes_string(x = x, y = progvar, colour = progvar)) +
                geom_point(size = 3) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient(low = 'blue', high = 'red') +
                geom_hline(yintercept = mean_progression, linetype = 3, lwd = 1)
        
        plots <- plot_grid(g_scatter1, g_scatter2, g_scatter3, labels = 'AUTO', nrow = 3, ncol = 1)
        plot_grid(plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('EstDisDurYears')
group <- c('timepoint')
for(n in unique(y)){
        g <- ScatterPlotsComplex(df, n, x, group)
        print(g)
}

# Simpler scatter plots
ScatterPlotsSimple <- function(dataframe, y, x, visit){
        dataframe <- dataframe %>%
                filter(timepoint == visit)
        
        g_scatter <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) +
                geom_point(size = 3) +
                geom_smooth(method = 'lm') +
                theme_cowplot(font_size = 25)
        g_scatter + labs(title = paste(y, ' ~ ', x, '   Timepoint =', visit))
}
y <- c('Up3OfTotal', 'Up3OfBradySum')
x <- c('EstDisDurYears')
visit <- c('V1')
for(n in unique(y)){
        g <- ScatterPlotsSimple(df, n, x, visit)
        print(g)
}

# Lineplots for lmer
TimeSlopesBySubjectPlots <- function(dataframe, y, x, group){
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes')
        
        progvar <- paste(y, '.1YearProg', sep = '')
        g_line <- ggplot(dataframe, aes_string(x=x, y=y, group=group)) +
                geom_line(aes_string(color=progvar), lwd = 1.2,  alpha = .7) + 
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25)
        g_line
}
y <- c('Up3OfTotal')
x <- c('timepoint')
group <- c('pseudonym')
for(n in unique(y)){
        g <- TimeSlopesBySubjectPlots(df, y, x, group)
        print(g)
}

MedSlopesMeanPlots <- function(dataframe){
        dataframe <- dataframe %>%
                select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal) %>%
                pivot_longer(!c(pseudonym, timepoint), names_to='Medication', values_to='Up3Total') %>%
                group_by(timepoint, Medication)
        dataframe$Medication <- factor(dataframe$Medication, levels = c('Up3OfTotal','Up3OnTotal'), labels = c('Off','On'))
        
        dataframe.summary <- dataframe %>%
                summarise(n=n(), Mean=mean(Up3Total, na.rm=TRUE), SD=sd(Up3Total, na.rm=TRUE), SE=SD/sqrt(n), lower=Mean+(-1.96*SE), upper=Mean+(1.96*SE))
        
        g_line <- ggplot(dataframe.summary, aes(x=timepoint, y = Mean, group=Medication)) +
                geom_line(aes(color=Medication), lwd=2) +
                geom_point(size=4) +
                geom_errorbar(aes(ymin=lower,ymax=upper), width=0.1, lwd=1) +
                theme_minimal_hgrid(font_size = 25, color = 'darkgrey') +
                labs(title = 'Total UPDRS-III score as a function of time and medication') + 
                ylab('Total UPDRS-III') +
                xlab('Time') +
                scale_x_discrete(labels=c('Baseline','Follow-up')) +
                scale_color_brewer(palette = 'Dark2') +
                scale_fill_brewer(palette = 'Dark2')
        
        g_line
}
MedSlopesMeanPlots(df)

MedSlopesBySubsPlots <- function(dataframe){
        dataframe <- dataframe %>%
                select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Up3TotalOnOffDelta) %>%
                pivot_longer(!c(pseudonym, timepoint, Up3TotalOnOffDelta), names_to='Medication', values_to='Severity') %>%
                mutate(Medication = as.factor(Medication))
        
        dataframeV1 <- dataframe %>%
                filter(timepoint == 'V1')
        g_lineV1 <- ggplot(dataframeV1, aes(x=Medication, y=Severity, group=pseudonym)) +
                geom_line(aes(color=Up3TotalOnOffDelta), lwd=1.2, alpha = .7) +
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25) +
                labs(title ='V1')
        
        dataframeV2 <- dataframe %>%
                filter(timepoint == 'V2')
        g_lineV2 <- ggplot(dataframeV2, aes(x=Medication, y=Severity, group=pseudonym)) +
                geom_line(aes(color=Up3TotalOnOffDelta), lwd=1.2, alpha = .7) +
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25) +
                labs(title = 'V2')
        
        library(ggpubr)
        ggarrange(g_lineV1, g_lineV2, ncol=2)
        
}
MedSlopesBySubsPlots(df)


#####

##### Clustering #####

## KMEANS ##
# Kmeans with intention to separate tremor dominant from non-dominant
# Method does not work
# Gives a straight split into low and high bradykinesia
# Tremor is not being weighed high enough. Probably due to low amount of
# participants with noticable tremor.
df_kmeans <- df %>%
        select(BradySum, RestTremAmpSum)
kmeansObj <- kmeans(df_kmeans, centers = 2)
plot(df_kmeans$BradySum, df_kmeans$RestTremAmpSum, col = kmeansObj$cluster, pch = 19, cex = 2)
points(kmeansObj$centers, col = 1:2, pch = 3, cex = 3, lwd = 3)

#####








