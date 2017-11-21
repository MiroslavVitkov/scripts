#!/bin/sh

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=finished.pdf file1.pdf file2.pdf  # ghostscript concatinate .pdfs
