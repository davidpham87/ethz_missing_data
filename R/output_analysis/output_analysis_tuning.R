source('output_analysis_fns.R')

# imputation.methods <- c('impute.knn', 'softImpute')
imputation.methods <- c('impute.knn', 'softImpute')

# all.rds <- ReadRds(imputation.methods, "imputation_tuning")
all.rds <- ReadRds(imputation.methods, 'imputation_20160117_2030')
names(all.rds) <- imputation.methods

sim.stats <- mapply(function(s, op) {
    f <- function(name) apply(getArray(all.rds[[name]], s), 2:3, op)
    names(all.rds) %>% lapply(f) ## %>% rbindlist ## %>%
    ## ## setcolorder(cols) %>% setorderv(cols)
}, c('error', 'time') , c(sum, mean), SIMPLIFY=FALSE)

names(sim.stats) <- imputation.methods


# Transfrom p into numerical vector
## for (DT in sim.stats) DT[, p:=fctr2num(p)]
## sim.stats <-
##   lapply(sim.stats, function(DT) filterPredicates(DT, isValidSimulation()))

print("Number of Errors with the simulation")
lapply(sim.stats$error, sum)
# xtable([value > 0], auto=TRUE)

vals <- lapply(all.rds, getArray)

cols <- c('p', 'measures', 'missing.random.seed', 'imputation.method',
          'imputation.args', 'value')

vals.dt <- lapply(names(vals), function(s) {
  v <- vals[[s]]
  names(dimnames(v))[1] <- "measures"
  v %>% array2df %>% as.data.table %>%
    {.[, `:=`(p=fctr2num(p), imputation.method=s)]}
}) %>% rbindlist %>% setcolorder(cols) %>% setorderv(cols)

table(vals.dt[, is.na(value)])

by.xpr <- byXprWithout(vals.dt, c('imputation.method', 'imputation.args', 'value')) # all without the last argument
vals.dt[, ranking:=rank(value), by=eval(by.xpr)] # ranking: higher is better

by.xpr <- byXprWithout(vals.dt,
                       c('value', 'rank', 'measures', 'ranking'))
scores.dt <- vals.dt[, .(score=sum(ranking, na.rm=TRUE)), by=eval(by.xpr)]
impute.knn.idx <- scores.dt[, imputation.method=='impute.knn']
scores.dt[impute.knn.idx, imputation.args:= paste('Impute.knn:', imputation.args)]
scores.dt[!impute.knn.idx, imputation.args:= paste('SoftImpute:', imputation.args)]

## MCAR
scores.dt[, imputation.args:= gsub('\\_', '\\\\_', imputation.args)]

### Plots of ranking
gg <- # ggplot(df.plot, aes(imputation.method, value)) +
  ggplot(scores.dt, aes(imputation.method, score, color=imputation.args)) +
  geom_boxplot(notch=TRUE) +
  facet_wrap(c('p'), ncol=2) + theme_bw() +
  ylab("Ranking per dataset") + xlab("Missing Mechanisg") +
  labs(colour='Tuning parameters') +
  theme(legend.position=c(0.75, 0.25)) +
  guides(col = guide_legend(ncol=2)) +
  ggtitle("Quality of imputation by ranks per simulation") + coord_flip()

savePlot(gg, "tuning_ranking_soft_impute_plot", height=8, width=8, TeX=TRUE)

### Plots of MSE
DT <- vals.dt

### MCAR

msePlotTuning <- function(DT){
  dev.new()
  gg <- # ggplot(df.plot, aes(imputation.method, value)) +
    ggplot(DT, aes(p, value, color=imputation.args)) + geom_boxplot(notch=TRUE) +
    facet_wrap('measures', ncol=3) +
    theme_bw() + ylab('MSE') + xlab("Feature") + ggtitle('MSE Per Column') +
    coord_cartesian(xlim=c(0, 2)) + coord_flip() +
    theme(legend.position='bottom')
  print(gg)
  gg
}

DT[p=='0.1'][, {msePlotTuning(.SD); 0}, ,by='imputation.method']
DT[p=='0.7'][, {msePlotTuning(.SD); 0}, ,by='imputation.method']
