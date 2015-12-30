### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')

## At p=0.75
## *** caught segfault ***
## address 0x2d860448, cause 'memory not mapped'

################################################################################
### General simulation arguments

# cl <- makeSimCluster(12) # change here for the number of cluster
options(mc.cores=12)
################################################################################
### Simulation Args for FLAS
imputation.methods <- c("impute.knn")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_1900_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASData()
flas.imputation.args <- imputationArgsFLAS()
varList <- varListProd(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       missing.probs=seq(5, 70, by=5)/100,
                       imputation.methods.args=flas.imputation.args)

################################################################################
### Start of simulations

set.seed(1)
res <- doLapply(varList, sfile=sfile.path, doOne=doOneDebug)

toLatex(sessionInfo(), locale=FALSE)

