#!/usr/bin/bash

while true
do
    BR=$(cat /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness)
    BR_FRACTION=$(calc -d "$BR / 96000")
    BAT=$(acpi | sed 's/Discharging/DISCHARGING/')
    TIME=$(date)
    CPU=$(uptime | cut -d' ' -f11,12,13)
    MEM=$(awk '/^Mem/ {print $4}' <(free -g))

    clear
    printf "%s,   " "$TIME"
    printf "%s,   " "$BAT"
    printf "brightness: %f,   " "$BR_FRACTION"
    printf "%s,   " "$CPU"
    printf "free: %s" "$MEM"
    sleep 2

done
