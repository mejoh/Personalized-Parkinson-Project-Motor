source('M:/scripts/Personalized-Parkinson-Project-Motor/R/CombinedDatabase.R')
df <- CombinedDatabase()

##### Libraries #####
#source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
library(tidyverse)
library(cowplot)
#####

##### Summary stats #####

# Response times by timepoint and condition
df %>%
        filter(timepoint == 'V1' || timepoint == 'V3') %>%
        group_by(timepoint, Condition) %>%
        summarise(n=n(),
                  avg=mean(Response.Time, na.rm = TRUE),
                  sd=sd(Response.Time, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(Response.Time)))

# Percentage correct by timepoint and condition
df %>%
        filter(timepoint == 'V1' || timepoint == 'V3') %>%
        group_by(timepoint, Condition) %>%
        summarise(n=n(),
                  avg=mean(Percentage.Correct, na.rm = TRUE),
                  sd=sd(Percentage.Correct, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(Percentage.Correct)))

# Up3OfTotal by timepoint and medication
df %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct)) %>%
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal) %>%
        pivot_longer(cols = 3:4,
                     names_to = 'medication',
                     values_to = 'score') %>%
        mutate(medication=ifelse(medication=='Up3OfTotal', 'Off', 'On'),
               medication=as.factor(medication)) %>%
        filter(timepoint != 'V3') %>%
        group_by(timepoint, medication) %>%
        summarise(n=n(),
                  avg=mean(score, na.rm = TRUE),
                  sd=sd(score, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(score)))

# 1-year delta(Up3OfTotal) by medication
df %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct)) %>%
        select(pseudonym, timepoint, Up3OfTotal.1YearProg, Up3OnTotal.1YearProg) %>%
        pivot_longer(cols = 3:4,
                     names_to = 'medication',
                     values_to = 'delta') %>%
        mutate(medication=ifelse(medication=='Up3OfTotal.1YearProg', 'Off', 'On'),
               medication=as.factor(medication)) %>%
        filter(timepoint == 'V2') %>%
        group_by(timepoint, medication) %>%
        summarise(n=n(),
                  avg=mean(delta, na.rm = TRUE),
                  sd=sd(delta, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(delta)))

# Brain activity
# IN PROGRESS

#####

##### Demographics #####

df.demo <- df %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct)) %>%
        select(pseudonym, timepoint, 
               Age, 
               Gender, 
               EstDisDurYears, 
               TimeToFUYears, 
               Up3OfHoeYah, 
               MostAffSide, 
               PrefHand, 
               Responding.Hand, 
               Up3OfRestTremAmpSum) %>%
        mutate(Resting.Tremor=as.factor(ifelse(Up3OfRestTremAmpSum >= 1, 'Yes','No')))

categorical.vars <- c(2,4,7,8,9,10,12)
for(i in categorical.vars){
        print(table(df.demo[,i]))
}
continuous.vars <- c(3,5,6)
for(i in continuous.vars){
        var <- na.omit(df.demo[ ,i][[1]])
        varname <- colnames(df.demo[,i])
        if(varname=='TimeToFUYears'){
                var <- var[var > 0]
        }
        avg <- mean(var, na.rm = TRUE)
        sd <- sd(var, na.rm = TRUE)
        se <- sd/sqrt(length(var))
        lowerCI <- avg-1.96*se
        upperCI <- avg-1.96*se
        dat <- c(avg=avg, sd=sd, se=se, lowerCI=lowerCI, upperCI=upperCI)
        cat(varname, '\n')
        print(dat)
        cat('\n')
}
        

#####

##### Widen data frame to accomodate plotting of motor task performance #####

df.wide <- df %>%
        pivot_wider(names_from = Condition,
                    values_from = c(Response.Time, Percentage.Correct))

#####

##### Collection of plotting functions #####

