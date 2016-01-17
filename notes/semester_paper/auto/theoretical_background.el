(TeX-add-style-hook
 "theoretical_background"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (LaTeX-add-labels
<<<<<<< Updated upstream
    "sec:compl-case"
=======
>>>>>>> Stashed changes
    "fig:geys1"
    "fig:geys2")))

