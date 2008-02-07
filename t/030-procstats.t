use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my @procstats = qw(
   new
   runqueue
   count
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(procstats => 1);
sleep(1);
my $stats = $lxs->get;
ok(defined $stats->procstats->{$_}, "checking procstats $_") for @procstats;
