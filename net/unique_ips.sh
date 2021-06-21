#!/usr/bin/env bash


# Print a breakdown of accesses by country of origin.



IPS=$(zgrep -E [0-9]*\.[0-9]*\.[0-9]*\.[0-9] /var/log/apache2/access.log* | cut -d':' -f2 | cut -d' ' -f1)

echo "$IPS" | while read IP
do
    python3 whois.py "$IP" >> results
done

sort < results | uniq -c | sort -rn
