library(mice)
library(mi)
library(Hmisc)  #package for na.pattern() and impute()
library(data.table)
library(parallel)
library(ggplot2)

source('completion_fns.R')
options(mc.cores=4)

set.seed(1)
FLAS <- readRDS('../data/FLAS_clean.rds')
FLAS_COMPLETE <- readRDS('../data/FLAS_complete_average.rds')
na.pattern(FLAS)

dataset <- FLAS_COMPLETE
mt <- na.pattern(FLAS)
column.type.mi <- list(grade_complete="ordered-categorical")

## MCAR simulation data
data.complete <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
mt <- na.pattern(FLAS[, -12])
n <- 20

data.missing <- MCAR(data.complete, 0.10)
data.missing <- MARFrequency(data.complete, mt)

idx <- is.na(data.missing)
ldf.imp  <- imputeData(data.missing, n=n, column.type.mi=column.type.mi)
imp.diff <-
  lapply(ldf.imp,
         function(dfx) mseImputation(dfx, data.missing, data.complete))


imputationSimulation <- function(data.complete, n.sample,
                                 missing.mechasnism=MCAR, ...){
  data.missing <- missing.mechasnism(data.complete, ...)
  idx <- is.na(data.missing)
  ldf.imp  <- imputeData(data.missing, n=n.sample,
                         column.type.mi=column.type.mi)
  imp.diff <-
    lapply(ldf.imp,
           function(dfx) mseImputation(dfx, data.missing, data.complete))
  imp.diff
}

## TODO: Write Simulation and do plots
## TODO: Check for more imputations packages
