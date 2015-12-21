### Functions for runing the simulation
source('simulation_fns.R')

################################################################################
### General simulation arguments

cl <- makeSimCluster(4) # change here for the number of cluster

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("impute.knn", "softImpute")
sfile.path <- paste0("../simulation_rds/imputation_", "20151221_1800_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASData()
flas.imputation.args <- imputationArgsFLAS()
varList <- varListTest(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       imputation.methods.args=flas.imputation.args)
################################################################################
### Start of simulations

set.seed(1)
res <- doClusterApply(varList, cl, sfile=sfile.path, doOne=doOne)
