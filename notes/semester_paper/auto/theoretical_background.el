(TeX-add-style-hook
 "theoretical_background"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Soutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Sinput")
   (add-to-list 'LaTeX-verbatim-environments-local "Loutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Linput")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "Verb")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb")
   (LaTeX-add-labels
    "sec:source-missingness"
    "sec:stand-appr-miss"
    "sec:compl-case"
    "eq:svd"
    "enumerate:step:svd:begin"
    "eq:completesvd"
    "enumerate:step:svd:end")
   (LaTeX-add-environments
    '("innerlist" LaTeX-env-args ["argument"] 0)))
 :latex)

