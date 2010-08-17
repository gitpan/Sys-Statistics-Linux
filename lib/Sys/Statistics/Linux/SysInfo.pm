=head1 NAME

Sys::Statistics::Linux::SysInfo - Collect linux system information.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::SysInfo;

    my $lxs  = Sys::Statistics::Linux::SysInfo->new;
    my $info = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::SysInfo gathers system information from the virtual F</proc> filesystem (procfs).

For more information read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 SYSTEM INFOMATIONS

Generated by F</proc/sys/kernel/{hostname,domainname,ostype,osrelease,version}>
and F</proc/cpuinfo>, F</proc/meminfo>, F</proc/uptime>, F</proc/net/dev>.

    hostname   -  The host name.
    domain     -  The host domain name.
    kernel     -  The kernel name.
    release    -  The kernel release.
    version    -  The kernel version.
    memtotal   -  The total size of memory.
    swaptotal  -  The total size of swap space.
    uptime     -  The uptime of the system.
    idletime   -  The idle time of the system.
    pcpucount  -  The total number of physical CPUs.
    tcpucount  -  The total number of CPUs (cores, hyper threading).
    interfaces -  The interfaces of the system.

    # countcpus is the same like tcpucount
    countcpus  -  The total (maybe logical) number of CPUs.

C<pcpucount> and C<tcpucount> are really easy to understand. Both values
are collected from C</proc/cpuinfo>. C<pcpucount> is the number of physical
CPUs, counted by C<physical id>. C<tcpucount> is just the total number 
counted by C<processor>.

If you want to get C<uptime> and C<idletime> as raw value you can set

    $Sys::Statistics::Linux::SysInfo::RAWTIME = 1;
    # or with
    Sys::Statistics::Linux::SysInfo->new(rawtime => 1)

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::SysInfo->new;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

    my $info = $lxs->get;

=head1 EXPORTS

No exports.

=head1 SEE ALSO

B<proc(5)>

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::SysInfo;

use strict;
use warnings;
use Carp qw(croak);

our $VERSION = '0.10';
our $RAWTIME = 0;
our $CPUINFO = 0;

sub new {
    my $class = shift;
    my $opts  = ref($_[0]) ? shift : {@_};

    my %self = (
        files => {
            path     => "/proc",
            meminfo  => "meminfo",
            sysinfo  => "sysinfo",
            cpuinfo  => "cpuinfo",
            uptime   => "uptime",
            hostname => "sys/kernel/hostname",
            domain   => "sys/kernel/domainname",
            kernel   => "sys/kernel/ostype",
            release  => "sys/kernel/osrelease",
            version  => "sys/kernel/version",
            netdev   => "net/dev",
        }
    );

    foreach my $file (keys %{ $opts->{files} }) {
        $self{files}{$file} = $opts->{files}->{$file};
    }

    foreach my $param (qw(rawtime cpuinfo)) {
        if ($opts->{$param}) {
            $self{$param} = $opts->{$param};
        }
    }

    return bless \%self, $class;
}

sub get {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my $stats = { };

    $self->{stats} = $stats;

    $self->_get_beer;
    $self->_get_meminfo;
    $self->_get_uptime;
    $self->_get_interfaces;

    if ($CPUINFO || $self->{cpuinfo}) {
        $self->_get_cpuinfo;
    }

    foreach my $key (keys %$stats) {
        chomp $stats->{$key};
        $stats->{$key} =~ s/\t+/ /g;
        $stats->{$key} =~ s/\s+/ /g;
    }

   return $stats;
}

sub _get_beer {
    my $self  = shift;
    my $class = ref($self);
    my $file  = $self->{files};
    my $stats = $self->{stats};

    #for my $x (qw(hostname domain kernel release version shmmax shmall shmmni)) {
    for my $x (qw(hostname domain kernel release version)) {
        my $filename = $file->{path} ? "$file->{path}/$file->{$x}" : $file->{$x};
        open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";
        $stats->{$x} = <$fh>;
        close($fh);
    }
}

