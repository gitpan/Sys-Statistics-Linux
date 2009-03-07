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

my $sys = Sys::Statistics::Linux->new();
$sys->set(sysinfo => 1);
my $stat = $sys->get;
ok(defined $stat->sysinfo->{$_}, "checking sysinfo $_") for @sysinfo;
