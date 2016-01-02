pckgs <- c("data.table", "ggplot2", "simsalapar", "magrittr")

loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))

imputation.methods <- c('amelia', 'impute.knn', 'mi', 'mice',
                        'softImpute')

ReadRds <- function(imputation.methods){
  lapply(imputation.methods, function(s) {
    paste0("../simulation_rds/", 
           "imputation_fulldataset_22151230_2200_",
           s, ".rds") %>% maybeRead
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

# Provide the by argument for summarizing by all columns but those
# given in p
byXprWithout <- function(DT, p){
  Filter(function(x) !(x %in% p), 
                 colnames(DT)) %>% paste0(collapse=',')
}

by.xpr <- byXprWithout(vals.dt, c('imputation.method', 'value'))
vals.dt[, ranking:=rank(-value), by=eval(by.xpr)] # ranking: higher is better


by.xpr <- byXprWithout(vals.dt, 
                       c('value', 'rank', 'measures', 'ranking'))
scores.dt <- vals.dt[, .(score=sum(ranking, na.rm=TRUE)), by=eval(by.xpr)]

# Creating ranks among imputations

## ftable(100*err, row.vars=rv, col.vars=cv)

### Plots
## df.plot <- na.omit(df.res) # subset(df.res, imputation.method!="softImpute"))
gg <- # ggplot(df.plot, aes(imputation.method, value)) +
  ggplot(scores.dt, aes(missing.mechanism, score, color=imputation.method)) +
  geom_boxplot() + facet_grid(measures~p, scales="free_y") +
  scale_x_discrete(labels=c("MCAR"="MCAR", "MARFrequency"="MAR")) + theme_bw() +
  ylab("MSE") + xlab("Missing Mechanism") + ggtitle("Missing simulation on FLAS")

pdf("../plot/test_plot.pdf", height=12, width=10)
print(gg)
dev.off()

## library('tikzDevice')
## options(tikzDefaultEngine = 'pdftex')
## tikz('test_plot.tex', height=6.5, width=9)
## print(gg)
## dev.off()

## ggplot(data, aes(type, value, fill=method)) + geom_bar(stat='identity', position=position_dodge()) + scale_y_log10()

## TODO: check how one can use extra variable as varLists
## mayplot(vals, varList,
##         row.vars="imputation.method", col.vars="missing.mechanism", xvar="measures") # uses default
