(TeX-add-style-hook
 "semester_paper_sfs"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("report" "11pt" "a4paper" "twoside" "openright")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("ETHDAsfs" "english") ("natbib" "longnamesfirst")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (TeX-run-style-hooks
    "latex2e"
    "Abstract"
    "Notation"
    "Introduction"
    "theoretical_background"
    "empirical_results"
    "Summary"
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
    "listings")
   (TeX-add-symbols
    '("Bruch" 2)
    '("aatop" 2))
   (LaTeX-add-environments
    "definition"
    "lemma"
    "theorem"
    "Coro"
    "example")
   (LaTeX-add-bibliographies
    "biblio.bib")))

