#!/bin/bash

# Scan all broadcasting wireless routers in range
# and list those with encryption turned off.

# Depends on: iwlist(from iwtools)

STRING='Encryption key:off'
iwlist scan 2>/dev/null | grep "$STRING" -C1 | grep -v "$STRING"
