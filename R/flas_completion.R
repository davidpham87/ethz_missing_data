library(mice)
library(mi)
library(Hmisc)  #package for na.pattern() and impute()
library(data.table)
library(parallel)

source('completion_fns.R')

set.seed(1)

options(mc.cores=max(detectCores()/2, 1)) # multithreading machine

FLAS <- readRDS('../data/FLAS.rds')

## Complete the FLAS data set with the complete grades
## 0 = F, 1 = D, 2 = C, 3 = B, A = 4
lower.grades <- read.csv('../data/flas_lower_grades.csv')
grades <- as.numeric(FLAS[, 'grade']) + 2

for (i in seq(1, nrow(lower.grades))){
  grades[lower.grades[i, 1]] <-  lower.grades[i, 2]
}

grades <- factor(grades, labels=c('F', 'D', 'C', 'B', 'A'))
FLAS[, 'grade_complete'] <- grades

saveRDS(FLAS, '../data/FLAS_clean.rds')

names(FLAS)  #show variable names
md.pattern(FLAS) #show patterns for missing data
na.pattern(FLAS) #show patterns for missing data

dataset <- FLAS
save.path <- '../data/FLAS_complete_average.rds'
column.type.mi <- list(grade_complete="ordered-categorical")
n <- 20

data.imputed <- imputeData(FLAS, n, column.type.mi) # Impute data from mice and mi
data.imputed <- do.call(c, data.imputed) # Flatten the variable as data imputed is a list of list of df.
data.average <- averagingImputations(data.imputed) # Mean for numerical value and mode otherwise

saveRDS(data.average, save.path)
