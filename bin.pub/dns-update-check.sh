#!/usr/bin/env bash

set -e
if [ "$DEBUG" ]; then set -x; fi

domain="$1"
hostname="$2"

function usage {
    echo "dns-update-check.sh <domain> <host>"
}

if [ ! "$domain" ]; then
    echo missing domain
    usage
    exit 1
fi

if [ ! "$hostname" ]; then
    echo missing hostname
    usage
    exit 1
fi

for server in $(dig +noall +answer NS "$domain" | awk '{print $NF}'); do
    dig +noall +answer @$server "$hostname"
done
