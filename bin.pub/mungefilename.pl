#!/usr/bin/env perl
# $Id: mungefilename.pl,v 1.1 2007/02/22 19:53:01 moquist Exp moquist $

use Getopt::Std;

$both = 0;
$changes_only = 0;
$mv = '';
$newline = '';
$q = '';

# print both the old name and the new name
our $opt_b;

# only print the line if it changes
our $opt_c;

# add mv command (implies -bcqn)
our $opt_m;

# add newlines
our $opt_n;

# add quotes to names
our $opt_q;

getopts("bcmnq");

if (defined($opt_m)) {
    $mv = "mv";
    $opt_b = 1;
    $opt_c = 1;
    $opt_n = 1;
    $opt_q = 1;
    $changes_only = 1;
}
if (defined($opt_b)) { $both = 1; }
if (defined($opt_c)) { $changes_only = 1; }
if (defined($opt_n)) { $newline = "\n"; }
if (defined($opt_q)) { $q = "\""; }

require "/home/moquist/bin.pub/mungefilename.pm";
foreach my $fn (<STDIN>) {
    chomp($fn);
    $new_fn = &mungefilename($fn);
    if ($changes_only and $new_fn eq $fn) {
        next;
    }

    if ($both) {
        print "$mv $q$fn$q $q$new_fn$q$newline";
    } else {
        print $q.$new_fn.$q.$newline;
    }
}

