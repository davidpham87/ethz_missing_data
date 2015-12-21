### Functions for runing the simulation
source('simulation_fns.R')

################################################################################
### General simulation arguments

cl <- makeSimCluster(4) # change here for the number of cluster
option(mc.cores=1) # mi wnats to eats your cores :-)

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("mice", "mi", "impute.knn", "softImpute")
sfile.path <- paste0("../simulation_rds/imputation_", "20151221_1800_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASData()
flas.imputation.args <- imputationArgsFLAS()

################################################################################
### Simulation Grid

varList <- varListProd(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       imputation.methods.args=flas.imputation.args)

################################################################################
### Start of simulations

set.seed(1)
res <- doClusterApply(varList, cl, sfile=sfile.path, doOne=doOne)

################################################################################
### Reproducibility

toLatex(sessionInfo(), locale=FALSE)
