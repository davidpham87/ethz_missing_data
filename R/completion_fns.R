# Functions to impute dataset and create artificial missingness.

##' Find the Mode of a vector
##'
##' Used for majority vote
##' @title Mode
##' @param x, a vector, if possible discrete.
##' @return the most present observation as string
##' @author David Pham
Mode <- function(x){
  sample(names(which.max(table(x))), 1)
}


##' Averaging observation of a column across data.frame
##'
##'
##' @title Averaging observation
##' @param dfx, list of data.frame with same shape
##' @param idx, the columne to average
##' @return The average column
##' @author David Pham
averagingColumn <- function(dfx, idx){
  df <- as.data.frame(lapply(dfx, '[', idx))
  ## Class can return vector with dimension bigger than 1 (e.g. c("ordered", "factor"))
  avg.fn <- if (any(c("factor", "string") %in% class(df[1, 1]))) Mode else mean
  apply(df, 1, avg.fn)
}


##' Create a "average" data set from several imputations
##'
##' The method use mean and majority vote to select the variable that where missing.
##' @title Imputations averaging
##' @param imputations, list of data.frames which are sample of imputations
##' @return The "average" data.frame, using mean and majority vote for
##'   selecting continuous and discrete variable.
##' @author David Pham
averagingImputations <- function(imputations){
  p <- ncol(imputations[[1]])
  res <- as.data.frame(lapply(1:p, function(i) averagingColumn(imputations, i)))
  colnames(res) <- colnames(imputations[[1]])
  return(res)
}


##' Impute data with mice
##'
##'
##' @title Imputing data with Mice
##' @param dataset, a data.frame containing missing values.
##' @param n, the number fo imputation to generate
##' @return list of imputed data.frame
##' @author David Pham
imputeDataMice <- function(dataset, n, ...){
  args <- list(...)
  imputations <- do.call(mice::mice, c(list(dataset, n), args)) # do multiple imputation (default is 5 realizations)
  data.mice <- lapply(1:n, function(i) mice::complete(imputations, i)) # mice and mi conflicts here
  return(data.mice)
}


##' Impute data with mice
##'
##'
##' @title Data imputation with mi
##' @param dataset, a data.frame containing missing values.
##' @param n, the number fo imputation to generate
##' @param column.type.mi, override of column type for the mi.
##' @return list of imputed data.frame
##' @author David Pham
imputeDataMi <- function(dataset, n, column.type.mi=NULL, ...){
  args <- list(...)
  valid.column.type <- c("unordered-categorical", "ordered-categorical",
                         "binary", "interval", "continuous", "count",
                         "irrelevant")

  ## check that the modification are valid
  if (!is.null(column.type.mi)){
    stopifnot(all(vapply(column.type.mi, is.element, TRUE, set=valid.column.type)))
  } else {
    column.type.mi <- list()
  }

  mdf <- missing_data.frame(dataset) # missing data.frame

  for (k in names(column.type.mi)){
    mdf <- change(mdf, y=k, what="type", to=column.type.mi[[k]])
  }

  imputations <- do.call(mi, c(list(mdf, n.iter=30, n.chains=4), args))
  data.mi <-  mi::complete(imputations, n) # creates 20 different versions of imputations

  ## mi append columns providing the stating the missingnes, so we have to delete them
  data.mi <- lapply(data.mi,  function(df) df[, 1:ncol(dataset)]) # restrict the number of columns
  return(data.mi)
}


##' Impute Data using Amelia
##'
##' Simple wrapper arounde amliea to provide a list of imputed data.frame
##' @title Data imputation with Amelia
##' @param dataset
##' @param n, the number of imput
##' @param ..., additional argument to the amelia function
##' @return a list imputed data.frame
##' @author David Pham
imputeDataAmelia <- function(dataset, n, ...){
  args <- list(...)
  a.out <- do.call(amelia, c(list(dataset, m=n), args))
  lapply(a.out$imputations, as.data.frame)
}



##' Complete the numerical value with softImpute
##'
##' Extract the numerical value of a dataset and complete them with softImpute
##' @title SoftImpute and Impute knn
##' @param dataset, an incomplete dataset
##' @param ..., argument for sotfImpute
##' @return a list with n times the same elements which is the completed
##'   data.frame (only numerical variable)
##' @author David Pham
imputeDataSoftImpute <- function(dataset, ...){

  args <- list(...)
  is.null.args <- length(args) == 1 & is.null(args[[1]])

  ## boolean vectors stating factors columns
  fctrs <- sapply(1:ncol(dataset), function(jdx)
    any(c("factor", "string") %in% class(dataset[1, jdx])))
  lvls <- lapply(dataset[, fctrs], levels)

  dataset[, fctrs] <- lapply(dataset[, fctrs], as.numeric)
  x <- as.matrix(dataset)

  fit <- if (is.null.args){
    do.call(softImpute::softImpute, c(list(x)))
  } else {
    do.call(softImpute::softImpute, c(list(x), args))
  }

  dataset <- as.data.frame(softImpute::complete(x, fit))

  ## Correct the factors
  f <- function(s) {
    cut(round(dataset[, s]), c(0, seq_along(lvls[[s]])),
        labels=lvls[[s]], include.lowest=TRUE)
  }
  dataset[, fctrs] <- lapply(names(lvls), f)
  list(dataset)
}


