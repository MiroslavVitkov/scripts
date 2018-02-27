#!/bin/sh
# Connects to a wifi network.
# Do make the config file readable only by root!


IFACE=wlp1s0
CONF=/etc/wpa_supplicant/conf


clean_up()
{
    killall wpa_supplicant dhclient
    sleep 1
}


connect()
{
    wpa_supplicant -c"$CONF" -i"$IFACE" -B
    dhclient -v "$IFACE"
}


# Continuously check that all is good.
test()
{
    traceroute abv.bg
}


main()
{
    while [ true ]; do
        clean_up
        connect
        until [ $? -ne 0 ]; do
            test
        done
        echo; echo; echo; echo 'Connection lost! Reconnecting...'; echo
    done
}


main
