use strict;
use warnings;
use Test::More tests => 6;
use Sys::Statistics::Linux;

my %CpuStats = (
   user => undef,
   nice => undef,
   system => undef,
   idle => undef,
   iowait => undef,
   total => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(CpuStats => 1);
sleep(1);
my $stats = $lxs->get;

ok(defined $stats->{CpuStats}->{cpu}->{$_}, "checking CpuStats $_") for keys %CpuStats;
