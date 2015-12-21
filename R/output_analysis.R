pckgs <- c("Hmisc", "mice",
           "data.table", "parallel", "ggplot2", "simsalapar")
loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))


source('completion_fns.R')
options(mc.cores=1)

set.seed(1)
FLAS <- readRDS('../data/FLAS_clean.rds')
FLAS_COMPLETE <- readRDS('../data/FLAS_complete_average.rds')
# na.pattern(FLAS)

dataset <- FLAS_COMPLETE
mt <- na.pattern(FLAS)
column.type.mi <- list(grade_complete="ordered-categorical")

## MCAR simulation data
data.complete <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
mt <- na.pattern(FLAS[, -12])
n <- 5

## Follow simsalapar
source("varlist_fns.R")
imputation.methods <- c("softImpute", "impute.knn")
varList <- varListProd(imputation.methods)

doOne <- function(data.complete, missing.mechanism, imputation.method, p, n.imputation,
                  imputation.args, missing.args, missing.random.seed){

  # Stopping mechanism from MARFrequency
  if (missing.mechanism == 'MARFrequency' & p > 0.3){
    measures <- colnames(data.complete)
    res <- rep(-1, length(measures))
    names(res) <- measures
    return(res)
  }

  miss.args <-
    c(list(random.seed=missing.random.seed), missing.args[[missing.mechanism]])

  ## arguments for the imputeDataFns
  n.imputation.args <-
    ifelse(!missing.mechanism %in% c('softImpute', 'impute.knn'),
           list(n=n.imputation),
           list())

  if (is.null(imputation.args[[imputation.method]])) {
    imp.args <- n.imputation.args
  } else {
    imp.args <- c(n.imputation.args, imputation.args[[imputation.method]])
  }

  imputationSimulation(as.data.frame(data.complete), missing.mechanism, imputation.method,
                       p, miss.args, imp.args)
}


getDataSimulation <- function(imputation.methods){
  ## varList <- varListProd(imputation.methods)
  sfile.path <- paste0("../simulation_rds/imputation_mc_",
                       "2015120_2202_",
                       paste0(imputation.methods, collapse='_'),
                       ".rds")
  res <- maybeRead(sfile.path)
  res
}

m <- list(c("softImpute", "impute.knn"), c("mice", "softImpute"))
res <- lapply(m, getDataSimulation)

vals <- getArray(res)
names(dimnames(vals))[1] <- "measures"
err <- getArray(res, "error")
df.res <- array2df(vals)
dt.res <- as.data.table(df.res)
setkeyv(dt.res, c('p'))

dt.err <- as.data.table(array2df(err))
dt.err[value==TRUE][missing.mechanism=="MCAR"]

si <- res[[1]]


# Because of MARFrequency one has to filter for positive mse
isValidSimulation <- function(l){
  if (is.null(l$value)) return(FALSE)
  all(l$value >= 0 | is.na(l$value))
}

valid.sim <- lapply(res, function(l) vapply(l, isValidSimulation, TRUE))

res.valid <- mapply(function(x, bx) x[bx], res, valid.sim)

getArrayElement <- function(l, s){
  a <- getArray(l, s)
  dt <- as.data.table(array2df(a))
  dt[!(missing.mechanism == 'MARFrequency' &
           as.numeric(levels(p)[p]) > 0.3)][, sum(value), by="missing.mechanism,imputation.method,p"]
}
