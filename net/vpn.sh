#!/usr/bin/env bash


# An unsuccessful(yet) attempt to perform tunelling for all protocols.



set -evx


# Create tunnel endpoints.
cd /tmp
su
nohup openvpn --remote 95.87.228.52 --dev tun1 --ifconfig 10.4.0.2 10.4.0.1 --verb 5 --secret /home/vorac/.ssh/openvpn/key --port 59999 &
ping 10.4.0.1

# Connect the two local networks.
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -A FORWARD -i tun+ -j ACCEPT
route add -net 10.0.0.0 netmask 255.255.255.0 gw 10.4.0.1
# set browser proxy settings or env http_proxy

