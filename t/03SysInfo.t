use strict;
use warnings;
use Test::More tests => 10;
use Sys::Statistics::Linux;
use Data::Dumper;

my %SysInfo = (
   hostname => undef,
   domain => undef,
   kernel => undef,
   release => undef,
   version => undef,
   memtotal => undef,
   swaptotal => undef,
   countcpus => undef,
   uptime => undef,
   idletime => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(SysInfo => 1);
my $stats = $lxs->get;

ok(defined $stats->{SysInfo}->{$_}, "checking SysInfo $_") for keys %SysInfo;
