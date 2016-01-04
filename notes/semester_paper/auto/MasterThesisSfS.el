(TeX-add-style-hook
 "MasterThesisSfS"
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
    "Chapter1"
    "Summary"
    "Appendix1"
    "Appendix2"
    "Epilogue"
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
    "myReferences")
   (LaTeX-add-color-definecolors
    "Mygrey"
    "Cgrey")))

