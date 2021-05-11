#!/usr/bin/env bash

#zgrep -E [0-9]*\.[0-9]*\.[0-9]*\.[0-9] /var/log/apache2/access.log* | cut -d':' -f2 | cut -d' ' -f1
A=$(zgrep -E [0-9]*\.[0-9]*\.[0-9]*\.[0-9] /var/log/apache2/access.log* | cut -d':' -f2 | cut -d' ' -f1)

for f in "$A"
do
    echo "$f"
#    python py-whois.py "$f"
done
