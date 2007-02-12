use strict;
use warnings;
use Test::More tests => 13;
use Sys::Statistics::Linux;

my %MemStats = (
   memused => undef,
   memfree => undef,
   memusedper => undef,
   memtotal => undef,
   buffers => undef,
   cached => undef,
   mapped => undef,
   slab => undef,
   dirty => undef,
   swapused => undef,
   swapfree => undef,
   swapusedper => undef,
   swaptotal => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(MemStats => 1);
my $stats = $lxs->get;
ok(defined $stats->{MemStats}->{$_}, "checking MemStats $_") for keys %MemStats;
