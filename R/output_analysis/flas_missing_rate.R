setwd('../')
source('simulation_fns.R')
library(xtable)

FLAS <- loadFLASData()
gsub('2', '1', gsub('1', '0', gsub('0', '2', names(FLAS$missing.table))))
mt <- FLAS$missing.table
names(mt) <- gsub('2', '1', gsub('1', '0', gsub('0', '2', names(FLAS$missing.table))))
n <- unlist(lapply(strsplit(names(mt), ''), function(x) sum(x=="0")))
x <- as.data.table(data.frame(mt, prob=round(mt/105, 2), dim.missing=n, missing.rate=round(n/12, 2)))
x[, prob.Var1:=NULL]

x[order(-Freq)]


## Mean Missingness Rate for MAR
x[-1, sum(prob.Freq*missing.rate)]
