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
imputeDataMice <- function(dataset, n){
  imputations <- mice(dataset, n) # do multiple imputation (default is 5 realizations)
  data.mice <- lapply(1:n, function(i) mice::complete(imputations, i)) # mice and mi conflicts here
  return(data.mice)
}


##' Impute data with mice
##'
##'
##' @title Data imputation with mice
##' @param dataset, a data.frame containing missing values.
##' @param n, the number fo imputation to generate
##' @param column.type.mi, override of column type for the mi.
##' @return list of imputed data.frame
##' @author David Pham
imputeDataMi <- function(dataset, n, column.type.mi=NULL){
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

  imputations <- mi(mdf, n.iter=30, n.chains=4)
  data.mi <-  mi::complete(imputations, n) # creates 20 different versions of imputations

  ## mi append columns providing the stating the missingnes, so we have to delete them
  data.mi <- lapply(data.mi,  function(df) df[, 1:ncol(dataset)]) # restrict the number of columns
  return(data.mi)
}


##' Imputation dataset from mice and mi
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
##' @param missing.table, a vector containing the frequency of
##'   missingness. Result of na.pattern from Hmisc::na.pattern
##' @return a data.frame of the same dimension of dataset with missingnes
##'   pattern sampled from the missing table
##' @author David Pham
MARFrequency <- function(dataset, missing.table){
  mt <- missing.table
  ## missingnes matrix
  mm <- sapply(names(mt), function(s) as.numeric(strsplit(s, split='')[[1]]))
  ## select missingnes pattern
  mp <- sample(1:ncol(mm), nrow(dataset), replace=TRUE, prob=mt)
  res <- data.frame(dataset)
  for (i in 1:nrow(dataset)){
    res[i, ] <- ifelse(mm[, mp[i]]==1, NA, dataset[i,])
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
MCAR <- function(dataset, p=0.03, columns=1:ncol(dataset)){
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
##' numeric value
##' @title MSE of a single column
##' @param dfx, a list of data frame
##' @param idx, single integer defining which column is being compared
##' @param na.idx, row index where the data is missing for column idx
##' @param dataset.complete
##' @return
##' @author David Pham
mseImputationColumn <- function(dfx, idx, na.idx, dataset.complete){


  mseNum <- function(x, y) mean(sqrt(sum((x-y)^2)))
  mseFac <- function(x, y) mean(x!=y)

  df <- as.data.frame(lapply(dfx, '[', idx))
  df <- df[na.idx, ] # keep imputed values only # na.idx <- cols.na[[idx]]
  nc <- ncol(df)

  values.true <- dataset.complete[na.idx, idx] # keep only missing value

  if (!length(values.true)){
    return(NA)
  }

  is.factor.value <- any(c("factor", "string") %in% class(values.true[1]))
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
