#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

my $header  = 20;
my $average = 1;
my $dcolumn = 12;
my $tcolumn = 10;
my $options = { MemStats => 1 };
my @order   = qw(memused memfree memusedper memtotal buffers cached swapused swapfree swapusedper swaptotal);
my $lxs     = Sys::Statistics::Linux->new( $options );
my $h       = $header;

while (1) {
   sleep($average);
   my $stats = $lxs->get;

   if ($h == $header) {
      printf "%${tcolumn}s", $_ for ('date', 'time');
      printf "%${dcolumn}s", $_ for @order;
      print "\n";
   }

   my ($date, $time) = $lxs->gettime;

   my $pstat = $stats->{MemStats};
   printf "%${tcolumn}s", $_ for ($date, $time);
   printf "%${dcolumn}s", $pstat->{$_} for @order;
   print "\n";

   $h = $header if --$h == 0;
}

