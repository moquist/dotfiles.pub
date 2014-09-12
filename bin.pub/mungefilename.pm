#!/usr/bin/perl -w
# $Id: mungefilename.pm,v 1.1 2007/02/22 19:53:01 moquist Exp moquist $

sub mungefilename($) {
    $fn = shift;
    $fn = lc $fn;
    $fn =~ s#.{1,2}/##g;
    $fn =~ s/\&/and/g;
    $fn =~ s/ /-/g;
    $fn =~ s/[^a-z0-9_\.-]//g;
    $fn = `echo "$fn" | tr -s '_.-'`;
    $fn =~ s/[-_]\{2,\}/-/g;
    $fn =~ s/[^\.A-Za-z0-9]\././g;
    chomp $fn;
    return $fn;
}

1;
