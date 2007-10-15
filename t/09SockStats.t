use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux;

my %SockStats = (
   used => undef,
   tcp => undef,
   udp => undef,
   raw => undef,
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(SockStats => 1);
my $stats = $lxs->get;

ok(defined $stats->{SockStats}->{$_}, "checking SockStats $_") for keys %SockStats;

SKIP: { # because ipfrag is only available by kernels > 2.2
    skip "checking SockStats ipfrag", 1
        if ! defined $stats->{SockStats}->{ipfrag};
    ok(1, "checking SockStats ipfrag");
}
