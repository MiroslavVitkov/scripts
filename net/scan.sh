#!/bin/sh

iwlist scan | egrep -w 'Cell|Channel:|Quality|Encryption key|ESSID|WPA|WPA2|Group Cipher|Pairwise Ciphers|Authentication Suites'
