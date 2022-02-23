pieplot_perc <- function(summarytab, title='', hide_legend=FALSE){
        
    bp <- summarytab %>%
        ggplot(aes(x="", y=Score, fill=Symptom)) + 
        geom_bar(width = 1, stat = "identity", color='black', size = 1) +
        scale_y_reverse()
    
    pie <- bp + 
        coord_polar("y", start=0)
    
    blank_theme <- theme_minimal()+
        theme(
            axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            panel.border = element_blank(),
            panel.grid=element_blank(),
            axis.ticks = element_blank(),
            plot.title=element_text(size=35, face="bold")
        )
    
    p <- pie + scale_fill_viridis_d(alpha=0.6,
                                    labels = str_sub(summarytab$Symptom,start=3),
                                    guide = guide_legend(reverse = FALSE)) +
            blank_theme +
            theme(axis.text.x=element_blank(),
                  legend.key.size = unit(1.5,'cm'),
                  legend.text = element_text(size=20),
                  legend.title = element_text(size=25)) +
            geom_text(aes(y = 1-c(0, cumsum(Score)[-length(Score)]) - Score/2, 
                          label = percent(Score)), size=6) +
            labs(title = title)
    
    if(hide_legend){
            p <- p + theme(legend.position = 'none')
    }
    
    p
    
}