imputeDataImputeKnn <- function(dataset, ...){

  args <- list(...)
  is.null.args <- length(args) == 1 & is.null(args[[1]])

  ## boolean vectors stating factors columns
  fctrs <- sapply(1:ncol(dataset), function(jdx)
    any(c("factor", "string") %in% class(dataset[1, jdx])))
  lvls <- lapply(dataset[, fctrs], levels)

  dataset[, fctrs] <- lapply(dataset[, fctrs], as.numeric)
  x <- as.matrix(dataset)

  fit <- if (is.null.args){
    do.call(impute::impute.knn, c(list(x)))
  } else {
    do.call(impute::impute.knn, c(list(x), args))
  }

  dataset <- as.data.frame(fit$data)

  ## Correct the factors
  f <- function(s) {
    cut(round(dataset[, s]), c(0, seq_along(lvls[[s]])),
        labels=lvls[[s]], include.lowest=TRUE)
  }
  dataset[, fctrs] <- lapply(names(lvls), f)
  list(dataset)
}


##' TODO: change the function to accept strings as imputation methods and use a
##' list with function and for argument. This faciliates the simulation as
##' arguments will be strings.
##' TODO: Refactor imputeData* to accept "..." arguments
##' This is bad polymorphism
imputeDataSimulation <- function(dataset, method='mice', ...){

  args <- list(...)

  imputationMethods <-
    list(mice=imputeDataMice,  mi=imputeDataMi, amelia=imputeDataAmelia,
         softImpute=imputeDataSoftImpute,
         impute.knn=imputeDataImputeKnn)

  impute.fn <- imputationMethods[[method]]
  res <- list(do.call(impute.fn, c(list(dataset), args)))
  names(res) <- method
  return(res)
}

##' Imputation dataset from mice and mi
##'
##'
##' Given a data set containing missing, the function produces
##' simulated data.frames using the mice and the mi packages.
##' @title Impute Data from a data.frame containing missing data
##' @param dataset, the data set
##' @param n, the number of imputed dataset
##' @param column.type.mi, type of column for the mi implemation
##' @return a list of list containing data.frames of complete data.
##' @author David Pham
imputeData <- function(dataset, n=5, column.type.mi=NULL){

  imputationMethods <-
    list(mice=imputeDataMice,  mi=imputeDataMi)

  data.mice <- imputeDataMice(dataset, n)
  data.mi <- imputeDataMi(dataset, n, column.type.mi)
  return(list(mice=data.mice, mi=data.mi))
}


################################################################################
## Missing simulation

##' Simulating missing at random using frequency
##'
##' Sample the missingness patterns from the missingness table and replace
##' complete data with the sampled missingnes patterns.
##' @title MAR Sample through missingnes frequency
##' @param dataset, the data.frame to simulate the missingnes
##' @param p, the probability that one single observation is missing
##' @param missing.table, a vector containing the frequency of
##'   missingness. Result of na.pattern from Hmisc::na.pattern
##' @return a data.frame of the same dimension of dataset with missingnes
##'   pattern sampled from the missing table
##' @author David Pham
MARFrequency <- function(dataset, p=0.03,  missing.table=NULL, random.seed=NULL){
  if (p==0) return(dataset)
  stopifnot(!is.null(missing.table))

  random.seed <- if (is.null(random.seed)) 1 else random.seed
  old <- .Random.seed
  on.exit({ .Random.seed <<- old })
  set.seed(random.seed)

  mt <- missing.table
  ## missingnes matrix => columns provies pattern, value of the i^{th} row is 1
  ## if the ith column in the original dataset is missing.
  mm <- sapply(names(mt), function(s) as.numeric(strsplit(s, split='')[[1]]))
  cols.keep <- which(apply(mm, 2, function(x) any(as.logical(x)))) # exclude complete case
  mt <- mt[cols.keep]
  mm <- mm[, cols.keep]

  n.missing.max <- floor(p*prod(dim(dataset))) + 1
  ## retry concept because it is possible that the sample does not provide
  ## enough missing data

  ## select missingnes pattern
  mp <- sample(1:ncol(mm), nrow(dataset), replace=TRUE, prob=mt)
  missing.cumulative <- cumsum(colSums(mm[, mp]))
  n.pattern.missing.artificial <-
    length(Filter(function(x) x <= n.missing.max, missing.cumulative)) + 1
  missingness.matrix <- mm[, mp][, 1:(max(1, n.pattern.missing.artificial))]

  res <- data.frame(dataset)
  rows.new <- sample(1:nrow(dataset), ncol(missingness.matrix))
  ## Could be improved with a apply
  for (i in 1:ncol(missingness.matrix)){
    idx <- rows.new[i]
    res[idx, ] <- ifelse(missingness.matrix[, i]==1, NA, dataset[idx, ])
  }
  res
}


