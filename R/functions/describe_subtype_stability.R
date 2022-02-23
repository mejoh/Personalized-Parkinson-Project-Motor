describe_subtype_stability <- function(df_stability, title='Subtype stability across sessions'){
    
    # Histogram
    g <- ggplot(df_stability, aes(x=baseline, fill=visit1)) +
        geom_histogram(stat = 'count', color='black', size =0.6) + 
        theme_cowplot() +
        xlab('Subtype at baseline') +
        ylab('Count') +
        scale_x_discrete(label = c('MMP','IM','DM')) +
        scale_fill_viridis_d(label = c('MMP','IM','DM'), name = 'Subtype at \nfollow-up', option='mako', alpha=0.7) +
        labs(title=title)
    
    # Proportions
    n.MMP <- sum(df_stability$baseline == '1_Mild-Motor')
    n.IM <- sum(df_stability$baseline == '2_Intermediate')
    n.DM <- sum(df_stability$baseline == '3_Diffuse-Malignant')
    n.Total <- n.MMP + n.IM + n.DM
    
    stability.ba_MMP <- df_stability %>%
        filter(SubtypeMatch == FALSE) %>%
        filter(baseline=='1_Mild-Motor') %>%
        mutate(MMPtoIM = visit1 == '2_Intermediate',
               MMPtoDM = visit1 == '3_Diffuse-Malignant')
    MMP.nswitch <- nrow(stability.ba_MMP)
    MMP.ntoIM <- sum(stability.ba_MMP$MMPtoIM)
    MMP.ntoDM <- sum(stability.ba_MMP$MMPtoDM)
    
    stability.ba_MMP <- df_stability %>%
        filter(SubtypeMatch == FALSE) %>%
        filter(baseline=='2_Intermediate') %>%
        mutate(IMtoMMP = visit1 == '1_Mild-Motor',
               IMtoDM = visit1 == '3_Diffuse-Malignant')
    IM.nswitch <- nrow(stability.ba_MMP)
    IM.ntoMMP <- sum(stability.ba_MMP$IMtoMMP)
    IM.ntoDM <- sum(stability.ba_MMP$IMtoDM)
    
    stability.ba_MMP <- df_stability %>%
        filter(SubtypeMatch == FALSE) %>%
        filter(baseline=='3_Diffuse-Malignant') %>%
        mutate(DMtoMMP = visit1 == '1_Mild-Motor',
               DMtoIM = visit1 == '2_Intermediate')
    DM.nswitch <- nrow(stability.ba_MMP)
    DM.ntoMMP <- sum(stability.ba_MMP$DMtoMMP)
    DM.ntoIM <- sum(stability.ba_MMP$DMtoIM)
    
    # Total switches
    n.Switches <- (MMP.nswitch + IM.nswitch + DM.nswitch)
    msg <- paste('Total: ', n.Total, ', Switches: ', n.Switches, ', Percentage: ', round(n.Switches/n.Total, digits=3)*100, sep='')
    print(msg)
    # Switches in MMP
    msg <- paste('In MMP, ', MMP.nswitch, ' switched. ', MMP.ntoIM, ' switched to IM, ', MMP.ntoDM, ' switched to DM', sep = '')
    print(msg)
    # Switches in IM
    msg <- paste('In IM, ', IM.nswitch, ' switched. ', IM.ntoMMP, ' switched to MMP, ', IM.ntoDM, ' switched to DM', sep = '')
    print(msg)
    # Switches in DM
    msg <- paste('In DM, ', DM.nswitch, ' switched. ', DM.ntoMMP, ' switched to MMP, ', DM.ntoIM, ' switched to IM', sep = '')
    print(msg)
    
    print(g)
    
}