source('output_analysis_fns.R')

FILE.PATTERN <- "imputation_fulldataset_20151230_2200"
IMPUTATION.METHODS <- c('amelia', 'impute.knn', 'mi', 'mice', 'softImpute')

all.rds <- ReadRds(IMPUTATION.METHODS, FILE.PATTERN)
names(all.rds) <- IMPUTATION.METHODS

sim.stats <- mapply(function(s, op) {
  f <- function(name) {
    SummaryBy(all.rds[[name]], s, op=op)[, imputation.method:=name]
  }

  cols <- c('missing.mechanism', 'n.imputation', 'p', 'imputation.method',
            'value')
  names(all.rds) %>% lapply(f) %>% rbindlist %>%
    setcolorder(cols) %>% setorderv(cols)
}, c('error', 'time') , c(sum, mean), SIMPLIFY=FALSE)

for (DT in sim.stats) DT[, p:=fctr2num(p)]

sim.stats <-
  lapply(sim.stats, function(DT) filterPredicates(DT, isValidSimulation()))

## Transfrom p into numerical vector



vals <- lapply(all.rds, getArray)
cols <- c('missing.mechanism', 'n.imputation', 'p', 'measures',
          'missing.random.seed', 'imputation.method', 'value')

vals.dt <- lapply(names(vals), function(s) {
  v <- vals[[s]]
  names(dimnames(v))[1] <- "measures"
  v %>% array2df %>% as.data.table %>%
    {.[, `:=`(p=fctr2num(p), imputation.method=s)]} %>%
    filterPredicates(isValidSimulation())
}) %>% rbindlist %>% setcolorder(cols) %>% setorderv(cols)

table(vals.dt[, is.na(value)])


by.xpr <- byXprWithout(vals.dt, c('imputation.method', 'value')) # all without the last argument
vals.dt[, ranking:=rank(value), by=eval(by.xpr)] # ranking: higher is better

by.xpr <- byXprWithout(vals.dt,
                       c('value', 'rank', 'measures', 'ranking'))
scores.dt <- vals.dt[, .(score=sum(ranking, na.rm=TRUE)), by=eval(by.xpr)]

### Plots of ranking
gg <- # ggplot(df.plot, aes(imputation.method, value)) +
  ggplot(scores.dt, aes(imputation.method, score, color=imputation.method)) +
  geom_violin() + stat_summary(fun.y=median, geom='point') +
  facet_wrap(c('p'), ncol=4) + theme_bw() +
  ylab("Ranking per dataset") + xlab("Missing Mechanism") +
  ggtitle("Quality of imputation by ranks\nper simulation") + coord_flip()

savePlot(gg, "full_ranking_plot", height=12, width=10)

### Plots of MSE
DT <- vals.dt

### MCAR
preds.low <- c(quote(missing.mechanism=="MCAR"), quote(p < 0.5), quote(imputation.method != 'softImpute'))
preds.high <- c(quote(missing.mechanism=="MCAR"), quote(p >= 0.5), quote(imputation.method != 'softImpute'))
preds.mar <- c(quote(missing.mechanism=="MARFrequency"), quote(imputation.method != 'softImpute'))

gg <- preds.low[1:2] %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MCAR, low probability of missingness', 'full_mcar_measures_prob_low')
gg <- preds.high[1:2] %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MCAR, high probability of missingness', 'full_mcar_measures_prob_high')

gg <- preds.low[1] %>% {filterPredicates(DT, .)} %>%
  imputationPlot('Missingness pattern: MCAR', 'full_mcar_imputation')

### MAR Frequency
gg <- preds.mar[1] %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MAR Frequency', 'full_marfrequency_measures')
gg <- preds.mar[1] %>% {filterPredicates(DT, .)} %>%
  imputationPlot('Missingness pattern: MARFrequency',
                 'full_marfrequency_imputation')

### Without SoftImpute
gg <- preds.low %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MCAR, low probability of missingness',
          'full_mcar_measures_prob_low_wo_softimpute')

gg <- preds.high %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MCAR, high probability of missingness',
          'full_mcar_measures_prob_high_wo_softimpute')

gg <- preds.low[c(1, 3)] %>% {filterPredicates(DT, .)} %>%
  imputationPlot('Missingness pattern: MCAR')
gg <- gg + coord_cartesian(ylim=c(0, 1))
savePlot(gg, 'full_mcar_imputation_wo_softimpute', height=16)

gg <- preds.mar %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MAR Frequency',
          'full_marfrequency_measures_wo_softimpute')

gg <- preds.mar %>% {filterPredicates(DT, .)} %>%
  imputationPlot('Missingness pattern: MARFrequency')
gg <- gg + coord_cartesian(ylim=c(0, 1))
savePlot(gg, 'full_marfrequency_imputation_wo_softimpute', height=16)
