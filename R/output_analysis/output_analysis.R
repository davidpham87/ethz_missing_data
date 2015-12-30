pckgs <- c("Hmisc", "mice",
           "data.table", "parallel", "ggplot2", "simsalapar")
loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))


source('completion_fns.R')
source("varlist_fns.R")
options(mc.cores=1)

set.seed(1)
FLAS <- readRDS('../data/FLAS_clean.rds')
FLAS_COMPLETE <- readRDS('../data/FLAS_complete_average.rds')
# na.pattern(FLAS)

## MCAR simulation data
data.complete <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
mt <- na.pattern(FLAS[, -12])
n <- 5

## Follow simsalapar

getDataSimulation <- function(imputation.methods){
  ## varList <- varListProd(imputation.methods)
  sfile.path <- paste0("../simulation_rds/imputation_",
                       "2015120_2202_",
                       paste0(imputation.methods, collapse='_'),
                       ".rds")
  res <- maybeRead(sfile.path)
  res
}

m <- list(c("softImpute", "impute.knn"), c("mi", "mice"))
res <- lapply(m, getDataSimulation)

vals <- getArray(res)
names(dimnames(vals))[1] <- "measures"
err <- getArray(res, "error")
df.res <- array2df(vals)
dt.res <- as.data.table(df.res)
setkeyv(dt.res, c('p'))

dt.err <- as.data.table(array2df(err))
dt.err[value==TRUE][missing.mechanism=="MCAR"]

si <- res[[1]]n

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
           as.numeric(levels(p)[p]) > 0.3)]
  # [, sum(value), by="missing.mechanism,imputation.method,p"]
}



## vals <- getArray(res)
## names(dimnames(vals))[1] <- "measures"
err <- lapply(res, getArrayElement, s="error")
## df.res <- array2df(vals)

## rv <- c("imputation.method")
## cv <- c("missing.mechanism")
## ftable(100*err, row.vars=rv, col.vars=cv)

### Plots
## df.plot <- na.omit(df.res) # subset(df.res, imputation.method!="softImpute"))
## gg <- # ggplot(df.plot, aes(imputation.method, value)) +
##   ggplot(df.plot, aes(missing.mechanism, value, color=imputation.method)) +
##   geom_boxplot() + facet_grid(measures~p, scales="free_y") +
##   scale_x_discrete(labels=c("MCAR"="MCAR", "MARFrequency"="MAR")) + theme_bw() +
##   ylab("MSE") + xlab("Missing Mechanism") + ggtitle("Missing simulation on FLAS")

## pdf("../plot/test_plot.pdf", height=12, width=10)
## print(gg)
## dev.off()

## library('tikzDevice')
## options(tikzDefaultEngine = 'pdftex')
## tikz('test_plot.tex', height=6.5, width=9)
## print(gg)
## dev.off()

## ggplot(data, aes(type, value, fill=method)) + geom_bar(stat='identity', position=position_dodge()) + scale_y_log10()

## TODO: check how one can use extra variable as varLists
## mayplot(vals, varList,
##         row.vars="imputation.method", col.vars="missing.mechanism", xvar="measures") # uses default
