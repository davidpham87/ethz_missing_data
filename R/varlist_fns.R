### Simple config files for testing for the varList in simulation Avoid to copy
### paste the type of variable when testing with small number of arguments.

### Caution: one should define previously the mt variable (missing table,
### typically na.pattern from Hmisc).

varListTest <- function() {
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## Missingness mechanism
      missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

      ## imputation names
      imputation.method=list(type="grid", expr = quote(Imputation~method),
                             value = c("softImpute", "mice")),

      ## Probability of missingness # Test only value
      p=list(type="frozen", value=c(0.15)),

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
                        "softImpute"=list())),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(random.seed=1),
                                   "MARFrequency"=list(random.seed=1, missing.table=mt))))
  varList
}


varListProd <- function() {
  varList <- # *User provided* list of variables
    varlist( # constructor for an object of class 'varlist'
      ## replications
      n.sim=list(type="N", expr=quote(N[sim]), value = 1),

      ## Missingness mechanism
      missing.mechanism=list(type="grid", value=c("MCAR", "MARFrequency")),

      ## imputation names
      imputation.method=list(type="grid", expr = quote(Imputation~method),
                             value = c("amelia", "mice",  "mi")),

      ## Probability of missingness # Test only value
      p=list(type="grid", value=c(0.05, 0.15)),

      ## Number of imputation
      n.imputation=list(type="grid", expr=quote(Number~of~imputation),
                        value = c(5, 20)),

      ## Additional arguments for the imputation methods
      imputation.args=
        list(type="frozen",
             value=list("mice"=list(),
                        "mi"=list(column.type.mi=list(grade_complete="ordered-categorical")),
                        "amelia"=list(noms=c("lang", "age", "priC", "sex"),
                                      ords="grade_complete"))),

      ## additional arguments for the missing mechanism functions
      missing.args=list(type="frozen",
                        value=list("MCAR"=list(random.seed=1),
                                   "MARFrequency"=list(random.seed=1, missing.table=mt))))
  varList
}
