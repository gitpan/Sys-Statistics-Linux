#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

my $header  = 20;
my $average = 1;
my $tcolumn = 10;
my $dcolumn = 10;
my $options = { Processes => 1 };

# you need a very very width screen for this output :-)

my @order = qw(
   pid ppid owner pgrp state session ttynr minflt cminflt mayflt cmayflt
   stime utime cstime cutime prior nice sttime actime vsize nswap cnswap
   cpu size resident share trs drs lrs dtp cmd cmdline
);

my $lxs = Sys::Statistics::Linux->new( $options );
my $h   = $header;

while (1) {
   sleep($average);
   my $stats = $lxs->get;

   if ($h == $header) {
      printf "%${tcolumn}s", $_ for ('date', 'time');
      printf "%${dcolumn}s", $_ for @order;
      print "\n";
   }

   my ($date, $time) = $lxs->gettime;

   foreach my $pid (keys %{$stats->{Processes}}) {
      next unless $pid == 1;
      my $pstat = $stats->{Processes}->{$pid};
      printf "%${tcolumn}s", $_ for ($date, $time);
      printf "%${dcolumn}s", $pstat->{$_} for @order;
      print "\n";
   }
   $h = $header if --$h == 0;
}

