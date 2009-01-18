use strict;
use warnings;
use Test::More tests => 35;
use Sys::Statistics::Linux;

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

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(processes => 1);
sleep(1);
my $stats = $lxs->get;

for my $pid (keys %{$stats->processes}) {
   ok(defined $stats->processes->{$pid}->{$_}, "checking processes $_") for @processes;
   last; # we check only one process, that should be enough
}
