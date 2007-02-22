#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

my $column  = 20;
my $options = { SysInfo => 1 };
my @order   = qw(hostname domain kernel release version memtotal swaptotal countcpus uptime idletime);
my $lxs     = Sys::Statistics::Linux->new( $options );
my $stats   = $lxs->get;

my $timestamp = $lxs->gettime('Date: %Y-%m-%d, Time: %H:%M:%S');
print $timestamp, "\n";

foreach (@order) {
   printf "%-${column}s", $_;
   print "$stats->{SysInfo}->{$_}\n";
}
