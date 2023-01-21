#!/usr/bin/bash


# In this file: terminal based status bar. Intended for ratpoison.
# TODO: perhaps include 'sensors' output in some way, for example the highest value?


# Settings.
BAT_CRITICAL=20  # Threshold for battery low, [%].
REFRESH_PERIOD=2  # Seconds.
BR_FILE='/sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness'
BR_MAX=96000  # Brightness, max allowable value.
FIELD_SEPARATOR=';   '
TMP_FILE="$(mktemp)"

# Constants.
RED=$(tput setaf 1)
WHITE=$(tput setaf 7)
DEFAULT=$(tput sgr0)


# Read battery status and present it concisely.
# If the battery is failing, blink to attract attention.
function battery
{
    # Read the value, [%].
    local BAT=$(acpi | sed 's/Battery 0: //' | sed 's/Discharging/DISCHARGING/')

    # Blink bright colours if low and discharging.
    local DISCHARGING=$(! echo "$BAT" | grep DISCHARGING > /dev/null ; echo "$?")
    if [[ "$BAT" =~ ^\w+,\s+(\d+)% ]]; then local PERCENT="${BASH_REMATCH[1]}"; fi
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
    printf "%s$FIELD_SEPARATOR" "${BAT_COLOUR}$BAT${DEFAULT}"
}


while true
do
    BR_FRACTION=$(calc -d $(cat "$BR_FILE") / "$BR_MAX")
    CPU=$(uptime | rev | cut -d' ' -f3,2,1 | rev)
    MEM=$(awk '/^Mem/ {print $4}' <(free -g))

    printf "%s;   " "$(date)" > "$TMP_FILE"
    battery >> "$TMP_FILE"
    printf "brightness: %f;   " "$BR_FRACTION" >> "$TMP_FILE"
    printf "%s;   " "$CPU" >> "$TMP_FILE"
    printf "free: %sG" "$MEM" >> "$TMP_FILE"

    clear
    cat "$TMP_FILE"
    sleep "$REFRESH_PERIOD"
done
