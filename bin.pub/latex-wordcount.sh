#!/bin/bash

set -ex

# texcount.pl is here: http://app.uio.no/ifi/texcount/download.html

wc=$(texcount.pl "$1" | grep 'Words in text' | awk '{print $NF}')
sed --in-place=noidnoid "s/^Word count:.*\$/Word count: $wc/i" "$1"
