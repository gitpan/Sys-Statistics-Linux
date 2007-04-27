#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

my $header   = 20;
my $interval = 1;
my $dcolumn  = 10;
my $tcolumn  = 10;
my @order    = qw(avg_1 avg_5 avg_15);
my $h        = $header;
my $lxs      = Sys::Statistics::Linux->new(LoadAVG => 1);

while (1) {
   my $stats = $lxs->get;

   if ($h == $header) {
      printf "%${tcolumn}s", $_ for ('date', 'time');
      printf "%${dcolumn}s", $_ for @order;
      print "\n";
   }

   my ($date, $time) = $lxs->gettime;

   my $pstat = $stats->{LoadAVG};
   printf "%${tcolumn}s", $_ for ($date, $time);
   printf "%${dcolumn}s", $pstat->{$_} for @order;
   print "\n";

   $h = $header if --$h == 0;
   sleep $interval;
}
