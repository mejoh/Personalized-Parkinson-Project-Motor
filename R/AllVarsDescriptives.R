source('M:/scripts/Personalized-Parkinson-Project-Motor/R/initialize_funcs.R')
df <- CombinedDatabase()

##### Libraries #####
#source("M:/scripts/RainCloudPlots/tutorial_R/R_rainclouds.R")
library(tidyverse)
library(cowplot)
#####

##### Summary stats #####
df.rt <- reshape_by_task(df, lengthen = TRUE)
# Response times by timepoint and condition
df.rt %>%
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
df.rt %>%
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
df.clin  <- df %>% 
        select(pseudonym, timepoint, Up3OfTotal, Up3OnTotal, Up3OfTotal.1YearDelta, Up3OnTotal.1YearDelta, Up3OfTotal.1YearROC, Up3OnTotal.1YearROC)
df.clin <- reshape_by_medication(df.clin, lengthen = TRUE)
df.clin <- df.clin %>%
        pivot_wider(names_from='Subscore',
                    names_prefix='Up3',
                    values_from = 'Severity')
levels(df.clin$Medication) <- c('Off','On')
df.clin %>%
        filter(timepoint != 'V3') %>%
        group_by(timepoint, Medication) %>%
        summarise(n=n(),
                  avg=mean(Up3Total, na.rm = TRUE),
                  sd=sd(Up3Total, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(Up3Total)))

# 1-year delta(Up3OfTotal) by medication
df.clin %>%
        filter(timepoint == 'V2') %>%
        group_by(timepoint, Medication) %>%
        summarise(n=n(),
                  avg=mean(Up3Total.1YearROC, na.rm = TRUE),
                  sd=sd(Up3Total.1YearROC, na.rm = TRUE),
                  se=sd/(sqrt(n)),
                  lowerCI=(avg-(1.96*se)),
                  upperCI=(avg+(1.96*se)),
                  missing=sum(is.na(Up3Total.1YearROC)))

# Brain activity
# IN PROGRESS

#####

##### Demographics #####

df.demo <- df %>%
        select(pseudonym,
               timepoint, 
               Age, 
               Gender, 
               EstDisDurYears, 
               TimeToFUYears, 
               Up3OfHoeYah, 
               MostAffSide, 
               PrefHand, 
               Responding.Hand)

categorical.vars <- c(2,4,7,8,9,10)
for(i in categorical.vars){
        cat(colnames(df.demo)[i])
        print(table(df.demo[,i]))
        cat('\n')
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

##### Collection of plotting functions #####

# Box and density plots for exploring Time x Group interactions (e.g. effect of medication)
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
SessionByGroupBoxPlots(df, x, x.ticks, groups)

##### DEPRECATED: Tremor #####
df %>%
        filter(timepoint=='V1') %>%
        select(pseudonym, TremorDominant, Condition, Response.Time) %>%
        na.omit %>% 
        ggplot(aes(x=TremorDominant, y=Response.Time)) +
                geom_boxplot(notch = TRUE) +
                facet_grid(. ~ Condition)

df %>%
        filter(timepoint=='V2', Condition=='Ext') %>%
        select(pseudonym, TremorDominant, Up3OfTotal.1YearProg, Up3OfBradySum.1YearProg) %>%
        na.omit %>% 
        ggplot(aes(x=TremorDominant, y=Up3OfBradySum.1YearProg)) +
        geom_boxplot(notch = TRUE)
#####

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
y <- c('Up3OfTotal.1YearDelta', 'Up3OfTotal.1YearROC',
       'Up3OnTotal.1YearDelta', 'Up3OnTotal.1YearROC')
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
                geom_smooth(method = 'lm', color = 'black', se = FALSE, lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25)
        
        progvar <- paste(y, '.1YearDelta', sep = '')
        
        g_scatter2 <- dataframe %>%
                ggplot(aes_string(x = x, y = y)) + 
                geom_point(size = 3) +
                geom_line(aes_string(group = 'pseudonym', color=progvar), lwd = 1, alpha = 0.7) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient2(low = 'blue', high = 'red') + 
                geom_smooth(method = 'lm', color = 'black', se = FALSE, lwd = 1, alpha = 0.7)
        
        mean_progression <- mean(unlist(dataframe[, colnames(dataframe) == progvar]), na.rm = TRUE)
        
        g_scatter3 <- dataframe %>% filter(timepoint == 'V2') %>%
                ggplot(aes_string(x = x, y = progvar, colour = progvar)) +
                geom_point(size = 3) +
                theme_cowplot(font_size = 25) +
                scale_color_gradient(low = 'blue', high = 'red') +
                geom_hline(yintercept = mean_progression, linetype = 3, lwd = 1) +
                geom_smooth(method = 'lm', color = 'black', se = FALSE, lwd = 1, alpha = 0.7)
        
        plots <- plot_grid(g_scatter1, g_scatter2, g_scatter3, labels = 'AUTO', nrow = 2, ncol = 2)
        plot_grid(plots, ncol=1, rel_heights=c(0.1, 1))
        
}
y <- c('Up3OnTotal')
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
                geom_point(size = 3, alpha = 1/3) +
                geom_smooth(method = 'lm', se = FALSE, color='darkred') +
                theme_cowplot(font_size = 25)
        g_scatter + labs(title = paste(y, ' ~ ', x, '   Timepoint =', visit))
}
y <- c('Up3OnTotal.1YearDelta', 'Up3OnTotal.1YearROC')
x <- c('Up3OnTotal')
visit <- c('V1')
for(n in unique(y)){
        g <- ScatterPlotsSimple(df, n, x, visit)
        print(g)
}