# Box plots for exploring Time x Group interactions (e.g. effect of medication)
SessionByGroupBoxPlots <- function(dataframe, x, x.ticks, groups){
        
        library(reshape2)
        
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint == x.ticks[1] | timepoint == x.ticks[2]) %>%
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
                geom_density(data = dataframe %>% filter(timepoint==x.ticks[1]), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                geom_density(data = dataframe %>% filter(timepoint==x.ticks[2]), aes(value, fill = group), alpha = 1/3, lwd = 2) +
                theme_cowplot(font_size = 25) +
                scale_color_brewer(palette = 'Set1') +
                scale_fill_brewer(palette = 'Set1')
        
        plots <- plot_grid(g_SbyGbox, g_SbyGdens, labels = 'AUTO', nrow = 1, ncol = 2)
        title <- ggdraw() + draw_label('Time x Group interaction plot', fontface='bold', size = 35)
        plot_grid(title, plots, ncol=1, rel_heights=c(0.1, 1))
        
}
x <- c('timepoint')
x.ticks <- c('V1','V3')
#groups <- c('Up3OfTotal', 'Up3OnTotal')
#SessionByGroupBoxPlots(df, x, x.ticks, groups)
groups <- c('Response.Time_Ext', 'Response.Time_Int2', 'Response.Time_Int3')
SessionByGroupBoxPlots(df.wide, x, x.ticks, groups)

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
y <- c('Up3OfTotal.1YearProg', 'Up3OfBradySum.1YearProg',
       'Up3OfTotal.1YearProg.Perc', 'Up3OfBradySum.1YearProg.Perc')
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

##### CHECK: Outliers in relevant variables #####

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
is_outlier <- function(x, coef=1.5) {
        return(x < quantile(x, 0.25) - coef * IQR(x) | x > quantile(x, 0.75) + coef * IQR(x))
}

#Visit1
y <- c('Up3OfTotal', 'Up3OnTotal',
       'Up3OfBradySum', 'Up3OnBradySum',
       'EstDisDurYears', 'Age',
       'Response.Time_Ext', 'Response.Time_Int2', 'Response.Time_Int3',
       'Percentage.Correct_Ext', 'Percentage.Correct_Int2', 'Percentage.Correct_Int3')
visit1 = c('V1')
outlier.pseudo1 <- c()
for(n in unique(y)){
        
        g <- SingleSessionBoxDensPlots(df.wide, n, visit1)
        print(g)
        
        outliers.visit1 <- df.wide %>% 
                select(pseudonym, one_of(n), timepoint) %>% 
                filter(timepoint==visit1) %>% 
                na.omit %>%
                mutate(outlier = is_outlier(pull(.,var=2))) %>%
                filter(outlier == TRUE) %>%
                select(pseudonym, one_of(n), timepoint)
        print(outliers.visit1)
        
        outlier.pseudo1 <- unique(c(outlier.pseudo1, outliers.visit1$pseudonym))
}

#Visit2
y <- c('Up3OfTotal', 'Up3OnTotal',
       'Up3OfBradySum', 'Up3OnBradySum',
       'Up3OfTotal.1YearProg', 'Up3OfBradySum.1YearProg',
       'Up3OnTotal.1YearProg', 'Up3OnBradySum.1YearProg',
       'TimeToFUYears')
visit2 = c('V2')
outlier.pseudo2 <- c()
for(n in unique(y)){
        
        g <- SingleSessionBoxDensPlots(df.wide, n, visit2)
        print(g)
        
        outliers.visit2 <- df.wide %>% 
                select(pseudonym, one_of(n), timepoint) %>% 
                filter(timepoint==visit2) %>% 
                na.omit %>%
                mutate(outlier = is_outlier(pull(.,var=2))) %>%
                filter(outlier == TRUE) %>%
                select(pseudonym, one_of(n), timepoint)
        print(outliers.visit2)
        
        outlier.pseudo2 <- unique(c(outlier.pseudo2, outliers.visit2$pseudonym))
        
}

#Visit3
y <- c('Response.Time_Ext', 'Response.Time_Int2', 'Response.Time_Int3',
       'Percentage.Correct_Ext', 'Percentage.Correct_Int2', 'Percentage.Correct_Int3')
visit3 = c('V3')
outlier.pseudo3 <- c()
for(n in unique(y)){
        
        g <- SingleSessionBoxDensPlots(df.wide, n, visit3)
        print(g)
        
        outliers.visit3 <- df.wide %>% 
                select(pseudonym, one_of(n), timepoint) %>% 
                filter(timepoint==visit3) %>% 
                na.omit %>%
                mutate(outlier = is_outlier(pull(.,var=2))) %>%
                filter(outlier == TRUE) %>%
                select(pseudonym, one_of(n), timepoint)
        print(outliers.visit3)
        
        outlier.pseudo3 <- unique(c(outlier.pseudo3, outliers.visit3$pseudonym))
}

outlier.pseudo.all <- unique(c(outlier.pseudo1, outlier.pseudo2, outlier.pseudo3))
cat('Total number of outliers among selected variables:', length(outlier.pseudo.all))

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








