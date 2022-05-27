raincloudplot_2Factor <- function(data, y, groupvar, title='', xlab='', ylab='',
                                  xticklabs='', legend_title='', legend_labels='',
                                  print_summary = FALSE, provided_summary = 'None',
                                  color_scheme='mako', legend_position = ''){
    
        
        library(extrafont)
        loadfonts(device='win',quiet = TRUE)
        
        g1 <- groupvar[1]
        g2 <- groupvar[2]
        
        # Generate summary stats for error bars
        if(!is_tibble(provided_summary)){
                sumrepdat <- data %>% 
                        group_by(.data[[g1]], .data[[g2]]) %>%    
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
        # ggplot(data, aes_string(x = g2, y = y, fill = g1)) +
        #         geom_flat_violin(aes_string(fill = g1),
        #                          position = position_nudge(x = .1, y = 0), 
        #                          adjust = 1.5, 
        #                          trim = FALSE, 
        #                          alpha = .5, 
        #                          colour = 'black') +
        #         geom_jitter(aes_string(x = paste('as.numeric(',g2,')-.1', sep=''), y = y, colour = g1),
        #                     size = 2,
        #                     shape = 19,
        #                     width = .04,
        #                     alpha = .8, show.legend = FALSE) +
        #         geom_boxplot(aes_string(x = g2, y = y, fill = g1),
        #                      outlier.shape = NA, 
        #                      alpha = .7, 
        #                      width = .1, 
        #                      colour = "black", show.legend = FALSE) +
        #         geom_line(data = sumrepdat,
        #                   aes_string(x = paste('as.numeric(',g2,')+.15'), y = 'mean', group = g1, color = g1),
        #                   linetype = 3, size = .9, show.legend = FALSE) +
        #         geom_point(data = sumrepdat, 
        #                    aes_string(x = paste('as.numeric(',g2,')+.1', sep=''), y = 'mean',
        #                               group = g1, color = g1), shape = 18, size=3, show.legend = FALSE) +
        #         geom_errorbar(data = sumrepdat, 
        #                       aes_string(x = paste('as.numeric(',g2,')+.1',sep=''), y = 'mean',
        #                                  ymin = 'mean-se', ymax = 'mean+se', group = g1, color = g1),
        #                       width = .07, show.legend = FALSE) +
        #         scale_x_discrete(labels = xticklabs) +
        #         scale_colour_viridis_d(option=color_scheme, begin = .1, end = .6, direction = -1) +
        #         scale_fill_viridis_d(option=color_scheme, begin = .1, end = .6, alpha = .8,
        #                              direction = -1, labels = legend_labels) +
        #         ggtitle(title) + xlab(xlab) + ylab(ylab) + 
        #         guides(fill=guide_legend(title=legend_title, reverse = FALSE)) + 
        #         coord_cartesian(xlim = c(1.2, NA), clip = "off") +
        #         theme_cowplot(font_size = 20)
        ggplot(data, aes_string(x = g2, y = y, fill = g1)) +
                geom_flat_violin(aes_string(fill = g1),
                                 position = position_nudge(x = .35, y = 0), 
                                 adjust = 1.5, 
                                 trim = TRUE, 
                                 alpha = .5, 
                                 colour = 'black', width = 0.3,size=1.6) +
                geom_point(aes_string(x = paste('as.numeric(',g2,')-0', sep=''), y = y, colour = g1),
                            size = 5,
                            shape = 19,
                            alpha = .3, show.legend = FALSE,
                           position = position_jitterdodge(dodge.width = .6, jitter.width = .3)) +
                geom_boxplot(aes_string(x = g2, y = y, fill = g1),
                             outlier.shape = NA, 
                             alpha = .7, 
                             width = .6, 
                             size=1.6,
                             colour = "black", show.legend = FALSE) +
                geom_point(data = sumrepdat, 
                           aes_string(x = paste('as.numeric(',g2,')+0', sep=''), y = 'mean',
                                      group = g1, color = g1),
                           shape = 18, size=10, show.legend = FALSE,
                           position = position_dodge(width = .6), color='yellow3') +
                scale_x_discrete(labels = xticklabs) +
                scale_colour_viridis_d(option=color_scheme, begin = .1, end = .6, direction = -1) +
                scale_fill_viridis_d(option=color_scheme, begin = .1, end = .6, alpha = .8,
                                     direction = -1, labels = legend_labels) +
                ggtitle(title) + xlab(xlab) + ylab(ylab) + 
                guides(fill=guide_legend(title=legend_title, reverse = FALSE,
                                         title.position = 'left', label.position = 'right')) +
                coord_cartesian(xlim = c(1.2, NA), clip = "off") +
                theme_cowplot(font_size = 60, font_family = 'Calibri') +
                theme(legend.position = legend_position,
                      legend.key.size = unit(1,'cm'))
        
}