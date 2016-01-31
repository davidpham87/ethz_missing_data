(TeX-add-style-hook
 "empirical_results"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (LaTeX-add-labels
    "tbl:flas:numeric"
    "tbl:flas:factor"
    "eq:smse"
    "eq:score:imputation"
    "fig:tuning:param:softimpute:imputeknn"
    "fig:ranking:imputations"
    "fig:mse:mcar"
    "fig:mse:mar")))

