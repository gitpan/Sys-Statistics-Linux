#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$| = 1;

my $header  = 20;
my $average = 1;
my $tcolumn = 10;
my $dcolumn = 10;
my $options = { CpuStats => 1 };
my @order   = qw(user nice system idle iowait total);
my $lxs     = Sys::Statistics::Linux->new( $options );
my $h       = $header;

while (1) {
   sleep($average);
   my $stats = $lxs->get;

   if ($h == $header) {
      printf "%${tcolumn}s", $_ for ('date', 'time');
      printf "%${dcolumn}s", $_ for ('cpu', @order);
      print "\n";
   }

   my ($date, $time) = $lxs->gettime;

   foreach my $cpu (keys %{$stats->{CpuStats}}) {
      my $cstat = $stats->{CpuStats}->{$cpu};
      printf "%${tcolumn}s", $_ for ($date, $time);
      printf "%${dcolumn}s", $cpu;
      printf "%${dcolumn}s", $cstat->{$_} for @order;
      print "\n";
   }
   $h = $header if --$h == 0;
}

