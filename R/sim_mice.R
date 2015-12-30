### Functions for runing the simulation
source('simulation_fns.R')

################################################################################
### General simulation arguments

# cl <- makeSimCluster(16) # change here for the number of cluster
# options(mc.cores=4) # mi wants to eats your cores :-)

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("mice")
sfile.path <- paste0("../simulation_rds/imputation_", "20151229_2130_",
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
res <- doLapply(varList, sfile=sfile.path, doOne=doOneDebug)

################################################################################
### Reproducibility

toLatex(sessionInfo(), locale=FALSE)
