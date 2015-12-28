source('completion_fns.R')

loadPackages <- function() {
  pckgs <- c("Amelia", "mice", "mi", "softImpute", "impute", "Hmisc",
             "data.table", "parallel", "ggplot2", "simsalapar")
  loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))
  0
}

loadPackages()

### Load the FLAS and the missingness frequency table
loadFLASData <- function() {

  FLAS <- readRDS('../data/FLAS_clean.rds')
  FLAS_COMPLETE <- readRDS('../data/FLAS_complete_average.rds')

  ## MCAR simulation data
  data.complete <- FLAS_COMPLETE[, -12] # Avoid problem of convergence with mi
  mt <- na.pattern(FLAS[, -12])
  list(data=data.complete, missing.table=mt)
}

### Arguments for imputation methods for the flas dataset
imputationArgsFLAS <- function(){
  list("mice"=list(),
       "mi"=list(column.type.mi=list(grade_complete="ordered-categorical")),
       "amelia"=list(noms=c("lang", "age", "priC", "sex"),
                     ords="grade_complete", p2s=0), # p2s -> print to screen
       "softImpute"=list(),
       "impute.knn"=list())
}


### Follow simsalapar
### Simple config files for testing for the varList in simulation Avoid to copy
### paste the type of variable when testing with small number of arguments.
varListTest <- function(data.complete, missing.table.frequency,
                        imputation.methods=c("softImpute", "mice"),
                        missing.probs=c(0.1, 0.15),
                        imputation.methods.args=NULL) {

  if (is.null(imputation.methods.args)){
    imputation.methods.args <- vector(list, length(imputation.methods))
    names(imputation.methods.args) <- imputation.methods
  }

  imputation.varlist.type <-
    if (length(imputation.methods) == 1) 'frozen' else 'grid'

  mt <- missing.table.frequency
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## replications variable, useful because it also set the seeds for the
      ## missing.mechanism
      missing.random.seed=list(type="frozen", expr=quote(Missingness~random~seed), value=1),

      ## Missingness mechanism
      missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

      ## imputation names
      imputation.method=list(type="grid", expr = quote(Imputation~method),
                             value=imputation.methods),

      ## Probability of missingness # Test only value
      p=list(type="grid", value=missing.probs),

      ## Number of imputation
      n.imputation=list(type="frozen", expr=quote(Number~of~imputation),
                        value = c(5)),

      ## Additional arguments for the imputation methods
      imputation.args=
        list(type="frozen",
             value=imputation.methods.args),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(),
                                   "MARFrequency"=list(missing.table=mt))),

      ## the complete dataset
      data.complete=list(type="frozen", expr=quote(Complete~dataset),
                         value=data.complete))
  varList
}


varListProd <- function(data.complete, missing.table.frequency,
                        imputation.methods=c("softImpute", "mice"),
                        missing.probs=seq(5, 85, by=5)/100,
                        imputation.methods.args=NULL) {

  if (is.null(imputation.methods.args)){
    imputation.methods.args <- vector(list, length(imputation.methods))
    names(imputation.methods.args) <- imputation.methods
  }

  imputation.varlist.type <-
    if (length(imputation.methods) == 1) 'frozen' else 'grid'

  mt <- missing.table.frequency
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## replications variable, useful because it also set the seeds for the
      ## missing.mechanism
      missing.random.seed=list(type="grid", expr=quote(Missingness~random~seed),
                               value=1:100),

      ## Missingness mechanism
      missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

      ## imputation names
      imputation.method=list(type=imputation.varlist.type,
                             expr = quote(Imputation~method),
                             value = imputation.methods),

      ## Probability of missingness # Test only value
      p=list(type="grid", value=missing.probs),

      ## Number of imputation
      n.imputation=list(type="grid", expr=quote(Number~of~imputation),
                        value = c(5, 20)),

      ## Additional arguments for the imputation methods
      imputation.args=
        list(type="frozen",
             value=imputation.methods.args),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(),
                                   "MARFrequency"=list(missing.table=mt))),
      ## the complete dataset
      data.complete=list(type="frozen", expr=quote(Complete~dataset),
                         value=data.complete))
  varList
}

## Have to redefine the impuationSimulation function the varList can only take
## grids
doOne <- function(data.complete, missing.mechanism, imputation.method, p, n.imputation,
                  imputation.args, missing.args, missing.random.seed){

  ## Stopping mechanism from MARFrequency
  ## Should make this with a predicate funciton on the argument
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

# Print argument to screen
doOneDebug <- function(...){
  args <- list(...)
  print(args)
  do.call(doOne, args)
}

### Simple wrapper to export the packages and the function
makeSimCluster <- function(n=8){
  cl <- makeCluster(n, type="PSOCK")
  clusterExport(cl, "loadPackages")
  clusterEvalQ(cl, {
    source('completion_fns.R')
    loadPackages()
  })
  cl
}
