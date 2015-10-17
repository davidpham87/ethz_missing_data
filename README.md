# ethz_missing_data project: Nearest Neighbor and Other Modern Methods for Missing Data Imputation

This is the git repository for my project at ETH: _Nearest neighbor and other
modern methods for missing data imputation_.

## Introduction

Although modern data analysis and statistical methods nowadays cope with
unstructured data, the most commonly used learning procedures rely on data
shaped as matrix. With the advent of computational power and faster database
systems, the number recorded of features (commonly seen as the number of columns
of the spreadsheets) grew exponentially, making model selection receipts
increasingly popular. 

However, for any observation, the probability that some features are left
unrecorded (or missing) grows with the number of features. This effect is
worrisome, as it can induce bias and an underestimating of the statistical
variance. 

The theme of missing data is often left in the usual statistical university
curriculum, and this project provides a good opportunity to circumvent
inconvenience. The goal of this project is to study most classical and modern
algorithms and experiment them with R.

Most of the methods for missing data replacing (or imputing) the missing value
with a reasonable surrogate, often involving the notion of expected value or
mean.  Classical methods developed in the 1980s find the replacement through the
model based procedures whose algorithmic order is around the number of features
squared, implying their impracticality with bigger data matrix. In contrast,
modern methods often involve only a linear asymptotic order.
