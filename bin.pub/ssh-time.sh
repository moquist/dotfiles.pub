#!/usr/bin/env bash
# Log the amount of time it takes to establish an SSH connection to the
# specified TARGET_HOST.

TIMEFORMAT=%3R

SSID=$(nmcli connection show | grep wlp2s0 | awk '{print $1}')

if [ "jomo" != $SSID ]; then
    exit
fi

source /home/moquist/.keychain/$HOSTNAME-sh

TARGET_HOST="$1"
LOGFILE="$2"

echo >> "$LOGFILE"
{ time ssh $TARGET_HOST date --utc +\"%Y-%m-%dT%T %Z\"; } |& perl -0777 -pe 's/\R/  /g' >> "$LOGFILE"
