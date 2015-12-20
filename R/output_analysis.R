pckgs <- c("data.table", "parallel", "ggplot2", "simsalapar")
loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))


varListTest <- function() {
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1))
   varList
}


varList <- varListTest()
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


res <- doLapply(varList,
                      sfile="../simulation_rds/imputation_clusterapply.rds",
                      doOne=doOne, monitor=interactive())

vals <- getArray(res)
names(dimnames(vals))[1] <- "measures"
err <- getArray(res, "error")
df.res <- array2df(vals)
dt.res <- as.data.table(df.res)
setkeyv(dt.res, c('p'))

dt.err <- as.data.table(array2df(err))
dt.err[value==TRUE][missing.mechanism=="MCAR"]
