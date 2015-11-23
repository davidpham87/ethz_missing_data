library(mice)
library(mi)
library(Hmisc)  #package for na.pattern() and impute()
library(data.table)
library(parallel)
library(ggplot2)
library(simsalapar)

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
n <- 5

diff <- imputationSimulation(data.complete, n, MCAR, column.type.mi, p=0.20)
vector2df(diff, c('method', 'type', 'value'))

diff <- imputationSimulation(data.complete, n, MARFrequency, column.type.mi, mt)
vector2df(diff, c('method', 'type', 'value'))

## TODO: Write Simulation and do plots
## TODO: Check for more imputations packages
## TODO: Run simulations with replicate and simulation.
