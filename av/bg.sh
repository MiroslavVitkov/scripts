#!/usr/bin/sh

# Play a directory shuffled.
# How can I make this interruptable, especially by mpsyt?
# Prhaps cron?

mpv --no-video --shuffle .
#grep 'state: RUNNING' /proc/asound/card*/pcm*/sub*/status; echo $?
