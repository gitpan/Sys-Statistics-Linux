use strict;
use warnings;
use Test::More tests => 4;
use Sys::Statistics::Linux;

my %PgSwStats = (
   pgpgin => undef,
   pgpgout => undef,
   pswpin => undef,
   pswpout => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(PgSwStats => 1);
sleep(1);
my $stats = $lxs->get;
ok(defined $stats->{PgSwStats}->{$_}, "checking PgSwStats $_") for keys %PgSwStats;
