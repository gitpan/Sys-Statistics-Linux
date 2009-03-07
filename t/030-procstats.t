use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my @procstats = qw(
   new
   runqueue
   count
);

my $sys = Sys::Statistics::Linux->new();
$sys->set(procstats => 1);
sleep(1);
my $stats = $sys->get;
ok(defined $stats->procstats->{$_}, "checking procstats $_") for @procstats;
