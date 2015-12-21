library(Amelia)
source('completion_fns.R')

FLAS <- readRDS('../data/FLAS_clean.rds')
dataset <- FLAS[-12]
amelia.args <- list(noms=c("lang", "age", "priC", "sex"), ords="grade_complete")

imputeDataAmelia <- function(dataset, n, ...){
  args <- list(...)
  a.out <- do.call(amelia, c(list(dataset, m=n), args))
  a.out$imputations
}


## Test
res <- do.call(imputeDataAmelia, c(list(dataset, 20), amelia.args))
stopifnot(sum(is.na(res[[1]]))==0)
