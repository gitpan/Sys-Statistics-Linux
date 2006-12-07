use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my %ProcStats = (
   new => undef,
   runqueue => undef,
   count => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(ProcStats => 1);
sleep(1);
my $stats = $lxs->get;

ok(defined $stats->{ProcStats}->{$_}, "checking ProcStats $_") for keys %ProcStats;
