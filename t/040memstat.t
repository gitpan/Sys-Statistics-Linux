use strict;
use warnings;
use Test::More tests => 12;
use Sys::Statistics::Linux;

my @memstats = qw(
   memused
   memfree
   memusedper
   memtotal
   buffers
   cached
   realfree
   realfreeper
   swapused
   swapfree
   swapusedper
   swaptotal
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(memstats => 1);
my $stats = $lxs->get;
ok(defined $stats->memstats->{$_}, "checking memstats $_") for @memstats;
