use strict;
use warnings;
use Test::More;
use Sys::Statistics::Linux;

if (-r "/proc/$$/stat") {
    plan tests => 35;
} else {
    plan skip_all => "your system doesn't provide process statistics - /proc/<pid> is not readable";
    exit(0);
}

my @processes = qw(
    ppid
    nlwp
    owner
    pgrp
    state
    session
    ttynr
    minflt
    cminflt
    mayflt
    cmayflt
    stime
    utime
    ttime
    cstime
    cutime
    prior
    nice
    sttime
    actime
    vsize
    nswap
    cnswap
    cpu
    size
    resident
    share
    trs
    drs
    lrs
    dtp
    cmd
    cmdline
    wchan
    fd
);

my $sys = Sys::Statistics::Linux->new();
$sys->set(processes => 1);
sleep(1);
my $stats = $sys->get;

for my $pid (keys %{$stats->processes}) {
   ok(defined $stats->processes->{$pid}->{$_}, "checking processes $_") for @processes;
   last; # we check only one process, that should be enough
}
