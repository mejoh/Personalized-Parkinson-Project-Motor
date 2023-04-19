## Simulate data resembling bradykinesia progression and change in brain
## activity. Test various statistical techniques to see which ones best retrieve
## the known associations.
## https://stirlingcodingclub.github.io/simulating_data/index.html

library(tidyverse)
library(MASS)
library(GGally)

set.seed(160)
N <- 50
cv_mat <- rbind(c( 1.00, -0.20, -0.50),
                c(-0.20,  1.00,  0.30),
                c(-0.50,  0.30,  1.00))
mns_1 <- c(22.05, 3.24, 10.51)
subj_mns <- bind_cols(subj_mns_1=rnorm(N/2, mean = mns_1[1], sd=1),
                      subj_mns_2=rnorm(N/2, mean = mns_1[2], sd=1),
                      subj_mns_3=rnorm(N/2, mean = mns_1[3], sd=1))
subj_id <- rep(x = seq(1,N/2), times = 2)
time_id <- c(rep(x = 0, times = N/2), rep(x = 1, times = N/2))
sim_data_1 <- mvrnorm(n = N, mu = mns_1, Sigma = cv_mat)
colnames(sim_data_1) <- c('Bradykinesia','Cortex','Putamen')
sp_1 <- data.frame(subj_id, time_id, sim_data_1) %>% 
        as_tibble() %>%
        arrange(subj_id, time_id) %>%
        mutate(subj_id = factor(subj_id),
               time_id = factor(time_id),
               Bradykinesia = round(Bradykinesia))

# One group
# Two visits
# Two continuous scores
 # Both increasing
 # Both decreasing
 # One increasing, one decreasing
# Random missing values
# Inter-subject relationship
 # Positive
 # Negative
# Intra-subject relationship
 # Positive
 # Negative
# Covariates
 # Time-invariant categorical
 # Time-invariant continuous
 # Time-varying categorical
 # Time-varying continuous

# Analyses
 # Raw change
 # Single-corrected raw change
 # Double-corrected raw change
 # Growth curve modelling
  # Interaction with time
  # Disaggregation
 # rmcorr
 # Spearman




