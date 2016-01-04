pckgs <- c('mi', 'mice', 'Amelia', # most modern multiple imput packages
           "norm", "cat", "mix", "pan", # the last four are from Schafer
           "data.table", "tables", # for analysis of the output
           "VIM", "softImpute", "simsalapar")
install.packages(pckgs)

pckgs.bio <- c("impute")
source("https://bioconductor.org/biocLite.R")
biocLite(pckgs.bio)
