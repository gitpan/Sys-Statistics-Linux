use strict;
use warnings;
use Test::More tests => 10;
use Sys::Statistics::Linux;

my @sysinfo = qw(
   hostname
   domain
   kernel
   release
   version
   memtotal
   swaptotal
   countcpus
   uptime
   idletime
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(sysinfo => 1);
my $stats = $lxs->get;
ok(defined $stats->sysinfo->{$_}, "checking sysinfo $_") for @sysinfo;
