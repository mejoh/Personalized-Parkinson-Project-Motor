install.packages('sjstats')
library(sjstats)
library(pwr)

dc <- 15 / 14.5 # Detectable contrast
df.n <- NULL             # Degrees of freedom numerator (animals per cluster)
power = 0.8            # Power
sig.level = 0.05       # Significance level
k = 4                 # Cluster groups (Timepoints?)
n = 4              # Number of observations per cluster group
icc <- 0.05            # Intraclass correlation

samplesize_mixed(
 eff.size = dc,
 df.n = df.n,
 power = power,
 sig.level = sig.level,
 k = k,
 n = n,
 icc = icc
)


install.packages('WebPower')
library(WebPower)
wp.rmanova(n = NULL, ng = 4, nm = 26, f = 0.5, nscor = 1, alpha = 0.05, power = 0.8, type = 0)

3.5/1.5
