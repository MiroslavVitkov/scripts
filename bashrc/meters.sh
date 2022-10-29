#!/usr/bin/bash

while true
do
    BR=$(cat /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness)
    BR_FRACTION=$(calc -d "$BR / 96000")
    BAT=$(acpi)  # cut
    TIME=$(date)

    clear
    printf "%s\n" "$TIME"
    printf "%s\n" "$BAT"
    printf "brightness: %f" "$BR_FRACTION"
    sleep 2

done
exit
