### Functions for runing the simulation

## Bug appears when p=0.05, n.imptuation = 100, n.random.seed=3
## The call:
## do.call(impute::impute.knn, c(list(as.matrix(dataset)), list(NULL))
## Creates a memory dump.

setwd('../')
source('simulation_fns.R')


######################################################################
### Simulation Args for FLAS
imputation.methods <- c("impute.knn")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_1430_",
                     paste0(imputation.methods, collapse='_'), ".rds")

######################################################################
### FLAS

flas.li <- loadFLASData()
flas.imputation.args <- imputationArgsFLAS()

set.seed(1)
dataset <- MCAR(flas.li$data, 0.10, random.seed=1)

## Transfrom factors to integers
## boolean vectors stating factors columns
fctrs <- sapply(1:ncol(dataset), function(jdx)
    any(c("factor", "string") %in% class(dataset[1, jdx])))
lvls <- lapply(dataset[, fctrs], levels)

dataset[, fctrs] <- lapply(dataset[, fctrs], as.numeric)
x <- as.matrix(dataset)

### Core dump
replicate(10, {
  impute::impute.knn(x, NULL)
})
