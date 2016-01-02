pckgs <- c("data.table", "ggplot2", "simsalapar", "magrittr")

loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))

imputation.methods <- c('amelia', 'impute.knn', 'mi', 'mice',
                        'softImpute')

ReadRds <- function(imputation.methods){
  lapply(imputation.methods, function(s) {
    paste0("../simulation_rds/",
           "imputation_fulldataset_20151230_2200_",
           s, "wo_lang.rds") %>% maybeRead
  })
}

SummaryBy <- function(array.list, s="error", margins=c(2, 3, 4), op=sum){
  arr <- getArray(array.list, s)
  apply(arr, margins, op) %>% array2df %>% as.data.table
}

fctr2num <- function(x) levels(x)[x]

isValidSimulation <- function(){
  c(quote(!(missing.mechanism=='MARFrequency' & p >= 0.25)))
}

filterPredicates <- function(DT, px) {
  Reduce(function(x, p) x[eval(p)], px, DT)
}

all.rds <- ReadRds(imputation.methods)
names(all.rds) <- imputation.methods

sim.stats <- mapply(function(s, op) {
  f <- function(name) {
    SummaryBy(all.rds[[name]], s, op=op)[, imputation.method:=name]
  }

  cols <- c('missing.mechanism', 'n.imputation', 'p', 'imputation.method',
            'value')
  names(all.rds) %>% lapply(f) %>% rbindlist %>%
    setcolorder(cols) %>% setorderv(cols)
}, c('error', 'time') , c(sum, mean), SIMPLIFY=FALSE)


# Provide the by argument for summarizing by all columns but those
# given in p
byXprWithout <- function(DT, p){
  Filter(function(x) !(x %in% p),
                 colnames(DT)) %>% paste0(collapse=',')
}

savePlot <- function(gg, pdf.file=NULL, height=8, width=12){
  if (!is.null(pdf.file)){
    paste0("../../plot/", pdf.file, '.pdf') %>% pdf(height=height, width=width)
    print(gg)
    dev.off()
  }
}

msePlot <- function(DT, plot.subtitle=NULL, pdf.file=NULL){
  ttl <- "MSE per column"
  ttl <-  if(is.null(plot.subtitle)) ttl else  paste0(ttl, '\n', plot.subtitle)
  ylb <- "MSE" # ylab
  gg <- # ggplot(df.plot, aes(imputation.method, value)) +
    ggplot(DT, aes(measures, value, color=imputation.method)) + geom_boxplot() +
    facet_wrap('p', ncol=3) +
    theme_bw() + ylab(ylb) + xlab("Feature") + ggtitle(ttl) +
    coord_cartesian(xlim=c(0, 2)) + coord_flip() + theme(legend.position='bottom')
  savePlot(gg, pdf.file, height=16)
  gg
}

imputationPlot <- function(DT, plot.subtitle=NULL, pdf.file=NULL){
  ttl <- "MSE per imputation method"
  ttl <-  if(is.null(plot.subtitle)) ttl else  paste0(ttl, '\n', plot.subtitle)
  ylb <- "MSE" # ylab
  gg <- # ggplot(df.plot, aes(imputation.method, value)) +
    ggplot(DT, aes(p, value, color=imputation.method)) + geom_boxplot() +
    ## stat_summary(fun.y=median, geom='point') +
    facet_wrap(c('measures'), ncol=2) +
    theme_bw() + ylab(ylb) + xlab("Probability of missingness") + ggtitle(ttl) +
    coord_cartesian(ylim=c(0, 2))  + theme(legend.position='bottom')
  savePlot(gg, pdf.file, height=16)
  gg
}

# Transfrom p into numerical vector
for (DT in sim.stats) DT[, p:=fctr2num(p)]

sim.stats <-
  lapply(sim.stats, function(DT) filterPredicates(DT, isValidSimulation()))


vals <- lapply(all.rds, getArray)

cols <- c('missing.mechanism', 'n.imputation', 'p',
          'measures', 'missing.random.seed', 'imputation.method',
          'value')

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

## MCAR

### Plots of ranking
gg <- # ggplot(df.plot, aes(imputation.method, value)) +
  ggplot(scores.dt, aes(imputation.method, score, color=imputation.method)) +
  geom_violin() + stat_summary(fun.y=median, geom='point') +
  facet_wrap(c('p'), ncol=4) + theme_bw() +
  ylab("Ranking per dataset") + xlab("Missing Mechanism") +
  ggtitle("Quality of imputation by ranks\nper simulation") + coord_flip()

pdf("../../plot/full_ranking_plot.pdf", height=12, width=10)
print(gg)
dev.off()

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
  imputationPlot('Missingness pattern: MCAR',
                 'full_mcar_imputation_wo_softimpute')

gg <- preds.mar %>% {filterPredicates(DT, .)} %>%
  msePlot('Missingness pattern: MAR Frequency',
          'full_marfrequency_measures_wo_softimpute')
gg <- preds.mar %>% {filterPredicates(DT, .)} %>%
  imputationPlot('Missingness pattern: MARFrequency',
                 'full_marfrequency_imputation_wo_softimpute')

## Library('tikzDevice')
## options(tikzDefaultEngine = 'pdftex')
## tikz('test_plot.tex', height=6.5, width=9)
## print(gg)
## dev.off()

## ggplot(data, aes(type, value, fill=method)) + geom_bar(stat='identity', position=position_dodge()) + scale_y_log10()

## TODO: check how one can use extra variable as varLists
## mayplot(vals, varList,
##         row.vars="imputation.method", col.vars="missing.mechanism", xvar="measures") # uses default