# Lineplots for lmer
TimeSlopesBySubjectPlots <- function(dataframe, y, x, group){
        dataframe <- dataframe %>%
                filter(MultipleSessions == 'Yes') %>%
                filter(timepoint != 'V3')
        
        var1 <- paste('Up3Of', y, sep = '')
        progvar1 <- paste('Up3Of', y, '.1YearDelta', sep = '')
        g_line1 <- ggplot(dataframe, aes_string(x=x, y=var1, group=group)) +
                geom_line(aes_string(color=progvar1), lwd = 1.2,  alpha = .7) + 
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25)
        g_line1
        
        var2 <- paste('Up3Of', y, sep = '')
        progvar2 <- paste('Up3On', y, '.1YearDelta', sep = '')
        g_line2 <- ggplot(dataframe, aes_string(x=x, y=var2, group=group)) +
                geom_line(aes_string(color=progvar2), lwd = 1.2,  alpha = .7) + 
                scale_color_gradient2(low = 'blue', high = 'red') +
                geom_jitter(width=0.01, size=2, shape=21, fill='white') +
                theme_cowplot(font_size = 25)
        g_line2
        
        library(ggpubr)
        ggarrange(g_line1, g_line2, ncol=2)
}
y <- c('Total')
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
                group_by(timepoint, Medication) %>%
                na.omit
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
        
        g <- SingleSessionBoxDensPlots(df, n, visit1)
        print(g)
        
        outliers.visit1 <- df %>% 
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
       'Up3OfTotal.1YearDelta', 'Up3OfBradySum.1YearDelta',
       'Up3OnTotal.1YearDelta', 'Up3OnBradySum.1YearDelta',
       'TimeToFUYears')
visit2 = c('V2')
outlier.pseudo2 <- c()
for(n in unique(y)){
        
        g <- SingleSessionBoxDensPlots(df, n, visit2)
        print(g)
        
        outliers.visit2 <- df %>% 
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
        
        g <- SingleSessionBoxDensPlots(df, n, visit3)
        print(g)
        
        outliers.visit3 <- df %>% 
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

##### Clustering on motor symptoms and their progression #####

## K-medoids ##

library(fpc)
library(cluster)
library(factoextra)

# Data preparation
dat <- df %>%
        filter(timepoint == 'V1' & MultipleSessions == 'Yes') %>%
        select(pseudonym,
               Up3OfTotal, Up3OfBradySum, Up3OfRestTremAmpSum, Up3OfRigiditySum,
               Up3OfTotal.1YearDelta, Up3OfBradySum.1YearDelta, Up3OfRestTremAmpSum.1YearDelta, Up3OfRigiditySum.1YearDelta,
               EstDisDurYears, Gender, Age) %>%
        na.omit

dat.scaled <- dat %>%
        select(-c(pseudonym, Up3OfTotal, Up3OfTotal.1YearDelta, EstDisDurYears, Gender, Age)) %>%
        mutate(Up3OfBradySum = scale(Up3OfBradySum),
               Up3OfRestTremAmpSum = scale(Up3OfRestTremAmpSum),
               Up3OfRigiditySum = scale(Up3OfRigiditySum),
               Up3OfBradySum.1YearDelta = scale(Up3OfBradySum.1YearDelta),
               Up3OfRestTremAmpSum.1YearDelta = scale(Up3OfRestTremAmpSum.1YearDelta),
               Up3OfRigiditySum.1YearDelta = scale(Up3OfRigiditySum.1YearDelta))

# K-medoids
clust <- pamk(dat.scaled, metric = 'manhattan', stand = FALSE)
fviz_nbclust(dat.scaled, FUNcluster = pam)
clust.res <- pam(dat.scaled, 2, metric = 'manhattan', stand = FALSE)
fviz_cluster(clust.res)
dat.clust <- bind_cols(dat, cluster = clust.res$clustering)

# Descriptives
dat.clust %>%
        group_by(cluster, Gender) %>%
        summarise(Avg=mean(Up3OfTotal), SD=sd(Up3OfTotal),
                  AvgDelta=mean(Up3OfTotal.1YearDelta), SDDelta=sd(Up3OfTotal.1YearDelta),
                  DisDur=mean(EstDisDurYears), Age=mean(Age))

ggplot(dat.clust, aes( x= cluster, y = Up3OfTotal, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfBradySum, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfRestTremAmpSum, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfRigiditySum, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfTotal.1YearDelta, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfBradySum.1YearDelta, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfRestTremAmpSum.1YearDelta, group = cluster)) + 
        geom_boxplot()
ggplot(dat.clust, aes( x= cluster, y = Up3OfRigiditySum.1YearDelta, group = cluster)) + 
        geom_boxplot()

ggplot(dat.clust, aes(x=Up3OfTotal,y=Up3OfTotal.1YearDelta)) + 
        geom_smooth(method='lm') + 
        geom_point() +
        facet_grid(.~cluster)

dat.clust %>%
        select(Up3OfTotal, Up3OfBradySum, Up3OfRestTremAmpSum, Up3OfRigiditySum,
               Up3OfTotal.1YearDelta, Up3OfBradySum.1YearDelta, Up3OfRestTremAmpSum.1YearDelta, Up3OfRigiditySum.1YearDelta) %>%
        pairs
        

#####








