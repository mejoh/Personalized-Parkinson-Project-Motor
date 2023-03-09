raincloudplot_1Factor <- function(data, y, groupvar, title='', xlab='', ylab='',
                                  xticklabs='', print_summary=FALSE, provided_summary='None',
                                  color_scheme='mako'){
    
        
        library(extrafont)
        loadfonts(device='win',quiet = TRUE)
        
        # Generate summary stats for error bars
        if(!is_tibble(provided_summary)){
                sumrepdat <- data %>% 
                        group_by(.data[[groupvar]]) %>%
                        summarise(n=n(), mean=mean(.data[[y]], na.rm=TRUE),
                                  median=median(.data[[y]], na.rm=TRUE),
                                  sd=sd(.data[[y]], na.rm=TRUE), se=sd/sqrt(n), ci=se+1.96)
        }else{
                sumrepdat <- provided_summary
        }
        
        if(print_summary){
                print(sumrepdat)
        }
        
        # Generate raincloud
        # ggplot(data, aes_string(x = groupvar, y = y)) +
        #     geom_flat_violin(aes_string(fill = groupvar),
        #                      position = position_nudge(x = .1, y = 0), 
        #                      adjust = 1.5, 
        #                      trim = FALSE, 
        #                      alpha = .5, 
        #                      colour = 'black', show.legend = FALSE) +
        #     geom_jitter(aes_string(x = paste('as.numeric(',groupvar,')-.1', sep=''), y = y, colour = groupvar),
        #                 size = 2,
        #                 shape = 19,
        #                 width = .01,
        #                 alpha = .5, color='black', show.legend = FALSE) +
        #     geom_boxplot(aes_string(x = groupvar, y = y, fill = groupvar),
        #                  outlier.shape = NA, 
        #                  alpha = .7, 
        #                  width = .1, 
        #                  colour = "black", show.legend = FALSE) +
        #     geom_line(data = sumrepdat,
        #               aes_string(x = paste('as.numeric(',groupvar,')+.1'), y = 'mean'),
        #               linetype = 3, size = .9, show.legend = FALSE, color='black') +
        #     geom_point(data = sumrepdat, 
        #                aes_string(x = paste('as.numeric(',groupvar,')+.1', sep=''), y = 'mean',
        #                           group = groupvar), shape = 18, show.legend = FALSE, size=3, color='black') +
        #     geom_errorbar(data = sumrepdat, 
        #                   aes_string(x = paste('as.numeric(',groupvar,')+.1',sep=''), y = 'mean',
        #                              ymin = 'mean-se', ymax = 'mean+se', group = groupvar),
        #                   width = .07, show.legend = FALSE, color='black') +
        #     scale_x_discrete(labels = xticklabs) +
        #     scale_colour_viridis_d(option=color_scheme, begin = .1, end = .6, direction = -1) +
        #     scale_fill_viridis_d(option=color_scheme, begin = .1, end = .6, direction = -1) +
        #     ggtitle(title) + xlab(xlab) + ylab(ylab) + 
        #     coord_cartesian(xlim = c(1.2, NA), clip = "off") +
        #     theme_cowplot(font_size = 20)
        ggplot(data, aes_string(x = groupvar, y = y)) +
                geom_flat_violin(aes_string(fill = groupvar),
                                 position = position_nudge(x = .25, y = 0), 
                                 adjust = 1.5, 
                                 trim = TRUE, 
                                 alpha = .5, 
                                 colour = 'black', show.legend = FALSE, width = 0.4, linewidth=1.2) +
                geom_point(aes_string(x = paste('as.numeric(',groupvar,')-0', sep=''), y = y, fill = groupvar),
                           size = 2,
                           shape = 19,
                           alpha = .3, show.legend = FALSE,
                           position = position_jitterdodge(dodge.width = .6, jitter.width = .2),color='black') +
                geom_boxplot(aes_string(x = groupvar, y = y, fill = groupvar),
                             outlier.shape = NA, 
                             alpha = .7, 
                             width = .4, 
                             size=1.2,
                             colour = "black", show.legend = FALSE) +
                geom_point(data = sumrepdat, 
                           aes_string(x = paste('as.numeric(',groupvar,')+0', sep=''), y = 'mean',
                                      group = groupvar, color = groupvar),
                           shape = 18, size=5, show.legend = FALSE,
                           position = position_dodge(width = .6), color='yellow3') +
                scale_x_discrete(labels = xticklabs) +
                scale_colour_viridis_d(option=color_scheme, begin = 0, end = .6, direction = 1) +
                scale_fill_viridis_d(option=color_scheme, begin = 0, end = .6, direction = 1, alpha = .8) +
                ggtitle(title) + xlab(xlab) + ylab(ylab) + 
                coord_cartesian(xlim = c(1.2, NA), clip = "off") +
                theme_cowplot(font_size = 16, font_family = 'Calibri')
    
}