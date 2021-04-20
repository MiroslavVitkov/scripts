#!/usr/bin/env bash

zgrep -E [0-9]*\.[0-9]*\.[0-9]*\.[0-9] /var/log/apache2/access.log* | cut -d':' -f2 | cut -d' ' -f1 | uniq -d | wc -l
