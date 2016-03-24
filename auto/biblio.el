(TeX-add-style-hook
 "biblio"
 (lambda ()
   (LaTeX-add-bibitems
    "gelman2006data"
    "gelman2011mi"
    "hastie1999impute"
    "hastie1999imputing"
    "hastie2015softimpute"
    "hofert2015simsalpar"
    "honaker2011amelia"
    "lichman2013yeast"
    "little2002statistical"
    "matloffblog2015"
    "schafer1997analysis"
    "schafer2002missing"
    "troyanskaya2001missing"
    "van2012flexible"
    "vanburren2011mice"
    "wikipediaImputation2015")
   (LaTeX-add-environments
    '("innerlist" LaTeX-env-args ["argument"] 0)))
 :bibtex)

