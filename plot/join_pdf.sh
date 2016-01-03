rm -f full_all.pdf
rm -f partial_all.pdf

pdftk full*.pdf cat output full_all.pdf
pdftk partial*.pdf cat output partial_all.pdf
