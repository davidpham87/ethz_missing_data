pckgs <- c("data.table", "ggplot2", "simsalapar", "magrittr")

loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))

imputation.methods <- 'mice' # c('mi', 'mice')
                      
ReadRds <- function(imputation.methods){
  lapply(imputation.methods, function(s) {
    paste0("../simulation_rds/",
           "imputation_fulldataset_20151230_2200_",
           s, ".rds") %>% maybeRead
  })
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


sim.stats$time[missing.mechanism=='MCAR']
