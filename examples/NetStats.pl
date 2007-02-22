#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

my $header  = 20;
my $average = 1;
my $tcolumn = 10;
my $dcolumn = 10;
my $options = { NetStats => 1 };
my @order   = qw(
   rxbyt rxpcks rxerrs rxdrop rxfifo rxframe rxcompr rxmulti
   txbyt txpcks txerrs txdrop txfifo txcolls txcarr txcompr
);
my $lxs     = Sys::Statistics::Linux->new( $options );
my $h       = $header;

while (1) {
   sleep($average);
   my $stats = $lxs->get;

   if ($h == $header) {
      printf "%${tcolumn}s", $_ for ('date', 'time');
      printf "%${dcolumn}s", $_ for ('iface', @order);
      print "\n";
   }

   my ($date, $time) = $lxs->gettime;

   foreach my $device (keys %{$stats->{NetStats}}) {
      my $dstat = $stats->{NetStats}->{$device};
      printf "%${tcolumn}s", $_ for ($date, $time);
      printf "%${dcolumn}s", $device;
      printf "%${dcolumn}s", $dstat->{$_} for @order;
      print "\n";
   }
   $h = $header if --$h == 0;
}

