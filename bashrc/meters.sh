#!/usr/bin/bash


# In this file: terminal based status bar. Intended for ratpoison.


# Settings.
BAT_CRITICAL=20  # Threshold to start blinking; battery low, [%].
BAT_WARN=40  # Threshold for non-blinking warning,[%].
REFRESH_PERIOD=2  # Seconds.
BR_FILE='/sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-eDP-1/intel_backlight/brightness'
BR_MAX=96000  # Brightness, max allowable value.
FIELD_SEPARATOR=';   '
PING_TARGET='abv.bg'


# Constants.
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
DEFAULT=$(tput sgr0)
TMP_FILE="$(mktemp)"


# Discard 'EET 2023'.
function print_time
{
    if [[ $(date) =~ (.*)\ EET ]]; then local DATE="${BASH_REMATCH[1]}"; fi
    printf "%s$FIELD_SEPARATOR" "$DATE"
}


# Read battery status and present it concisely.
# If the battery is failing: blink to attract attention.
IS_RED=0
function print_battery
{
    # Read the value, [%].
    local BAT=$(acpi | sed 's/Battery 0: //' | sed 's/Discharging/DISCHARGING/')

    # Trim trailing estimated times.
    # Not too accurate and take a lot of space.
    if [[ "$BAT" =~ (.+[0-9]+%), ]]; then BAT="${BASH_REMATCH[1]}"; fi

    # Blink bright colours if low and discharging.
    local DISCHARGING=$(! echo "$BAT" | grep DISCHARGING > /dev/null ; echo "$?")
    if [[ "$BAT" =~ ([0-9]+)% ]]; then local PERCENT="${BASH_REMATCH[1]}"; fi

    BAT_COLOUR="$DEFAULT"
    if [[ "$DISCHARGING" -ne 0 ]]; then
        if [[ "$PERCENT" -le "$BAT_WARN" ]]; then
            BAT_COLOUR="$YELLOW"
        fi

        if [[ "$PERCENT" -le "$BAT_CRITICAL" ]]; then
            IS_RED=$(("$IS_RED" + 1))
            if [[ $(("$IS_RED" % 2)) -ne 0 ]]; then
                BAT_COLOUR="$WHITE"
            else
                BAT_COLOUR="$RED"
            fi
        fi
    fi

    # Gloriously print our result respecting global separator setting.
    printf "%s$FIELD_SEPARATOR" "${BAT_COLOUR}$BAT${DEFAULT}"
}


# Power to backlight, [% of max].
function print_brightness
{
    local BR=$(calc -d 100*$(cat "$BR_FILE")/"$BR_MAX")
    printf "br: %.2f%s" "$BR" "%$FIELD_SEPARATOR"
}


# Report CPU load.
function print_cpu
{
    local CPU=$(uptime | rev | cut -d' ' -f1,2,3 | rev) >> "$TMP_FILE"
    printf "%s$FIELD_SEPARATOR" "$CPU"
}


# Print temperature of the CPU die.
# Number of physical CPUs == 1 hardcoded.
function print_temperature
{
    PACK_TEMP=$(sensors | grep 'Package id 0:')
    if [[ "$PACK_TEMP" =~ ^"Package id 0:  +"([0-9]+"."[0-9]) ]]; then
        local TEMP="${BASH_REMATCH[1]}"
    fi
    printf "%sC$FIELD_SEPARATOR" "$TEMP"
}


function print_volume
{
    local VOL=$(amixer -M get Master | grep 'Front Left:')
    if [[ "$VOL" =~ '['([0-9]+)'%]' ]]; then
        local VOLUME="${BASH_REMATCH[1]}"
    fi
    printf "vol: %s$FIELD_SEPARATOR" "$VOLUME%"
}


function print_ping
{
    PING="$(ping -c1 $PING_TARGET | grep 'bytes from' | rev | cut -d' ' -f1,2 | rev | cut -d'=' -f2)"
    printf "%s$FIELD_SEPARATOR" "$PING"
}


# Calculate the whole screen before starting to draw it.
tput civis  # reverse with 'tput cnorm'.
while true
do
    print_time > "$TMP_FILE"
    print_battery >> "$TMP_FILE"
    print_brightness >> "$TMP_FILE"
    print_volume >> "$TMP_FILE"
    print_cpu >> "$TMP_FILE"
    print_temperature >> "$TMP_FILE"
    printf "free: %sG$FIELD_SEPARATOR" $(awk '/^Mem/ {print $4}' <(free -g)) >> "$TMP_FILE"
    print_ping >> "$TMP_FILE"

    clear
    cat "$TMP_FILE"
    sleep "$REFRESH_PERIOD"
done
