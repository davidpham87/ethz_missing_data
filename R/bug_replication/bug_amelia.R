### Functions for runing the simulation
setwd('../')
source('simulation_fns.R')

toLatex(sessionInfo(), locale=FALSE)

### Bug: In Amelia, when the provided matrix is not invertible,
### the process has a core dump segmentation fault.

######################################################################
### FLAS Dataset

flas.li <- loadFLASData()

######################################################################
### Test case

## Exception Throw (core dumped)
dataset <- MCAR(flas.li$data, p=0.35, random.seed=59)

## Throw exception
a.out <- amelia(dataset, 20, noms=c("lang", "age",  "priC", "sex"),
                ords=c("grade_complete"), p2s=0)

## Same core dumped
dataset <- MCAR(flas.li$data, p=0.7, random.seed=1)
## Throw exception (not invertible)
a.out <- amelia(dataset, 20, noms=c("lang", "age",  "priC", "sex"),
                ords=c("grade_complete"), p2s=0)
