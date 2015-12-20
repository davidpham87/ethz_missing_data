### Simple config files for testing for the varList in simulation Avoid to copy
### paste the type of variable when testing with small number of arguments.

### Caution: one should define previously the data.complete and the mt variable
### (missing table, typically na.pattern from Hmisc).

varListTest <- function() {
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## replications variable, useful because it also set the seeds for the
      ## missing.mechanism
      missing.random.seed=list(type="grid", expr=quote(Missingness~random~seed), value=1:5),

      ## Missingness mechanism
      missing.mechanism=list(type="frozen", value=c("MCAR")),

      ## imputation names
      imputation.method=list(type="grid", expr = quote(Imputation~method),
                             value = c("softImpute", "impute.knn")),

      ## Probability of missingness # Test only value
      p=list(type="grid", value=c(0.15, 0.30, 0.45, 0.60, 0.80)),

      ## Number of imputation
      n.imputation=list(type="frozen", expr=quote(Number~of~imputation),
                        value = c(5)),

      ## Additional arguments for the imputation methods
      imputation.args=
        list(type="frozen",
             value=list("mice"=list(),
                        "mi"=list(column.type.mi=list(grade_complete="ordered-categorical")),
                        "amelia"=list(noms=c("lang", "age", "priC", "sex"),
                                      ords="grade_complete"),
                        "softImpute"=list(),
                        "impute.knn"=list())),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(),
                                   "MARFrequency"=list(missing.table=mt))),

      ## the complete dataset
      data.complete=list(type="frozen", expr=quote(Complete~dataset),
                         value=data.complete))
  varList
}


varListProd <- function(imputation.methods=c("amelia", "mice", "mi",
  "softImpute", "impute.knn")) {

  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## replications variable, useful because it also set the seeds for the
      ## missing.mechanism
      missing.random.seed=list(type="grid", expr=quote(Missingness~random~seed), value=1:100),

      ## Missingness mechanism
      missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

      ## imputation names
      imputation.method=list(type="grid", expr = quote(Imputation~method),
                             value = imputation.methods),

      ## Probability of missingness # Test only value
      p=list(type="grid", value=seq(5, 85, by=5)/100),

      ## Number of imputation
      n.imputation=list(type="grid", expr=quote(Number~of~imputation),
                        value = c(5, 20)),

      ## Additional arguments for the imputation methods
      imputation.args=
        list(type="frozen",
             value=list("mice"=list(),
                        "mi"=list(column.type.mi=list(grade_complete="ordered-categorical")),
                        "amelia"=list(noms=c("lang", "age", "priC", "sex"),
                                      ords="grade_complete"),
                        "softImpute"=list(),
                        "impute.knn"=list())),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(),
                                   "MARFrequency"=list(missing.table=mt))),
      ## the complete dataset
      data.complete=list(type="frozen", expr=quote(Complete~dataset),
                         value=data.complete))
  varList
}
