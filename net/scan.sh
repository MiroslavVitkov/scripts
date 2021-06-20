#!/bin/sh

iwlist scan | grep -wE 'Cell|Channel:|Quality|Encryption key|ESSID|WPA|WPA2|Group Cipher|Pairwise Ciphers|Authentication Suites'
