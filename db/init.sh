#!/usr/bin/env bash

set -euo pipefail


# This script initializes a new MariaDB database,
# without root privileges,
# and connects to it.
# Learn SQL!
# Pre-requisetes: `pacman -Syu mariadb`


# Unprivilliged install.
# For production this should be in `/opt`,
# but this here is just for learning so let's be safe.
DB_DIR="/home/$(id -u -n)/.sql/dat"
SOCKET_DIR="/run/user/$(id -u)/mariadbtest"
SOCKET="$SOCKET_DIR/mysql.socket"


# Utility function.
# This also exists in `../bashrc/funcs`.
function run
{
    cd /tmp
    nohup "$@" &
    cd -
}


# Not used but too nice to pass on.
# Use as `err "Unable to do_something"`.
function err
{
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}


# Create a DB if running for the first time.
if [[ ! -d "$DB_DIR" ]]; then
    mysql_install_db --datadir="$DB_DIR"
fi


# Run the server if not running already.
mkdir -p "$SOCKET_DIR"
pidof mysqld
if [[ ! "$?" ]]; then
    run mysqld --socket="$SOCKET" --datadir="$DB_DIR"
fi


# Connect to the db.
mysql --socket="$SOCKET"


# Get started.
# show schemas like "%";
# show full tables from information_schema;
