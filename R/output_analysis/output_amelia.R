library(simsalapar)
library(ggplot2)

imputation.methods <- 'amelia'
sfile.path <- paste0("../simulation_rds/imputation_",
                     "20151230_2000_",
                     paste0(imputation.methods, collapse='_'),
                     ".rds")

res <- maybeRead(sfile.path)

SummaryBy <- function(array.list, s="error", margins=c(2, 3, 4), op=sum){
  arr <- getArray(array.list, s)
  apply(arr, margins, op)  
}

mapply(function(s, op) SummaryBy(res, s, op=op), 
       c('error', 'time'), 
       c(sum, mean), SIMPLIFY=FALSE)


