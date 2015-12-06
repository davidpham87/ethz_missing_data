## Problem: does not handle categorical data.
library(softImpute)
source('completion_fns.R')

FLAS <- readRDS('../data/FLAS_clean.rds')
dataset <- FLAS[-12]

imputeDataSoftImpute <- function(dataset, ...){
  args <- list(...)

  to.keep <- sapply(1:ncol(dataset), function(jdx)
    !any(c("factor", "string") %in% class(dataset[1, jdx])))

  data.numerical <- dataset[, to.keep]
  x <- as.matrix(data.numerical)
  fit <- do.call(softImpute::softImpute, c(list(x), args))
  dataset[, to.keep] <- softImpute::complete(x, fit)
  list(dataset)
}
################################################################################

## Test
to.keep <- sapply(1:ncol(dataset), function(jdx)
  !any(c("factor", "string") %in% class(dataset[1, jdx])))

res <- imputeDataSoftImpute(dataset)
stopifnot(sum(is.na(res[[1]][, to.keep]))==0)
