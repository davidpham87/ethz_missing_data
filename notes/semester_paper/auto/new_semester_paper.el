(TeX-add-style-hook
 "new_semester_paper"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("report" "11pt" "a4paper" "twoside" "openright")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("ETHDAsfs" "english") ("natbib" "longnamesfirst")))
   (add-to-list 'LaTeX-verbatim-environments-local "Soutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Sinput")
   (add-to-list 'LaTeX-verbatim-environments-local "Loutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Linput")
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "Verb")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "Verb")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (TeX-run-style-hooks
    "latex2e"
    "Abstract"
    "Notation"
    "theoretical_background"
    "empirical_results"
    "Appendix1"
    "Appendix2"
    "report"
    "rep11"
    "ETHDAsfs"
    "pdfpages"
    "amsbsy"
    "amssymb"
    "graphicx"
    "natbib"
    "texab"
    "amsmath"
    "enumerate"
    "relsize"
    "color"
    "fancyvrb"
    "listings")
   (TeX-add-symbols
    '("HRule" ["argument"] 0)
    '("file" 1)
    '("Bruch" 2)
    '("aatop" 2)
    "plim"
    "Rcode"
    "LL"
    "cmd")
   (LaTeX-add-environments
    '("Soutput" LaTeX-env-args ["argument"] 0)
    '("Sinput" LaTeX-env-args ["argument"] 0)
    '("Loutput" LaTeX-env-args ["argument"] 0)
    '("Linput" LaTeX-env-args ["argument"] 0)
    "definition"
    "lemma"
    "theorem"
    "Coro"
    "example")
   (LaTeX-add-bibliographies
    "biblio.bib")
   (LaTeX-add-color-definecolors
    "Mygrey"
    "Cgrey")
   (LaTeX-add-listings-lstdefinestyles
    "input"
    "output"
    "Lstyle"
    "Rstyle")))

