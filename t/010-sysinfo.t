use strict;
use warnings;
use Test::More;
use Sys::Statistics::Linux;

my $ostest = 1;

my @pf = qw(
    /proc/sys/kernel/hostname
    /proc/sys/kernel/domainname
    /proc/sys/kernel/ostype
    /proc/sys/kernel/osrelease
    /proc/sys/kernel/version
    /proc/cpuinfo
    /proc/meminfo
    /proc/uptime
    /proc/net/dev
);

foreach my $f (@pf) {
    if (!-r $f) {
        $ostest = 0;
        last;
    }
}

if ($ostest) {
    plan tests => 20;

    my @sysinfo = qw(
        hostname domain kernel release
        version memtotal swaptotal countcpus
        pcpucount cpuinfo tcpucount interfaces
        uptime idletime
    );

    my $sys = Sys::Statistics::Linux->new();
    $sys->set(sysinfo => { init => 1, cpuinfo => 1 });
    my $stat = $sys->get;
    ok(defined $stat->sysinfo->{$_}, "checking sysinfo $_") for @sysinfo;
} else {
    plan tests => 4;
}

my %t_cpuinfo = (
    cpuinfo0 => '1 CPU',
    cpuinfo1 => 'cpu0 has 4 cores with hyper threading',
    cpuinfo2 => 'cpu0 has 6 cores with hyper threading, cpu1 has 6 cores with hyper threading',
    cpuinfo3 => 'cpu0 has 6 cores, cpu1 has 6 cores, cpu2 has 6 cores, cpu3 has 6 cores',
    cpuinfo4 => 'cpu0 has 1 core with hyper threading',
    cpuinfo5 => 'cpu0 has 1 core with hyper threading',
);

foreach my $file (keys %t_cpuinfo) {
    my $sys = Sys::Statistics::Linux::SysInfo->new(
        cpuinfo => 1,
        files => {
            path => "",
            meminfo  => "/proc/meminfo",
            sysinfo  => "/proc/sysinfo",
            uptime   => "/proc/uptime",
            hostname => "/proc/sys/kernel/hostname",
            domain   => "/proc/sys/kernel/domainname",
            kernel   => "/proc/sys/kernel/ostype",
            release  => "/proc/sys/kernel/osrelease",
            version  => "/proc/sys/kernel/version",
            netdev   => "/proc/net/dev",
            cpuinfo  => "t/examples/$file",
        }
    );
    my $stat = $sys->get;

    ok($t_cpuinfo{$file} eq $stat->{cpuinfo}, "$file ($stat->{cpuinfo})");
}
