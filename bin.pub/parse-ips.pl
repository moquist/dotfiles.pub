#!/usr/bin/perl -w
# Find and print IPv4 addresses in STDIN.

use Regexp::Common qw /net/;

while (<>) {
    @tok = split(/ /);
    foreach (@tok) {
        /($RE{net}{IPv4})/ and print "$1\n";
    }
}

