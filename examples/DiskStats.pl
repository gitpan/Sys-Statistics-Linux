#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$| = 1;

my $header  = 20;
my $average = 1;
my $tcolumn = 10;
my $dcolumn = 10;
my $options = { DiskStats => 1 };
my @order   = qw(major minor rdreq rdbyt wrtreq wrtbyt ttreq ttbyt);
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

   foreach my $device (keys %{$stats->{DiskStats}}) {
      my $dstat = $stats->{DiskStats}->{$device};
      printf "%${dcolumn}s", $_ for ($date, $time);
      printf "%${tcolumn}s", $device;
      printf "%${tcolumn}s", $dstat->{$_} for @order;
      print "\n";
   }
   $h = $header if --$h == 0;
}

