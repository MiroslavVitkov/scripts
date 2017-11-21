#!/bin/sh
# Connects to a wifi network.
# Do make the config file readable only by root!

IFACE=wlp1s0
CONF=/etc/wpa_supplicant/conf

killall wpa_supplicant dhclient
sleep 1
wpa_supplicant -c"$CONF" -i$IFACE -B
dhclient -v $(IFACE)
ping abv.bg
