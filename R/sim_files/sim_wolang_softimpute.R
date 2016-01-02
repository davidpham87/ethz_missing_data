### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')

################################################################################
### General simulation arguments

cl <- makeSimCluster(12) # change here for the number of cluster

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("softImpute")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_1900_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASDataWoLang()
flas.imputation.args <- imputationArgsFLAS()
varList <- varListProd(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       imputation.methods.args=flas.imputation.args)
################################################################################
### Start of simulations

set.seed(1)
res <- doClusterApply(varList, cl, sfile=sfile.path, doOne=doOne)

toLatex(sessionInfo(), locale=FALSE)
