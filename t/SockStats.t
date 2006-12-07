use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux;

my %SockStats = (
   used => undef,
   tcp => undef,
   udp => undef,
   raw => undef,
   ipfrag => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(SockStats => 1);
my $stats = $lxs->get;

ok(defined $stats->{SockStats}->{$_}, "checking SockStats $_") for keys %SockStats;
