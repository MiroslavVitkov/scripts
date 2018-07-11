#!/bin/sh

# $1 - string to log
# $2 - minimum verbosity
# $3 - method of logging (stdout/file/espeak/null)



# 0 - verbose debug
# 1 - debug
# 2 - major events
# 3 - errors
# Used for debug tracing.
log()
{
    :                  # No logs
    echo "log: $1"     # Log to stdout
                       # Log to a file
                       # Say out loud
}