sub _get_meminfo {
    my $self  = shift;
    my $class = ref($self);
    my $file  = $self->{files};
    my $stats = $self->{stats};

    my $filename = $file->{path} ? "$file->{path}/$file->{meminfo}" : $file->{meminfo};
    open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";

    while (my $line = <$fh>) {
        if ($line =~ /^MemTotal:\s+(\d+ \w+)/) {
            $stats->{memtotal} = $1;
        } elsif ($line =~ /^SwapTotal:\s+(\d+ \w+)/) {
            $stats->{swaptotal} = $1;
        }
    }

    close($fh);
}

sub _get_cpuinfo {
    my $self  = shift;
    my $class = ref($self);
    my $file  = $self->{files};
    my $stats = $self->{stats};
    my (%cpu, $phyid);

    $stats->{countcpus} = 0;

    my $filename = $file->{path} ? "$file->{path}/$file->{cpuinfo}" : $file->{cpuinfo};
    open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";

    while (my $line = <$fh>) {
        if ($line =~ /^physical\s+id\s*:\s*(\d+)/) {
            $phyid = $1;
            $cpu{$phyid}{count}++;
        } elsif ($line =~ /^core\s+id\s*:\s*(\d+)/) {
            $cpu{$phyid}{cores}{$1}++;
        } elsif ($line =~ /^processor\s*:\s*\d+/) {       # x86
            $stats->{countcpus}++;
        } elsif ($line =~ /^# processors\s*:\s*(\d+)/) {  # s390
            $stats->{countcpus} = $1;
            last;
        }
    }

    close($fh);

    $stats->{countcpus} ||= 1; # if it was not possible to match
    $stats->{tcpucount} = $stats->{countcpus};
    $stats->{pcpucount} = scalar keys %cpu || $stats->{countcpus};

    if (scalar keys %cpu) {
        my @cpuinfo;

        foreach my $cpu (sort keys %cpu) {
            my $pcpu = $cpu{$cpu};
            my $text = "cpu$cpu";

            if (scalar keys %{$pcpu->{cores}}) {
                my $cores = scalar keys %{$pcpu->{cores}};
                $text .= " has $cores ";
                $text .= $cores > 1 ? "cores" : "core";

                if ($pcpu->{cores}->{0} > 1) {
                    $text .= " with hyper threading";
                }
            } elsif ($pcpu->{count} > 1) {
                $text .= " has hyper threading";
            }

            push @cpuinfo, $text;
        }

        $stats->{cpuinfo} = join(", ", @cpuinfo);
    } elsif ($stats->{countcpus} > 1) {
        $stats->{cpuinfo} = "$stats->{countcpus} CPUs";
    } else {
        $stats->{cpuinfo} = "$stats->{countcpus} CPU";
    }
}

sub _get_interfaces {
    my $self  = shift;
    my $class = ref($self);
    my $file  = $self->{files};
    my $stats = $self->{stats};
    my @iface = ();

    my $filename = $file->{path} ? "$file->{path}/$file->{netdev}" : $file->{netdev};
    open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";
    { my $head = <$fh>; }

    while (my $line = <$fh>) {
        if ($line =~ /^\s*(\w+):/) {
            push @iface, $1;
        }
    }

    close $fh;

    $stats->{interfaces} = join(", ", @iface);
    $stats->{interfaces} ||= "";
}

sub _get_uptime {
    my $self  = shift;
    my $class = ref($self);
    my $file  = $self->{files};
    my $stats = $self->{stats};

    my $filename = $file->{path} ? "$file->{path}/$file->{uptime}" : $file->{uptime};
    open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";
    ($stats->{uptime}, $stats->{idletime}) = split /\s+/, <$fh>;
    close $fh;

    if (!$RAWTIME && !$self->{rawtime}) {
        foreach my $x (qw/uptime idletime/) {
            my ($d, $h, $m, $s) = $self->_calsec(sprintf('%li', $stats->{$x}));
            $stats->{$x} = "${d}d ${h}h ${m}m ${s}s";
        }
    }
}

sub _calsec {
    my $self = shift;
    my ($s, $m, $h, $d) = (shift, 0, 0, 0);
    $s >= 86400 and $d = sprintf('%i',$s / 86400) and $s = $s % 86400;
    $s >= 3600  and $h = sprintf('%i',$s / 3600)  and $s = $s % 3600;
    $s >= 60    and $m = sprintf('%i',$s / 60)    and $s = $s % 60;
    return ($d, $h, $m, $s);
}

1;
