#!/bin/bash
# Connects to a wifi network.
# Do make the config file readable only by root!


IFACE='wlp1s0'
CONF='/etc/wpa_supplicant/conf'
TMPFILE='tmp/connect.sh.tmp.verytemporaryfile'

# Used for debug tracing.
log()
{
    :                  # No logs
    echo "log: $1"     # Log to stdout
                       # Log to a file
}


say()
{
    espeak -v us-mbrola-1 "$1"
}


clean_up()
{
    log 'Cleaning up.'
    killall wpa_supplicant dhclient 1> xargs log 2> xargs log  # BUG: creates file 'xargs'
    sleep 1
}


connect()
{
    log 'Connecting.'
    wpa_supplicant -c"$CONF" -i"$IFACE" -B 1>/dev/null 2>/dev/null
    dhclient -v "$IFACE" 1>/dev/null 2>/dev/null
}


# Continuously check that all is good.
test()
{
    traceroute abv.bg 1>/dev/null 2>/dev/null
    if [ $? -eq 0 ]; then
        echo 'true'
    else
        echo 'false'
    fi
}


connection_lost()
{
    log 'Connection lost.'
    say 'disconnected'
}


connection_established()
{
    log 'Connection established.'
    say 'connected'
}


main()
{
    WAS_CONNECTED=$(test)
    while [ true ]; do
        CONNECTED=$(test)
        log "state: $WAS_CONNECTED $CONNECTED"

        if [[ "$WAS_CONNECTED" == 'false' && "$CONNECTED" == 'true' ]]; then
            connection_established
        fi

        if [[ "$WAS_CONNECTED" == 'true' && "$CONNECTED" == 'false' ]]; then
            connection_lost
            clean_up
            connect
        fi

        if [[ "$WAS_CONNECTED" == 'false' && "$CONNECTED" == 'false' ]]; then
            clean_up
            connect
        fi

        #if [[ "$WAS_CONNECTED" == 'true' && "$CONNECTED" == 'true' ]]; then
            # All is fine.
        #fi

        WAS_CONNECTED="$CONNECTED"
    done
}


main
