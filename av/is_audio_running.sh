#!/bin/sh


# After thee script, run 'echo $?'
# != 0 -> no audio last 60 seconds
# 0 -> audio is being produced


grep 'state: RUNNING' /proc/asound/card*/pcm*/sub*/status
