use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux;

my @sockstats = qw(
   used
   tcp
   udp
   raw
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(sockstats => 1);
my $stats = $lxs->get;

ok(defined $stats->sockstats->{$_}, "checking sockstats $_") for @sockstats;

SKIP: { # because ipfrag is only available by kernels > 2.2
    skip "checking sockstats ipfrag", 1
        if ! defined $stats->sockstats->{ipfrag};
    ok(1, "checking sockstats ipfrag");
}
