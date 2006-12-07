#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$| = 1;

my $header  = 20;
my $average = 1;
my $dcolumn = 10;
my $tcolumn = 10;
my $options = { FileStats => 1 };
my @order   = qw(fhalloc fhfree fhmax inalloc infree inmax dentries unused agelimit wantpages);
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

   my $pstat = $stats->{FileStats};
   printf "%${tcolumn}s", $_ for ($date, $time);
   printf "%${dcolumn}s", $pstat->{$_} for @order;
   print "\n";

   $h = $header if --$h == 0;
}

