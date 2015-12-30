### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')


################################################################################
### General simulation arguments

# cl <- makeSimCluster(24) # change here for the number of cluster

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("impute.knn")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_1400_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASData()
flas.imputation.args <- imputationArgsFLAS()
varList <- varListProd(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       imputation.methods.args=flas.imputation.args)

################################################################################
### Start of simulations

set.seed(1)
res <- doLapply(varList, sfile=sfile.path, doOne=doOneDebug)

toLatex(sessionInfo(), locale=FALSE)


## ################################################################################
## Output from sim_imputeknn.Rout
## ################################################################################
## [1] "missing.mechanism MARFrequency"
## [1] "imputation.method impute.knn"
## [1] "p 0.85"
## [1] "n.imputation 5"
## [1] "missing.random.seed 100"
## ################################################################################
## [1] "missing.mechanism MCAR"
## [1] "imputation.method impute.knn"
## [1] "p 0.05"
## [1] "n.imputation 20"
## [1] "missing.random.seed 1"
## ################################################################################
## [1] "missing.mechanism MCAR"
## [1] "imputation.method impute.knn"
## [1] "p 0.05"
## [1] "n.imputation 20"
## [1] "missing.random.seed 2"
## ################################################################################
