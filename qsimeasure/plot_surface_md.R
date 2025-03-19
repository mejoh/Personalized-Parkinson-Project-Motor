library(tidyverse)
library(ggseg)
library(rstatix)
library(effectsize)
library(cowplot)

# Read data
df <- read_csv('P:/3024006.02/wd/ggseg_all_data_FSLmd.csv')
df.s <- df %>%
    select(pseudonym,ParticipantType,TimepointNr,starts_with('L_'),starts_with('R_')) %>%
    select(-contains('pSN')) %>% select(-contains('aSN')) %>%
    select(-contains('thickavg')) %>% select(-contains('surfavg'))
colnames(df.s) <- colnames(df.s) %>% str_remove('_dti')
colnames(df.s) <- colnames(df.s) %>% str_replace('L_','lh_')
colnames(df.s) <- colnames(df.s) %>% str_replace('R_','rh_')

df.s <- df.s %>% pivot_longer(cols = lh_caudalanteriorcingulate:rh_insula,
                    names_to = 'label', values_to = 'md') %>%
    pivot_wider(id_cols = c('pseudonym','ParticipantType','label'),
                names_from = 'TimepointNr',
                names_prefix = 'T',
                values_from = 'md') %>%
    mutate(T2sub0=T2-T0,
           ParticipantType=factor(ParticipantType)) %>%
    na.omit()

# Generate table
tab <- c()
for(lab in unique(df.s$label)){
    
    tmp <- df.s %>%
        filter(label==lab)
    t <- t_test(tmp, T2sub0 ~ ParticipantType, var.equal=F)
    t_stat <- t$statistic %>% unname()
    p_stat <- t$p
    d <- tmp %>%
        effectsize::cohens_d('T2sub0','ParticipantType',data=.,pooled_sd=F)
    d_stat <- d$Cohens_d
    tab <- bind_rows(tab,
                     tibble(label=lab,t=t_stat,p=p_stat,d=d_stat))
    
}
tab <- tab %>%
    mutate(sig = if_else(p < 0.05, 1, 0))

# Plot
tab %>%
    filter(sig != 1) %>%
    select(label,d) %>%
    ggplot() + 
    geom_brain(atlas = dk,
               position = position_brain(hemi ~ side),
               aes(fill = d)) + 
    theme_bw() + 
    scale_fill_continuous(limits=c(0,1),breaks=seq(0,1,0.2))


colnamesggseg_data <- read_csv('P:/3024006.02/wd/ggseg_stats_CLINvsMD_FSLmd.csv')
ggseg_data <- colnamesggseg_data %>%
    mutate(
        region = case_when(
            label == 'bi_inferiorparietal_dti' ~ 'inferior parietal',
            label == 'bi_superiorparietal_dti' ~ 'superior parietal',
            label == 'bi_precuneus_dti' ~ 'precuneus',
            label == 'bi_supramarginal_dti' ~ 'supramarginal',
            label == 'bi_paracentral_dti' ~ 'paracentral',
            label == 'bi_postcentral_dti' ~ 'postcentral',
            label == 'bi_precentral_dti' ~ 'precentral',
            label == 'bi_superiorfrontal_dti' ~ 'superior frontal',
            label == 'bi_caudalmiddlefrontal_dti' ~ 'caudal middle frontal',
            label == 'bi_premotor_dti' ~ NA,
            label == 'bi_sensorimotor_dti' ~ NA,
            label == 'bi_parietal_dti' ~ NA
        ),
        sig = if_else(p_Group_x_Time < 0.05, 1, 0)
    )
ggseg_data %>%
    select(region,cohens_d) %>%
    na.omit() %>%
    ggplot() + 
    geom_brain(atlas = dk,
               position = position_brain(hemi ~ side),
               aes(fill = cohens_d)) + 
    theme_bw()


labs_subset <- data.frame(
    region = ggseg_data$region %>% unique(),
    reg_col = ggseg_data$region %>% unique()
)
g <- ggplot(labs_subset) +
    geom_brain(atlas = dk,
               aes(fill = reg_col),
               colour = 'black',
               hemi = 'left') +
    scale_fill_brain2(dk$palette[labs_subset$region] ) +
    labs(fill = 'Regions of interest') +
    theme_void()
print(g)
save_plot('H:/sysneu/marjoh/Visualization/R_LongitudinalComparisonFmri/CorticalMD/ggseg_rois.png',
          g, dpi=300, device='png', base_width = 3.5)

g <- ggseg_data %>%
    filter(sig == 1) %>%
    select(region,cohens_d) %>%
    na.omit() %>%
    ggseg(., atlas = dk,
          colour = 'black',
          size = .1,
          hemisphere = 'left',
          mapping = aes(fill = cohens_d)) +
    theme_void() + 
    labs(fill = 'Cohen\'s d') + 
    theme(legend.key.size = unit(0.25,'cm'),
          legend.key.width = unit(0.35,'cm')) + 
    scale_fill_continuous(limits=c(-1,0),breaks=seq(0,-1,-0.25))
print(g)
save_plot('H:/sysneu/marjoh/Visualization/R_LongitudinalComparisonFmri/CorticalMD/ggseg_cohensd.png',
          g, dpi=300, device='png', base_width = 4)


# someData <- tibble(
#     region = rep(c("transverse temporal", "insula",
#                    "precentral","superior parietal"), 2), 
#     p = sample(seq(0,.5,.001), 8),
#     groups = c(rep("g1", 4), rep("g2", 4))
# )
# someData %>%
#     group_by(groups) %>%
#     ggplot() +
#     geom_brain(atlas = dk, 
#                position = position_brain(hemi ~ side),
#                aes(fill = p)) +
#     facet_wrap(~groups) + theme_bw()
