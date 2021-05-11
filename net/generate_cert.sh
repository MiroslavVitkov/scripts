#!/usr/bin/env bash


# Generates certs.


set -e


openssl genrsa -out notEncodedPk.key 3072
openssl req -new -out website.csr -sha256 -key notEncodedPk.key
openssl x509 -req -in website.csr -days 365 -signkey notEncodedPk.key -out website.cert -outform PEM

