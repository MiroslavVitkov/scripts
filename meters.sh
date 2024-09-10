#!/usr/bin/bash


# In this file: terminal based status bar. Intended for ratpoison.
# Depents: calc, sensors | acpi, bash regex.


set -euo pipefail


# Settings.
BAT_CRITICAL=20  # Threshold to start blinking; battery low, [%].
BAT_WARN=40  # Threshold for non-blinking warning,[%].
REFRESH_PERIOD=1  # Seconds, can be fractional.
BR_FILE='/sys/class/backlight/intel_backlight/brightness'
BR_MAX_FILE='/sys/class/backlight/intel_backlight/max_brightness'
FIELD_SEPARATOR=';   '
PING_TARGET='abv.bg'


# Constants.
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
WHITE=$(tput setaf 7)
DEFAULT=$(tput sgr0)
TMP_FILE="$(mktemp)"
BR_MAX="$(cat $BR_MAX_FILE)"

#printf "vol: %.2f$FIELD_SEPARATOR" "$VOLUME"
# Helpers.

# in - percentage
# out - fraction, rounded to 2 decimal places, leading 0. or trailing .00 stripped.
function percent_to_frac
{
    local FRAC=$(calc -d "$1" / 100)
    local ROUNDED=$(printf "%.2f" "$FRAC")
    if [[ "$ROUNDED" =~ '0'('.'[0-9]+) ]]; then
        ROUNDED="${BASH_REMATCH[1]}"
    fi
    if [[ "$ROUNDED" =~ ([0-9]+'.')'00' ]]; then
        ROUNDED="${BASH_REMATCH[1]}"
    fi
    echo "$ROUNDED"
}


# Actual worker procedures.
function print_time
{
    local DATE=$(date +"%a %d %b %R:%S")
    printf "%s$FIELD_SEPARATOR" "$DATE"
}


# Read battery status and present it concisely.
# If the battery is failing: blink to attract attention.
IS_RED=0
function print_battery
{
    # Read the value, [%].
    local BAT=$(acpi)
    local DISCHARGING=$(! echo "$BAT" | grep "Discharging" > /dev/null ; echo "$?")
    if [[ "$BAT" =~ ([0-9]+)% ]]; then
        local PERCENT="${BASH_REMATCH[1]}"; fi
    local FRACTION=$(percent_to_frac "$PERCENT")

    # Blink bright colours if low and discharging.
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

        local WARNING=" ${BAT_COLOUR}discharging${DEFAULT}"
    else
        local WARNING=""
    fi

    # Gloriously print our result respecting global separator setting.
    printf "bat: %s$WARNING$FIELD_SEPARATOR" "$FRACTION"
}


# Power to backlight, [% of max].
function print_brightness
{
    local BR_PER=$(calc -d $(cat "$BR_FILE")"*100/$BR_MAX")
    local BR=$(percent_to_frac "$BR_PER")
    printf "br: %s$FIELD_SEPARATOR" "$BR"
}


function print_volume
{
    local VOL=$(amixer -M get Master | grep 'Front Left:')
    local VOLUME=""
    if [[ "$VOL" =~ '['([0-9]+)'%]' ]]; then
        VOLUME=$(percent_to_frac "${BASH_REMATCH[1]}")
    fi
    printf "vol: %s$FIELD_SEPARATOR" "$VOLUME"
}


# Report CPU load.
function print_cpu
{
    local CPU=$(uptime | rev | cut -d' ' -f1,2,3 | rev) >> "$TMP_FILE"
    printf "load: %s$FIELD_SEPARATOR" "$CPU"
}


# Print temperature of the CPU die.
# Number of physical CPUs == 1 hardcoded.
function print_temperature
{
    PACK_TEMP=$(sensors | grep 'Package id 0:')  # Alternatively `acpi -t`.
    local TEMP='ERR'
    if [[ "$PACK_TEMP" =~ ^"Package id 0:  +"([0-9]+"."[0-9]) ]]; then
        TEMP="${BASH_REMATCH[1]}"
    fi
    printf "%s C$FIELD_SEPARATOR" "$TEMP"
}


function print_ping
{
    local PING="$(ping -c1 $PING_TARGET 2>/dev/null | grep 'bytes from' | rev | cut -d' ' -f1,2 | rev | cut -d'=' -f2)"
    if [[ ! "$PING" ]] ; then
        PING='no internet'
    fi
    printf "%s$FIELD_SEPARATOR" "$PING"
}


# To use, enable experimental mode of bluez:
# sudo sed -i "s/#Experimental = false/Experimental = true/" /etc/bluetooth/main.conf
# sudo systemct restart bluetooth
function print_blue_bat
{
    local BTBAT=$(bluetoothctl info | grep Battery)
    local BAT=""
    if [[ "$BTBAT" =~ '('([0-9]+)')' ]]; then
        BAT=$( percent_to_frac "${BASH_REMATCH[1]}" )
    fi
    if [[ "$BAT" ]]; then
        printf "bt: %s$FIELD_SEPARATOR" "$BAT"
    fi
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
    printf "free: %s G$FIELD_SEPARATOR" $(awk '/^Mem/ {print $4}' <(free -g)) >> "$TMP_FILE"
    print_ping >> "$TMP_FILE"
    print_blue_bat >> "$TMP_FILE"

    clear
    cat "$TMP_FILE"
    sleep "$REFRESH_PERIOD"
done