##' Simulating missing completely at random
##'
##' Sample a binomial sample with the probability given by the user.
##' @title MCAR Sample
##' @param dataset, the data.frame to simulate the missingnes
##' @param p, the probability that one single observation is missing
##' @param columns, integers specifying which columns are considered for missingness, default all.
##' @return a data.frame of the same dimension as dataset containing missing
##'   data with the probility given by the user.
##' @author David Pham
MCAR <- function(dataset, p=0.03, columns=1:ncol(dataset), random.seed=NULL){

  if (p==0) return(dataset)

  random.seed <- if (is.null(random.seed)) 1 else random.seed
  old <- .Random.seed
  on.exit({ .Random.seed <<- old })
  set.seed(random.seed)

  res <- data.frame(dataset)
  cx <- columns
  n <- length(cx)
  for (i in 1:nrow(res)){
    res[i, cx] <- ifelse(rbinom(n, 1, p), NA, dataset[i, cx])
  }
  res
}

##' Column MSE
##'
##' Provide the mse, taking care of knowing if the value is a factor or a
##' numeric value. The MSE for numerical value is given by
##' 1/N \sum{_i=1}^{N} (\hat x_ij - x_ij)^2/x_{\dot j}^2
##' @title MSE of a single column
##' @param dfx, a list of data frame
##' @param idx, single integer defining which column is being compared
##' @param na.idx, row index where the data is missing for column idx
##' @param dataset.complete
##' @return
##' @author David Pham
mseImputationColumn <- function(dfx, idx, na.idx, dataset.complete){

  is.factor.value <- any(c("factor", "string")
                         %in% class(dataset.complete[1, idx]))
  col.mean.data.complete <- if(is.factor.value) 1 else mean(dataset.complete[ , idx])
  mseNum <- function(x, y) mean((((x-y)/col.mean.data.complete)^2))
  mseFac <- function(x, y) mean(x!=y)

  df <- as.data.frame(lapply(dfx, '[', idx))
  df <- df[na.idx, ] # keep imputed values only # na.idx <- cols.na[[idx]]
  nc <- if(is.null(ncol(df))) 1 else ncol(df)

  values.true <- dataset.complete[na.idx, idx] # keep only missing value

  if (!length(values.true)){
    return(NA)
  }

  values.true <- matrix(rep(values.true, times=nc), ncol=nc) # transform for comparing
  err.fn <- if (is.factor.value) mseFac else mseNum
  res <- err.fn(df, values.true)
  res
}


##' @param dfx, a list of data frame
mseImputation <- function(dfx, data.missing, data.complete){
  cols.na <- lapply(data.missing, is.na)
  f <- function(i) mseImputationColumn(dfx, i, cols.na[[i]], data.complete)
  res <- vapply(1:ncol(data.complete), f, 0)
  names(res) <- colnames(data.complete)
  res
}



##' Run imputation simulation
##'
##' TODO: simplify the function
##' @title Error of imputation through simultation
##' @param data.complete, a complete dataframe
##' @param n.sample, the number of sample per imputation
##' @param column.type.mi
##' @param missing.mechasnism, a function accepting data.complete and returns an incomplete data.frame
##' @param ..., argument to missing.mechanism
##' @return a named numeric vector containing the mse of columns by the simulation type
##' @author David Pham
imputationSimulation <- function(data.complete,
                                 missing.mechanism='MCAR',
                                 imputation.method='mice',
                                 p=0.05,
                                 missing.mechanism.args=list(),
                                 imputation.args=list()){

  missing.mechanism.fns <- list(MCAR=MCAR, MARFrequency=MARFrequency)
  stopifnot(missing.mechanism %in% names(missing.mechanism.fns))
  missing.mechanism.fn <- missing.mechanism.fns[[missing.mechanism]]

  data.missing <-
    do.call(missing.mechanism.fn,
            c(list(dataset=data.complete, p=p), missing.mechanism.args))

  ldf.imp  <-
    do.call(imputeDataSimulation,
            c(list(dataset=data.missing, method=imputation.method),
                   imputation.args))
  imp.diff <-
    lapply(ldf.imp,
           function(dfx) mseImputation(dfx, data.missing, data.complete))

  imp.diff[[1]]
}

##' Taking from a simulation vector
##' @param x, a vector with names containing a dot "." used to split them
##' @param col.names, a 3 dimension character vector, containing the name of
##'   the resulting data.frame
vector2df <- function(x, col.names){
  stopifnot(length(col.names) == 3)
  nx <- strsplit(names(x), "\\.")
  df <- mapply(function(name, value) {
   type <- paste0(name[-1], collapse='')
   res <- list(name[1], type, value)
   names(res) <- col.names
   res
  }, name=nx, value=x)
  data.frame(lapply(as.data.frame(t(df)), unlist)) # transform into data.frame
}
