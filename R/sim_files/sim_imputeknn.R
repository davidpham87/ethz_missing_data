### Functions for runing the simulation
set('../')
source('simulation_fns.R')


################################################################################
### General simulation arguments

# cl <- makeSimCluster(24) # change here for the number of cluster

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("impute.knn")
sfile.path <- paste0("simulation_rds/imputation_", "20151229_2130_",
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
