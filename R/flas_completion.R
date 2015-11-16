library('mice')
library('Hmisc')  #package for na.pattern() and impute()

set.seed(1)

FLAS <- readRDS('../data/FLAS.rds')

## Complete the FLAS data set with the complete grades
## 0 = F, 1 = D, 2 = C, 3 = B, A = 4
lower.grades <- read.csv('../data/flas_lower_grades.csv')
grades <- as.numeric(FLAS[, 'grade']) + 2
for (i in seq(1, nrow(lower.grades))){
  grades[lower.grades[i, 1]] <-  lower.grades[i, 2]
}
grades <- factor(grades, labels=c('F', 'D', 'C', 'B', 'A'))
FLAS[, 'grade'] <- grades

saveRDS(FLAS, '../data/FLAS_clean.rds')

names(FLAS)  #show variable names
md.pattern(FLAS) #show patterns for missing data in 1st 4 vars
na.pattern(FLAS) #show patterns for missing data in 1st 4 vars

## TODO set the methods for imputations
imp <- mice(FLAS, 5) #do multiple imputation (default is 5 realizations)

stripplot(imp)
## for (iSet in 1:5) {  #show results for the 5 imputation datasets
##   fit<- glm(hired ~ FLASy + gender + natamer,
##             data=complete(imp, iSet), family=binomial)  #fit to iSet-th realization
##   print(summary(fit))
## }
