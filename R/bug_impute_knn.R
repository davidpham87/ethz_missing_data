# Scripts for illustrating the segmentations faults of impute.knn


pckgs <- c("impute", "Hmisc", "parallel", "simsalapar")
loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))

source('completion_fns.R')
source("varlist_fns.R") # create the variable list for the simulation
options(mc.cores=1)

set.seed(1)
FLAS <- readRDS('../data/FLAS_clean.rds')
FLAS_COMPLETE <- readRDS('../data/FLAS_complete_average.rds')

column.type.mi <- list(grade_complete="ordered-categorical")
## MCAR simulation data
data.complete <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
mt <- na.pattern(FLAS[, -12])

## Follow simsalapar
p <- 0.75

dataset <- MCAR(as.data.frame(data.complete), p=p, random.seed=10)

fctrs <- sapply(1:ncol(dataset), function(jdx)
  any(c("factor", "string") %in% class(dataset[1, jdx])))
lvls <- lapply(dataset[, fctrs], levels)

dataset[, fctrs] <- lapply(dataset[, fctrs], as.numeric)
fit <- impute::impute.knn(as.matrix(dataset))
dataset <- as.data.frame(fit$data)
