#!/usr/bin/env bash


# A quick and dirty tool to replace `mps-youtube`
# in the times it is down because of YouTube API changes
# or problems with the API key or whatever.
#
# Example use:
# sh yt.sh dQw4w9WgXcQ


# Be pedantic. Add `x` for verbosity.
set -euo pipefail


# Allocate a .tmp and .mp3 file and read $1.
PREFIX="https://youtube.com/watch?v="
FORMAT="-x --audio-format mp3"
FILE="$RANDOM"
ID="$1"
read -ra ARGS <<< $(echo "$FORMAT -o $FILE.tmp $PREFIX$ID")

# Do the work.
youtube-dl "${ARGS[@]}"
mpv --no-video "$FILE.mp3"

# No `trap` seems to be needed.
rm "$FILE.mp3"
