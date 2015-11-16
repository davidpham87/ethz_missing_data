import os
import sys
from cStringIO import StringIO
from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage

# Copy-paste from
# https://www.binpress.com/tutorial/manipulating-pdfs-with-python/167

pagenums = set()
output = StringIO()
manager = PDFResourceManager()
converter = TextConverter(manager, output, laparams=LAParams())
interpreter = PDFPageInterpreter(manager, converter)

infile = open('data/flas.pdf', 'rb')

for page in PDFPage.get_pages(infile, pagenums):
    interpreter.process_page(page)
infile.close()
converter.close()
text = output.getvalue()
output.close()
