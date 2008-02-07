use strict;
use warnings;
use Test::More tests => 116;
use Sys::Statistics::Linux;

my %wanted = (
    SysInfo => [ qw/
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
    /],
    CpuStats => [ qw/
        user
        nice
        system
        idle
        iowait
        total
    /],
    ProcStats => [ qw/
        new
        runqueue
        count
    /],
    MemStats => [ qw/
        memused
        memfree
        memusedper
        memtotal
        buffers
        cached
        realfree
        realfreeper
        swapused
        swapfree
        swapusedper
        swaptotal
    /],
    PgSwStats => [ qw/
        pgpgin
        pgpgout
        pswpin
        pswpout
    /],
    NetStats => [ qw/
        rxbyt
        rxpcks
        rxerrs
        rxdrop
        rxfifo
        rxframe
        rxcompr
        rxmulti
        txbyt
        txpcks
        txerrs
        txdrop
        txfifo
        txcolls
        txcarr
        txcompr
        ttpcks
        ttbyt
    /],
    SockStats => [ qw/
        used
        tcp
        udp
        raw
    /],
    DiskStats => [ qw/
         major
         minor
         rdreq
         rdbyt
         wrtreq
         wrtbyt
         ttreq
         ttbyt
    /],
    DiskUsage => [ qw/
         total
         usage
         free
         usageper
         mountpoint
    /],
    LoadAVG => [ qw/
        avg_1
        avg_5
        avg_15
    /],
    FileStats => [ qw/
        fhalloc
        fhfree
        fhmax
        inalloc
        infree
        inmax
        dentries
        unused
        agelimit
        wantpages
    /],
    Processes => [ qw/
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
    /],
);

my @options = keys %wanted;
my $lxs = Sys::Statistics::Linux->new(map { $_ => 1 } keys %wanted);
sleep 1;
my $stat = $lxs->get;

foreach my $opt (keys %wanted) {
    if ($opt =~ /^(?:CpuStats|NetStats|DiskStats|DiskUsage|Processes)\z/) {
        foreach my $x (keys %{$stat->{$opt}}) {
            print "$opt $x\n";
            ok(defined $stat->{$opt}->{$x}->{$_}, "checking $opt $_") for @{$wanted{$opt}};
            last; # we check only one process, that should be enough
        }
    } else {
        ok(defined $stat->{$opt}->{$_}, "checking $opt $_") for @{$wanted{$opt}};
    }
}
