---
title: Missing Data - Introductory notes
author: David Pham
papersize: a4paper
numbersections: true
documentclass: article
subparagraph: true
latex-engine: pdflatex
geometry: margin=3.5cm
header-includes:
  - \setcounter{secnumdepth}{3}
  - \usepackage{microtype}
  - \usepackage{amsmath}
  - \usepackage{helvet}
toc: true
toc-depth: 1

---

These are my current notes and the themes 

# [Wikipedia](https://en.wikipedia.org/wiki/Imputation_(statistics))

#### Case deletion (CC)

The method does not introduce any bias if the missing values are uniformly
distributed.

#### Single imputation

If one sort the data matrix according some order, _Last observation carried
forward_ is the method of replacing the missing value with last valid value.

The missing value can also be replaced with the mean of the other observations,
however, correlations are attenuated.

Regression imputation use the other variables as predictors to replace the
missing value, although precision is misleadingly augmented, hence does not
reflect the statistical errors of the missing data. This problem is partially
solved by multiple imputation.

#### Multiple imputation

The multiple imputation [Rubin (1987)] is similar to bootstrapping method:
Missing variables are simulated, say $B$ times, and the desired statistics are
averaged except for the standard error which is constructed by adding the
variance of the imputed data and the within variance of each data set.

# [Matloff Blog post](https://matloff.wordpress.com/2015/09/16/new-r-softwaremethodology-for-handling-missing-dat/)

#### Complete-case analysis (CC), listwise deletion

Delete all record for which at least one variable is missing.

#### Single and multiple imputation

Estimation of the distribution of missing variables conditional on the others
and then sampling from that distirbution. Multiple alternate matrix are
generated without the NAs.

In multiple imputation, the distribution of each variable conditional and the
others is fitted and in case of missing value, a sample is drawn from this
distribution.

#### Available cases (AC), pairwise deletion

Keep the observation if the missing feature is not retained for the desired
measure, for example the correlation (where only 2 variables are needed). It
can, nonetheless, produce correlations over 1.

## MCAR: Missing Completely at Random

Let $Y$ the variable of interest, $M \in \{0, 1\}$ denotes if $Y$ is missing,
and $D$ the other variables than $Y$. This is often denoted as

\begin{align*}
P(M=1 \vert Y=s, D=t) = P(M=1),
\end{align*}

or equivalently

\begin{align*}
P(Y=s, D=t \vert M=i) = P(Y=s, D=t), i \in \{0, 1\}.
\end{align*}

## MAR: Missing at Random

For multiple imputation, one requires only $M \perp Y \vert D$, that is

\begin{align*}
P(M=1 \vert Y=s, D=t) = P(M=1 \vert D=t),
\end{align*}

### Conditional estimation under MAR

In practice, problems arise as $D$ might not hold any predictive ability of the
desired variable and that $D$ might as well contain missing data.  Interestingly

\begin{align*}
P(Y=s \vert D=t, M=i) 
  & = \frac{P(Y=s, D=t, M=i)}{P(D=t,M=i)} \\
  & = \frac{P(Y=s, D=t) P(M=i \vert Y=s, D=t)}{P(D=t,M=i)} \\
  & = \frac{P(Y=s \vert D=t)P(D=t)P(M=i \vert D=t)}{P(D=t,M=i)} \\
  & = P(Y=s \vert t).
\end{align*}

Hence if we are interested in the relationship between $Y$ and $D$, that is the
conditional distribution $Y$ given $D$, the fact that it is missing or not will
not introduce bias, hence _CC_ and _AC_ would perform equally well. This is
ironic as MAR is meant to apply where _CC_ and _AC_ should not be used.

### Unconditional estimation under MAR

Observe that 

\begin{align*}
P(Y=s \vert M=0) = \frac{P(M=0 \vert Y=s)}{P(M=0)}\ P(Y=s),
\end{align*}
hence our estimation of $P(Y=s)$ might still be biased with the factor of $P(M=0 \vert Y=s)/P(M=0)$.

# Gelman, Hill, Data analysis using regression and multilevel/hierarchical models

Chapter 25 of [@gelman2006data] contains information about missing values.

# Little, Robin, Statistical analysis with missing data

The monograph [@little2002statistical] describes mechanisms underlying the
missingness come in several type (_mi_, _mice_, _Amelia_ in R packages).

# Bibliography

[//]: # (TODO: understand the within variance data set term)
