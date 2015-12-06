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


## Follow simsalapar
require("simsalapar")

varList <- # *User provided* list of variables
  varlist( # constructor for an object of class 'varlist'
    ## replications
    n.sim=list(type="N", expr=quote(N[sim]), value = 5),

    ## Missingness mechanism
    missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

    ## imputation names
    imputation.method=list(type="grid", expr = quote(Imputation~method),
                            value = c("mice", "mi")),

    ## Probability of missingness # Test only value
    p=list(type="grid", value=c(0.05, .15)),

    ## Number of imputation
    n.imputation=list(type="grid", expr=quote(Number~of~imputation),
                      value = c(5, 20)),

    ## Additional arguments for the imputation methods
    imputation.args=list(type="frozen",
                         value=list("mice"=list(),
                                    "mi"=list(column.type.mi=column.type.mi))),

    ## additional arguments for the missing mechanism functions
    missing.args=list(type="frozen",
                      value=list("MCAR"=list(random.seed=1),
                                 "MARFrequency"=list(random.seed=1, missing.table=mt))))

## toLatex(varList)
## pGrid <- mkGrid(varList)

## Have to redefine the impuationSimulation function the varList can only take
## grides
doOne <- function(missing.mechanism, imputation.method, p, n.imputation,
                  imputation.args, missing.args){
  miss.args <- missing.args[[missing.mechanism]]
  imp.args <- c(list(n=n.imputation), imputation.args[[imputation.method]])
  res <- imputationSimulation(data.complete,
                       missing.mechanism,
                       imputation.method,
                       p,
                       miss.args,
                       imp.args)
  res
}

# sfile="imputation_lapply.rds"
## res <- doLapply(varList, doOne=doOne, monitor=interactive())

cl <- makeCluster(4, type="PSOCK")
clusterEvalQ(cl, {
  source('completion_fns.R')
  library(mice)
  library(mi)
  library(Hmisc)  #package for na.pattern() and impute()
  library(data.table)
  library(parallel)
  library(simsalapar)
})
clusterExport(cl, "data.complete")

res <- doClusterApply(varList, cluster=cl, sfile="imputation_clusterapply.rds",
                      doOne=doOne, monitor=interactive())

vals <- getArray(res)
names(dimnames(vals))[1] <- "measures"
err <- getArray(res, "error")
df.res <- array2df(vals)


rv <- c("imputation.method")
cv <- c("missing.mechanism")
ftable(100*err, row.vars=rv, col.vars=cv)


ggplot(na.omit(df.res), aes(missing.mechanism, value, color=imputation.method)) +
  geom_boxplot() + facet_grid(p~measures)

## mayplot(vals[, , , ,n.imputation="20",], varList,
##         row.vars="imputation.method", col.vars="missing.mechanism", xvar="p") # uses default

## TODO: Write Simulation and do plots
## TODO: Check for more imputations packages
## TODO: Run simulations with replicate and simulation.
## ggplot(data, aes(type, value, fill=method)) + geom_bar(stat='identity', position=position_dodge()) + scale_y_log10()
