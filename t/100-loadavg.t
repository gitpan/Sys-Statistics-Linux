use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my @loadavg = qw(
   avg_1
   avg_5
   avg_15
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(loadavg => 1);
my $stats = $lxs->get;
ok(defined $stats->{loadavg}->{$_}, "checking loadavg $_") for @loadavg;
