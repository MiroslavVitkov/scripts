#!/usr/bin/bash


# In this file: terminal based status bar. Intended for ratpoison.
# TODO: perhaps include 'sensors' output in some way, for example the highest value?


# Settings.
BAT_CRITICAL=20  # Threshold to start blinking; battery low, [%].
BAT_WARN=40  # Threshold for non-blinking warning,[%].
REFRESH_PERIOD=2  # Seconds.
BR_FILE='/sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness'
BR_MAX=96000  # Brightness, max allowable value.
FIELD_SEPARATOR=';   '


# Constants.
RED=$(tput setaf 1)
WHITE=$(tput setaf 7)
DEFAULT=$(tput sgr0)
TMP_FILE="$(mktemp)"


# Read battery status and present it concisely.
# If the battery is failing: blink to attract attention.
function battery
{
    # Read the value, [%].
    local BAT=$(acpi | sed 's/Battery 0: //' | sed 's/Discharging/DISCHARGING/')

    # Blink bright colours if low and discharging.
    local DISCHARGING=$(! echo "$BAT" | grep DISCHARGING > /dev/null ; echo "$?")
    if [[ "$BAT" =~ ([0-9]+)%.* ]]; then echo INSIDE;local PERCENT="${BASH_REMATCH[1]}"; fi
    echo "[$PERCENT, $BAT_CRITICAL, $BAT]"
    if [[ "$DISCHARGING" -ne 0 ]] && [[ "$PERCENT" -le "$BAT_CRITICAL" ]]
    then
        if [[ "$BAT_COLOUR" == "$RED" ]]
        then
            BAT_COLOUR="$WHITE"
        else
            BAT_COLOUR="$RED"
        fi
    else
        BAT_COLOUR="$DEFAULT"
    fi

    # Gloriously print our result respecting global separator setting.
    printf "%s$FIELD_SEPARATOR" "${BAT_COLOUR}$BAT${DEFAULT}" >> "$TMP_FILE"
}


# Report CPU load.
function cpu
{
    local CPU=$(uptime | rev | cut -d' ' -f1,2,3 | rev) >> "$TMP_FILE"
    printf "%s$FIELD_SEPARATOR" "$CPU" >> "$TMP_FILE"
}


while true
do
    printf "%s$FIELD_SEPARATOR" "$(date)" > "$TMP_FILE"
    battery
    printf "brightness: %f$FIELD_SEPARATOR" $(calc -d $(cat "$BR_FILE") / "$BR_MAX") >> "$TMP_FILE"
    cpu
    printf "free: %sG" $(awk '/^Mem/ {print $4}' <(free -g)) >> "$TMP_FILE"

    clear
    cat "$TMP_FILE"
    sleep "$REFRESH_PERIOD"
done
