use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my @loadavg = qw(
   avg_1
   avg_5
   avg_15
);

my $sys = Sys::Statistics::Linux->new();
$sys->set(loadavg => 1);
my $stats = $sys->get;
ok(defined $stats->{loadavg}->{$_}, "checking loadavg $_") for @loadavg;
