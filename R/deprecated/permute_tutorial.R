library('permute')
data("jackal")
jackal

# Simple t-test
jack.t <- t.test(Length ~ Sex, data = jackal, var.equal = TRUE,
                 alternative = 'two.sided')
jack.t

# Assumption tests
var.test(Length ~ Sex, data = jackal)
fligner.test(Length ~ Sex, data = jackal)

# Permutation test
meanDif <- function(x, grp){
  mean(x[grp == 'Male']) - mean(x[grp == 'Female'])
}
Djackal <- numeric(length = 5000)
N <- nrow(jackal)
set.seed(42)
for(i in seq_len(length(Djackal) - 1)){
  perm <- shuffle(N)
  Djackal[i] <- with(jackal, meanDif(Length, Sex[perm]))
}
Djackal[5000] <- with(jackal, meanDif(Length, Sex))

# Visualise distribution
hist(Djackal, main='',
     xlab = expression('Mean difference (Male - Female) in mm'))
rug(Djackal[5000], col = 'red', lwd = 2)

# Calculate p-value
(Dbig <- sum(Djackal >= Djackal[5000])) # Number larger than observed diff
Dbig / length(Djackal) # P-value

#-#

args(shuffle)
str(how())

set.seed(2)
(r1 <- shuffle(10))
set.seed(2)
(r2 <- sample(1:10,10,replace=FALSE))
all.equal(r1, r2)

#-#

set.seed(4)
x <- 1:10
CTRL <- how(within = Within(type = 'series'))
perm <- shuffle(10, control = CTRL)
perm

x[perm]

set.seed(4)
plt <- gl(3, 9)
CTRL <- how(within = Within(type = 'grid', ncol = 3, nrow = 3),
            plots = Plots(strata = plt))
perm <- shuffle(length(plt), control = CTRL)
perm

lapply(split(seq_along(plt), plt), matrix, ncol = 3)
lapply(split(perm, plt), matrix, ncol = 3)

set.seed(65)
CTRL <- how(within = Within(type = 'grid', ncol = 3, nrow = 3,
            constant = TRUE),
            plots = Plots(strata = plt))
perm2 <- shuffle(length(plt), control = CTRL)
lapply(split(perm2, plt), matrix, ncol = 3)

#-#

how(nperm = 10, within = Within(type = 'series'))

set.seed(4)
CTRL <- how(within = Within(type = 'series'))
pset <- shuffleSet(10, nset = 5, control = CTRL)
pset

#-#

pt.test <- function(x, group, nperm = 199){
  meanDif <- function(i, x, grp){
    grp <- grp[i]
    mean(x[grp == 'Male'] - mean(x[grp == 'Female']))
  }
  
  stopifnot(all.equal(length(x), length(group)))
  N <- nobs(x)
  pset <- shuffleSet(N, nset = nperm)
  D <- apply(pset, 1, meanDif, x = x, grp = group)
  D <- c(meanDif(seq_len(N), x, group), D)
  Ds <- sum(D >= D[1])
  Ds / (nperm + 1)
}
set.seed(42)
pval <- with(jackal, pt.test(Length, Sex, nperm = 4999))
pval

ppt.test <- function(x, group, nperm = 199, cores = 2){
  meanDif <- function(i, .x, .grp){
    .grp <- .grp[i]
    mean(.x[.grp == 'Male'] - mean(.x[.grp == 'Female']))
  }
  
  stopifnot(all.equal(length(x), length(group)))
  N <- nobs(x)
  pset <- shuffleSet(N, nset = nperm)
  if(cores > 1){
    c1 <- makeCluster(cores)
    on.exit(stopCluster(c1 = c1))
    D <- parRapply(c1, pset, meanDif, .x = x, .grp = group)
  }else{
    D <- apply(pset, 1, meanDif, .x = x, .grp = group)
  }
  D <- c(meanDif(seq_len(N), x, group), D)
  Ds <- sum(D >= D[1])
  Ds / (nperm + 1)
}
require('parallel')
set.seed(42)
system.time(ppval <- ppt.test(jackal$Length, jackal$Sex, nperm = 9999,
                              cores = 2))







