library(impute)
source('completion_fns.R')

FLAS <- readRDS('../data/FLAS_clean.rds')
dataset <- FLAS[-12]

imputeDataImpute <- function(dataset, n=NULL, ...){
  args <- list(...)

  ## boolean vectors stating factors columns
  fctrs <- sapply(1:ncol(dataset), function(jdx)
    any(c("factor", "string") %in% class(dataset[1, jdx])))
  lvls <- lapply(dataset[, fctrs], levels)

  dataset[, fctrs] <- lapply(dataset[, fctrs], as.numeric)
  fit <- do.call(impute::impute.knn, c(list(as.matrix(dataset)), args))
  dataset <- as.data.frame(fit$data)

  ## Correct the factors
  f <- function(s) {
    cut(round(fit$data[, s]), c(0, seq_along(lvls[[s]])),
        labels=lvls[[s]], include.lowest=TRUE)
  }
  dataset[, fctrs] <- lapply(names(lvls), f)

  list(dataset, dataset)
}


## Test
to.keep <- sapply(1:ncol(dataset), function(jdx)
  !any(c("factor", "string") %in% class(dataset[1, jdx])))

res <- imputeDataImpute(dataset)
stopifnot(sum(is.na(res[[1]][, to.keep]))==0)
