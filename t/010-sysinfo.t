use strict;
use warnings;
use Test::More;
use Sys::Statistics::Linux;

my @pf = qw(
    /proc/sys/kernel/hostname
    /proc/sys/kernel/domainname
    /proc/sys/kernel/ostype
    /proc/sys/kernel/osrelease
    /proc/sys/kernel/version
    /proc/cpuinfo
    /proc/meminfo
    /proc/uptime
);

foreach my $f (@pf) {
    if (!-r $f) {
        plan skip_all => "$f is not readable";
        exit(0);
    }
}

plan tests => 10;

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
