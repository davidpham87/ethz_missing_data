(TeX-add-style-hook
 "semester_paper_sfs"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("report" "11pt" "a4paper" "twoside" "openright")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("ETHDAsfs" "english") ("natbib" "longnamesfirst") ("xcolor" "dvipsnames")))
   (add-to-list 'LaTeX-verbatim-environments-local "VerbatimOut")
   (add-to-list 'LaTeX-verbatim-environments-local "SaveVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "LVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "BVerbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Verbatim")
   (add-to-list 'LaTeX-verbatim-environments-local "Soutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Sinput")
   (add-to-list 'LaTeX-verbatim-environments-local "Loutput")
   (add-to-list 'LaTeX-verbatim-environments-local "Linput")
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
    "conclusion"
    "Appendix1"
    "report"
    "rep11"
    "ETHDAsfs"
    "hyperref"
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
    "listings"
    "xcolor")
   (TeX-add-symbols
    '("blue" 1)
    '("red" 1)
    '("orange" 1)
    '("yellow" 1)
    '("seashell" 1)
    '("gray" 1)
    '("Bruch" 2)
    '("aatop" 2))
   (LaTeX-add-environments
    "definition"
    "lemma"
    "theorem"
    "Coro"
    "example")
   (LaTeX-add-bibliographies
    "biblio.bib"))
 :latex)

