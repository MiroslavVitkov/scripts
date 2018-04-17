#!/bin/bash

# Scan all broadcasting wireless routers in range
# and list those with encryption turned off.

# Depends on: iwlist(from iwtools)

iwlist scan 2>/dev/null | grep 'Encryption key:off' -C1
