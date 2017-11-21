#!/bin/sh
# Scan a multipage document.

rm /tmp/document*.tiff
scanimage --resolution 300 -x 800 -y 600 --format=tiff --batch=/tmp/document-p%d.tiff --batch-prompt
convert /tmp/document-p*.tiff -compress jpeg -quality 70 document.pdf
rm /tmp/document*.tiff
