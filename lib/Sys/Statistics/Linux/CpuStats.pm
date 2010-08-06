=head1 NAME

Sys::Statistics::Linux::CpuStats - Collect linux cpu statistics.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::CpuStats;

    my $lxs = Sys::Statistics::Linux::CpuStats->new;
    $lxs->init;
    sleep 1;
    my $stats = $lxs->get;

Or

    my $lxs = Sys::Statistics::Linux::CpuStats->new(initfile => $file);
    $lxs->init;
    my $stats = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::CpuStats gathers cpu statistics from the virtual
F</proc> filesystem (procfs).

For more information read the documentation of the front-end module
L<Sys::Statistics::Linux>.

=head1 CPU STATISTICS

Generated by F</proc/stat> for each cpu (cpu0, cpu1 ...). F<cpu> without
a number is the summary.

    user    -  Percentage of CPU utilization at the user level.
    nice    -  Percentage of CPU utilization at the user level with nice priority.
    system  -  Percentage of CPU utilization at the system level.
    idle    -  Percentage of time the CPU is in idle state.
    total   -  Total percentage of CPU utilization.

Statistics with kernels >= 2.6.

    iowait  -  Percentage of time the CPU is in idle state because an I/O operation
               is waiting to complete.
    irq     -  Percentage of time the CPU is servicing interrupts.
    softirq -  Percentage of time the CPU is servicing softirqs.
    steal   -  Percentage of stolen CPU time, which is the time spent in other
               operating systems when running in a virtualized environment (>=2.6.11).

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::CpuStats->new;

Maybe you want to store/load the initial statistics to/from a file:

    my $lxs = Sys::Statistics::Linux::CpuStats->new(initfile => '/tmp/cpustats.yml');

If you set C<initfile> it's not necessary to call sleep before C<get()>.

It's also possible to set the path to the proc filesystem.

     Sys::Statistics::Linux::CpuStats->new(
        files => {
            # This is the default
            path => '/proc'
            stat => 'stat',
        }
    );

=head2 init()

Call C<init()> to initialize the statistics.

    $lxs->init;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

    my $stats = $lxs->get;

=head2 raw()

Get raw values.

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

package Sys::Statistics::Linux::CpuStats;

use strict;
use warnings;
use Carp qw(croak);

our $VERSION = '0.19';

sub new {
    my ($class, %opts) = @_;

    my %self = (
        files => {
            path => '/proc',
            stat => 'stat',
        }
    );

    if (defined $opts{initfile}) {
        require YAML::Syck;
        $self{initfile} = $opts{initfile};
    }

    foreach my $file (keys %{ $opts{files} }) {
        $self{files}{$file} = $opts{files}{$file};
    }

    return bless \%self, $class;
}

sub raw {
    my $self = shift;
    my $stat = $self->_load;
    return $stat;
}

sub init {
    my $self = shift;

    if ($self->{initfile} && -r $self->{initfile}) {
        $self->{init} = YAML::Syck::LoadFile($self->{initfile});
    } else {
        $self->{init} = $self->_load;
    }
}

sub get {
    my $self  = shift;
    my $class = ref $self;

    if (!exists $self->{init}) {
        croak "$class: there are no initial statistics defined";
    }

    $self->{stats} = $self->_load;
    $self->_deltas;

    if ($self->{initfile}) {
        YAML::Syck::DumpFile($self->{initfile}, $self->{init});
    }

    return $self->{stats};
}

#
# private stuff
#

sub _load {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my (%stats, $iowait, $irq, $softirq, $steal);

    my $filename = $file->{path} ? "$file->{path}/$file->{stat}" : $file->{stat};
    open my $fh, '<', $filename or croak "$class: unable to open $filename ($!)";

    while (my $line = <$fh>) {
        if ($line =~ /^(cpu.*?)\s+(.*)$/) {
            my $cpu = \%{$stats{$1}};
            (@{$cpu}{qw(user nice system idle)},
                $iowait, $irq, $softirq, $steal) = split /\s+/, $2;
            # iowait, irq and softirq are only set 
            # by kernel versions higher than 2.4.
            # steal is available since 2.6.11.
            $cpu->{iowait}  = $iowait  if defined $iowait;
            $cpu->{irq}     = $irq     if defined $irq;
            $cpu->{softirq} = $softirq if defined $softirq;
            $cpu->{steal}   = $steal   if defined $steal;
        }
    }

    close($fh);
    return \%stats;
}

sub _deltas {
    my $self  = shift;
    my $class = ref $self;
    my $istat = $self->{init};
    my $lstat = $self->{stats};

    foreach my $cpu (keys %{$lstat}) {
        my $icpu = $istat->{$cpu};
        my $dcpu = $lstat->{$cpu};
        my $uptime;

        while (my ($k, $v) = each %{$dcpu}) {
            if (!defined $icpu->{$k}) {
                croak "$class: not defined key found '$k'";
            }

            if ($v !~ /^\d+\z/ || $dcpu->{$k} !~ /^\d+\z/) {
                croak "$class: invalid value for key '$k'";
            }

            $dcpu->{$k} -= $icpu->{$k};
            $icpu->{$k}  = $v;
            $uptime += $dcpu->{$k};
        }

        foreach my $k (keys %{$dcpu}) {
            if ($dcpu->{$k} > 0) {
                $dcpu->{$k} = sprintf('%.2f', 100 * $dcpu->{$k} / $uptime);
            } elsif ($dcpu->{$k} < 0) {
                $dcpu->{$k} = sprintf('%.2f', 0);
            } else {
                $dcpu->{$k} = sprintf('%.2f', $dcpu->{$k});
            }
        }

        $dcpu->{total} = sprintf('%.2f', 100 - $dcpu->{idle});
    }
}

1;
