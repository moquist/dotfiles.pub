#!/bin/bash

wc=$(texcount.pl "$1" | grep 'Words in text' | awk '{print $NF}')
sed --in-place=noidnoid "s/^Word count:.*\$/Word count: $wc/" "$1"
