pckgs <- c("data.table", "ggplot2", "simsalapar", "magrittr")

loaded.pckgs <- lapply(pckgs, function(x) do.call(library, args=list(x)))

################################################################################
### Utility functions

fctr2num <- function(x) levels(x)[x]

ReadRds <- function(imputation.methods, file.pattern){
  lapply(imputation.methods, function(s) {
    paste0("../simulation_rds/",
           paste0(c(file.pattern, s), collapse='_'),
           ".rds") %>% maybeRead
  })
}

################################################################################
### Data.table functions


SummaryBy <- function(array.list, s="error", margins=c(2, 3, 4), op=sum){
  arr <- getArray(array.list, s)
  apply(arr, margins, op) %>% array2df %>% as.data.table
}

### Avoid writting DT[eval(px[1] & ... & px[n])] everytime
filterPredicates <- function(DT, px) {
  Reduce(function(x, p) x[eval(p)], px, DT)
}

# Provide the by argument for summarizing by all columns but those
# given in p
byXprWithout <- function(DT, p){
  Filter(function(x) !(x %in% p),
         colnames(DT)) %>% paste0(collapse=',')
}


################################################################################
### Plots

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
    coord_cartesian(xlim=c(0, 2)) + coord_flip() +
    theme(legend.position='bottom')
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


################################################################################
### User Defined Function

### Function returning expression determining valid simulation
isValidSimulation <- function(){
  c(quote(!(missing.mechanism=='MARFrequency' & p >= 0.25)))
}
