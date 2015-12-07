pckgs <- c("Amelia", "mice", "mi", "softImpute", "impute", "Hmisc",
           "data.table", "parallel", "ggplot2", "simsalapar")
loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))


source('completion_fns.R')
options(mc.cores=4)

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
varList <- varListProd()

# varList <- varListProd()
## toLatex(varList)
## pGrid <- mkGrid(varList)

## Have to redefine the impuationSimulation function the varList can only take
## grids
doOne <- function(data.complete, missing.mechanism, imputation.method, p, n.imputation,
                  imputation.args, missing.args, missing.random.seed){

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

# sfile="imputation_lapply.rds"
## res <- doLapply(varList, doOne=doOne, monitor=interactive())

cl <- makeCluster(4, type="PSOCK")
clusterExport(cl, "pckgs")
clusterEvalQ(cl, {
  source('completion_fns.R')
  loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))
  0
})
res <- doClusterApply(varList, cluster=cl, sfile="imputation_clusterapply.rds",
                      doOne=doOne, monitor=interactive())

vals <- getArray(res)
names(dimnames(vals))[1] <- "measures"
err <- getArray(res, "error")
df.res <- array2df(vals)

rv <- c("imputation.method")
cv <- c("missing.mechanism")
ftable(100*err, row.vars=rv, col.vars=cv)

### Plots
gg <- ggplot(na.omit(df.res), aes(missing.mechanism, value, color=imputation.method)) +
  geom_boxplot() + facet_grid(p~measures) + coord_cartesian(ylim = c(0, 1)) +
  scale_x_discrete(labels=c("MCAR"="MCAR", "MARFrequency"="MAR")) + theme_bw() +
  ylab("MSE") + xlab("Missing Mechanism") + ggtitle("Missing simulation on FLAS")

pdf("test_plot.pdf", height=6.5, width=18)
print(gg)
dev.off()
## library('tikzDevice')
## options(tikzDefaultEngine = 'pdftex')
## tikz('test_plot.tex', height=6.5, width=9)
## print(gg)
## dev.off()

## ggplot(data, aes(type, value, fill=method)) + geom_bar(stat='identity', position=position_dodge()) + scale_y_log10()

## TODO: check how one can use extra variable as varLists
## mayplot(vals, varList,
##         row.vars="imputation.method", col.vars="missing.mechanism", xvar="measures") # uses default
