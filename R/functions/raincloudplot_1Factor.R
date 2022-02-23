raincloudplot_1Factor <- function(data, y, groupvar, title='', xlab='', ylab='', xticklabs=''){
    
    # Generate summary stats for error bars
    sumrepdat <- data %>% 
        group_by(.data[[groupvar]]) %>%
        summarise(n=n(), mean=mean(.data[[y]], na.rm=TRUE),
                  median=median(.data[[y]], na.rm=TRUE),
                  sd=sd(.data[[y]], na.rm=TRUE), se=sd/sqrt(n), ci=se+1.96)
    
    # Generate raincloud
    ggplot(data, aes_string(x = groupvar, y = y)) +
        geom_flat_violin(aes_string(fill = groupvar),
                         position = position_nudge(x = .1, y = 0), 
                         adjust = 1.5, 
                         trim = FALSE, 
                         alpha = .7, 
                         colour = 'black', show.legend = FALSE) +
        geom_jitter(aes_string(x = paste('as.numeric(',groupvar,')-.1', sep=''), y = y, colour = groupvar),
                    size = 2,
                    shape = 19,
                    width = .01,
                    alpha = .5, color='black', show.legend = FALSE) +
        geom_boxplot(aes_string(x = groupvar, y = y, fill = groupvar),
                     outlier.shape = NA, 
                     alpha = .7, 
                     width = .1, 
                     colour = "black", show.legend = FALSE) +
        geom_point(data = sumrepdat, 
                   aes_string(x = paste('as.numeric(',groupvar,')+.1', sep=''), y = 'mean',
                              group = groupvar), shape = 18, show.legend = FALSE, size=3, color='black') +
        geom_errorbar(data = sumrepdat, 
                      aes_string(x = paste('as.numeric(',groupvar,')+.1',sep=''), y = 'mean',
                                 ymin = 'mean-se', ymax = 'mean+se', group = groupvar),
                      width = .07, show.legend = FALSE, color='black') +
        scale_x_discrete(labels = xticklabs) +
        scale_colour_viridis_d(option='mako') +
        scale_fill_viridis_d(option='mako') +
        ggtitle(title) + xlab(xlab) + ylab(ylab) + 
        coord_cartesian(xlim = c(1.2, NA), clip = "off") +
        theme_cowplot(font_size = 20)
}