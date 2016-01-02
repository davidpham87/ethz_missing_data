### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')
################################################################################
### General simulation arguments

cl <- makeSimCluster(24) # change here for the number of cluster
options(mc.cores=1) # mi wants to eats your cores :-)

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("mi")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_2200_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASDataWoLang()
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
