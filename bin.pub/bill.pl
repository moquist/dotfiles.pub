#!/usr/bin/perl -w

use Getopt::Std;

# sum all the input, instead of stopping at the first "Sent invoice..." line
our $opt_a;

# print all the log entries for this category
our $opt_l;
my @log_list;
my $log_date = '';
my $log_on = 0;

# sum all the unpaid input (i.e., stop when we see "sent invoice.*paid")
our $opt_p;

# print invoiced v. paid
our $opt_i;

# print the total hours/days as well as $$
our $opt_t;

# process only the indicated year
our $opt_y;
my $foundyear = 0;

getopts("l:aipty:");

if (defined($opt_p)) { $opt_a = 1; }
if (defined($opt_y)) { $opt_a = 1; }

my $dblchk_total_a = 0;
my $dblchk_total_b = 0;
my %totals = (
    'money' => ('default' => 0),
    'time' => ('default' => 0),
    'invoiced' => 0,
    'paid' => 0,
);
foreach my $line (<STDIN>) {
  chomp $line;

  if (defined($opt_i)) {
      if (defined($opt_y)) {
          if ($line !~ /$opt_y-[0-9]/) {
              # Skip this line, it's not for our year
              next;
          }
      }
      if ($line =~ /^# Sent invoice/i) {
          if ($line =~ /^# Sent invoice [#0-9-]* for \$*([0-9\.]+)[, ]*/i) {
              $totals{'invoiced'} += $1;
          } else {
              print "invoice formatting error: $line\n";
              next;
          }
      }

      if ($line =~ /^# paid/i) {
          if ($line =~ /^# paid[, ]* \$*([0-9\.]+)[, ]*/i) {
              $totals{'paid'} += $1;
          } else {
              print "paid formatting error: $line\n";
              next;
          }
      }
      next;
  }

  if (!defined($opt_a) and $line =~ /sent invoice/i) { last; }
  if (!defined($opt_a) and $line =~ /updated books/i) { last; }
  if (defined($opt_p) and $line =~ /sent invoice.*paid/i) { last; }

  # We don't need to look for the year here if we're just adding up
  # invoiced/paid; that's handled in that += code below.
  if (defined($opt_y)) {
      if (!$foundyear) {
          if ($line =~ /^[SMTWF].*$opt_y$/) {
              # We've found `date` output from the specified year, so start processing
              $foundyear = 1;
          } else {
              next;
          }
      } else {
          if ($line =~ /^[SMTWF]/) {
              if ($line !~ /$opt_y$/) {
                  # We've gone past the specified year, so stop processing
                  $foundyear = 0;
              }
          }
      }
  }

  if ($line !~ /^ *(?:time|item): /) {
      if ($log_on) {
          if ($line =~ /^ /) {
              push @log_list, $line;
          } else {
              $log_on = 0;
          }
      }
      if ($line =~ /^[SMTWF]/) {
          # Remember this date in case we find an item for which we want to
          # catch logging; we can then include this date.
          $log_date = $line;
      }
  } else {
    $ok = 0;
    # grab the hours, rate, and total
    if ($line =~ /^ *(?:time|item): ([0-9\.]+) *[a-z_.-]+ *@([\-0-9\.]+) *\(\$([\-0-9\.]+)\) *(?:\[(.*)\])?/) {

      my $hours = $1;
      my $rate = $2;

      my $precalc_pay = undef;
      if (defined($3)) { $precalc_pay = $3; }

      my $cats = undef;
      if (defined($4)) { $cats = $4; }

      my $total_a = ($hours * $rate);
      my $total_b = undef;
      if (defined($precalc_pay)) { $total_b = $precalc_pay; }
      if (abs($total_a - $total_b) > .25) {
        # uh-oh!  print the error
        print "a: $total_a != b: $total_b\n";
        print "Error line: $line\n";
        next;
      }
      $dblchk_total_a += $total_a;
      $dblchk_total_b += $total_b;
      # everything checks out; categorize and add it
      if (defined($cats)) {
        my $percent_sum = 0;
        $cats =~ s/,/ /g;
        my %tmpcats = ('money' => undef, 'time' => undef);

        if (defined($opt_l)) {
            if ($cats =~ /$opt_l/) {
                $log_on = 1;
                push @log_list, "\n".$log_date;
                push @log_list, $line;
                $log_date = '';
            } else {
                $log_on = 0;
            }
        }

        foreach my $cat (split /[ \t,]/, $cats) {
          if ($cat =~ /([^\(]+)(?:\(([0-9]+)\))?/) {
            $cat = lc $1;
            if (!defined($2)) {
              $percent = 100;
            } else {
              $percent = $2;
            }
            $tmpcats{'money'}{"$cat"} = $total_a * $percent / 100;
            $tmpcats{'time'}{"$rate"}{"$cat"} = $hours * $percent / 100;
            $percent_sum += $percent;
          } elsif (length($cat) > 0) {
            print "category/percentage format error\n";
          }
        }
        if ($percent_sum != 100) {
          print "percentage error\n";
        } else {
          foreach my $cat (keys %{$tmpcats{'money'}}) {
            if (!defined($totals{'money'}{"$cat"})) {
              $totals{'money'}{"$cat"} = 0;
              $totals{'time'}{"$rate"}{"$cat"} = 0;
            }

            $totals{'money'}{"$cat"} += $tmpcats{'money'}{"$cat"};
            $totals{'time'}{"$rate"}{"$cat"} += $tmpcats{'time'}{$rate}{"$cat"};
          }
          $ok = 1;
        }
      } else {
        $totals{'money'}{"default"} += $total_a;
        $totals{'time'}{$rate}{"default"} += $hours;
        $ok = 1;
      }
    } else {
      print "formatting error: $line\n";
      next;
    }
    if ($ok == 0) {
      print "unknown error: $line\n";
    }
  }
}
my $grand_total = 0;
foreach my $key (sort keys %{$totals{'money'}}) {
  print "$key: $totals{'money'}{$key}\n";
  $grand_total += $totals{'money'}{$key};
}
print "\nInvoice total: $grand_total\n";
print "double-check a: $dblchk_total_a\n";
print "double-check b: $dblchk_total_b\n";

$grand_total = 0;
my @time_list = ();
if (defined($opt_t)) {
  print "Hours/Miles:\n";
  foreach my $rate (sort keys %{$totals{'time'}}) {
    foreach my $cat (sort keys %{$totals{'time'}{$rate}}) {
      push @time_list, "\t$cat: $totals{'time'}{$rate}{$cat} units \@$rate\n";
      $grand_total += $totals{'time'}{$rate}{$cat};
    }
  }
  print sort @time_list;
}

if (defined($opt_i)) {
    my $diff = $totals{'invoiced'} - $totals{'paid'};
    print "\n\n";
    print "Invoiced: $totals{'invoiced'}\n";
    print "Paid: $totals{'paid'}\n";
    print "Difference: $diff\n";
}

if ($opt_l) {
    foreach my $liner (@log_list) {
        print $liner."\n";
    }
}
