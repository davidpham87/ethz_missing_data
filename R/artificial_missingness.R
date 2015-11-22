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
dataset <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
data.missing <- MCAR(dataset, 0.10)

idx <- is.na(data.missing)
ldf.mcar  <- imputeData(data.missing, column.type.mi=column.type.mi)
df <- ldf.mcar[[1]]

cols.na <- lapply(data.mcar, is.na)
### write comparison methods depending on the type of the column
### Write function deviation
dataset - df[[1]]

data.missing <- MARFrequency(dataset, mt)
idx <- is.na(data.missing)
ldf.mar  <- imputeData(data.missing, column.type.mi=column.type.mi)
