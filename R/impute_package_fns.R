library(impute)
source('completion_fns.R')

FLAS <- readRDS('../data/FLAS_clean.rds')
dataset <- FLAS[-12]

imputeDataImpute <- function(dataset, n=NULL, ...){
  args <- list(...)

  to.keep <- sapply(1:ncol(dataset), function(jdx)
    !any(c("factor", "string") %in% class(dataset[1, jdx])))

  data.numerical <- dataset[, to.keep]
  x <- as.matrix(data.numerical)
  fit <- do.call(impute::impute.knn, c(list(x), args))
  dataset[, to.keep] <- fit$data
  list(dataset, dataset)
}


## Test
to.keep <- sapply(1:ncol(dataset), function(jdx)
  !any(c("factor", "string") %in% class(dataset[1, jdx])))

res <- imputeDataImpute(dataset)
stopifnot(sum(is.na(res[[1]][, to.keep]))==0)
