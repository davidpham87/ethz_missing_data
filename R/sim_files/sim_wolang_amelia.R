### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')

################################################################################
### General simulation arguments

# cl <- makeSimCluster(16) # change here for the number of cluster
options(mc.cores=23) # mi wnats to eats your cores :-)

################################################################################
### Simulation Args for FLAS
imputation.methods <- c("amelia")
sfile.path <- paste0("simulation_rds/imputation_", "20151230_2000_",
                     paste0(imputation.methods, collapse='_'), ".rds")

################################################################################
### FLAS

flas.li <- loadFLASDataWoLang()
flas.imputation.args <- imputationArgsFLAS()
flas.imputation.args$amelia <- list(noms=c("age", "priC", "sex"),
                                    ords="grade_complete", p2s=0)

################################################################################
### Simulation Grid

varList <- varListProd(flas.li$data, flas.li$missing.table,
                       imputation.methods,
                       missing.probs=seq(5, 30, by=5)/100,
                       imputation.methods.args=flas.imputation.args)

################################################################################
### Start of simulations

set.seed(1)
res <- doMclapply(varList, sfile=sfile.path, doOne=doOne)

################################################################################
### Reproducibility

toLatex(sessionInfo(), locale=FALSE)
