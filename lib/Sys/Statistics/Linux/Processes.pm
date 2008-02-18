=head1 NAME

Sys::Statistics::Linux::Processes - Collect linux process statistics.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::Processes;

    my $lxs = Sys::Statistics::Linux::Processes->new;
    $lxs->init;
    sleep 1;
    my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::Processes gathers process informations from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 PROCESS STATISTICS

Generated by F</proc/E<lt>numberE<gt>/statm>, F</proc/E<lt>numberE<gt>/stat>,
F</proc/E<lt>numberE<gt>/status>, F</proc/E<lt>numberE<gt>/cmdline> and F<getpwuid()>.

Note that if F</etc/passwd> isn't readable, the key owner is set to F<N/a>.

    ppid      -  The parent process ID of the process.
    nlwp      -  The number of light weight processes that runs by this process.
    owner     -  The owner name of the process.
    pgrp      -  The group ID of the process.
    state     -  The status of the process.
    session   -  The session ID of the process.
    ttynr     -  The tty the process use.
    minflt    -  The number of minor faults the process made.
    cminflt   -  The number of minor faults the child process made.
    mayflt    -  The number of mayor faults the process made.
    cmayflt   -  The number of mayor faults the child process made.
    stime     -  The number of jiffies the process have beed scheduled in kernel mode.
    utime     -  The number of jiffies the process have beed scheduled in user mode.
    ttime     -  The number of jiffies the process have beed scheduled (user + kernel).
    cstime    -  The number of jiffies the process waited for childrens have been scheduled in kernel mode.
    cutime    -  The number of jiffies the process waited for childrens have been scheduled in user mode.
    prior     -  The priority of the process (+15).
    nice      -  The nice level of the process.
    sttime    -  The time in jiffies the process started after system boot.
    actime    -  The time in D:H:M:S (days, hours, minutes, seconds) the process is active.
    vsize     -  The size of virtual memory of the process.
    nswap     -  The size of swap space of the process.
    cnswap    -  The size of swap space of the childrens of the process.
    cpu       -  The CPU number the process was last executed on.
    size      -  The total program size of the process.
    resident  -  Number of resident set size, this includes the text, data and stack space.
    share     -  Total size of shared pages of the process.
    trs       -  Total text size of the process.
    drs       -  Total data/stack size of the process.
    lrs       -  Total library size of the process.
    dtp       -  Total size of dirty pages of the process (unused since kernel 2.6).
    cmd       -  Command of the process.
    cmdline   -  Command line of the process.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::Processes->new;

It's possible to handoff an array reference with a PID list.

    my $lxs = Sys::Statistics::Linux::Processes->new([ 1, 2, 3 ]);

=head2 init()

Call C<init()> to initialize the statistics.

    $lxs->init;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

    my $stat = $lxs->get;

=head1 EXPORTS

No exports.

=head1 SEE ALSO

B<proc(5)>

B<perldoc -f getpwuid>

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::Processes;
our $VERSION = '0.14';

use strict;
use warnings;
use Carp qw(croak);

sub new {
    my ($class, $pids) = @_;

    croak "$class: not a array reference"
        if $pids && ref($pids) ne 'ARRAY';

   foreach my $pid (@$pids) {
        croak "$class: pid '$_' is not a number"
            unless $pid =~ /^\d+$/;
   }

   my %self = (
        files => {
            basedir   => '/proc',
            uptime    => '/proc/uptime',
            p_stat    => 'stat',
            p_statm   => 'statm',
            p_status  => 'status',
            p_cmdline => 'cmdline',
        },
        pids => $pids,
    );

    return bless \%self, $class;
}

sub init {
    my $self = shift;
    $self->{init} = $self->_init;
}

sub get {
    my $self  = shift;
    my $class = ref $self;

    croak "$class: there are no initial statistics defined"
        unless exists $self->{init};

    $self->{stats} = $self->_load;
    $self->_deltas;
    return $self->{stats};
}

#
# private stuff
#

sub _init {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my $pids  = $self->{pids};
    my %stats;

    $stats{uptime} = $self->_uptime;

    unless (@$pids) {
        opendir my $pdir, $file->{basedir} or croak "$class: unable to open directory $file->{basedir} ($!)";
        @$pids = (grep /^\d+$/, readdir $pdir);
        closedir $pdir;
    }

    foreach my $pid (@$pids) {
        if (open my $fh, '<', "$file->{basedir}/$pid/$file->{p_stat}") {
            @{$stats{$pid}}{qw(
                minflt cminflt mayflt cmayflt utime
                stime cutime cstime sttime
            )} = (split /\s+/, <$fh>)[9..16,21];
            close($fh);
        } else {
            delete $stats{$pid};
            next;
        }
    }

    return \%stats;
}

sub _load {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my $pids  = $self->{pids};
    my (%stats, %userids);

    $stats{uptime} = $self->_uptime;

    # we get all the PIDs from the /proc filesystem. if we are unable to open a file
    # of a process, then it can be that the process doesn't exist any more and
    # we will delete the hash key.

    unless (@$pids) {
        opendir my $pdir, $file->{basedir} or croak "$class: unable to open directory $file->{basedir} ($!)";
        @$pids = (grep /^\d+$/, readdir $pdir);
        closedir $pdir;
    }

    foreach my $pid (@$pids) {

        # memory usage for each process
        if (open my $fh, '<', "$file->{basedir}/$pid/$file->{p_statm}") {
            @{$stats{$pid}}{qw(size resident share trs drs lrs dtp)} = split /\s+/, <$fh>;
            close($fh);
        } else {
            delete $stats{$pid};
            next;
        }

        # different other informations for each process
        if (open my $fh, '<', "$file->{basedir}/$pid/$file->{p_stat}") {
            @{$stats{$pid}}{qw(
                cmd     state   ppid    pgrp    session ttynr   minflt
                cminflt mayflt  cmayflt utime   stime   cutime  cstime
                prior   nice    nlwp    sttime  vsize   nswap   cnswap
                cpu
            )} = (split /\s+/, <$fh>)[1..6,9..19,21..22,35..36,38];
            close($fh);
        } else {
            delete $stats{$pid};
            next;
        }

        # calculate the active time of each process
        my ($d, $h, $m, $s) = $self->_calsec(sprintf('%li', $stats{uptime} - $stats{$pid}{sttime} / 100));
        $stats{$pid}{actime} = "$d:".sprintf('%02d:%02d:%02d', $h, $m, $s);

        # determine the owner of the process
        if (open my $fh, '<', "$file->{basedir}/$pid/$file->{p_status}") {
            while (my $line = <$fh>) {
                next unless $line =~ /^Uid:(\s+|\t+)(\d+)/;
                $stats{$pid}{owner} = getpwuid($2) || 'N/a';
                last;
            }
            close($fh);
        } else {
            delete $stats{$pid};
            next;
        }

        #  command line for each process
        if (open my $fh, '<', "$file->{basedir}/$pid/$file->{p_cmdline}") {
            $stats{$pid}{cmdline} = <$fh>;
            if ($stats{$pid}{cmdline}) {
                $stats{$pid}{cmdline} =~ s/\0/ /g;
                $stats{$pid}{cmdline} =~ s/^\s+//;
                $stats{$pid}{cmdline} =~ s/\s+$//;
                chomp $stats{$pid}{cmdline};
            }
            $stats{$pid}{cmdline} = 'N/a' unless $stats{$pid}{cmdline};
            close($fh);
        }
    }

    return \%stats;
}

sub _deltas {
    my $self  = shift;
    my $class = ref $self;
    my $istat = $self->{init};
    my $lstat = $self->{stats};

    croak "$class: missing key 'uptime'"
        unless $istat->{uptime} && $lstat->{uptime};
    croak "$class: value of 'uptime' is not a number"
        unless $istat->{uptime} =~ /^\d+(\.\d+|)$/ && $lstat->{uptime} =~ /^\d+(\.\d+|)$/;

    my $uptime = $lstat->{uptime} - $istat->{uptime};
    $istat->{uptime} = $lstat->{uptime};
    delete $lstat->{uptime};

    for my $pid (keys %{$lstat}) {
        my $ipid = $istat->{$pid};
        my $lpid = $lstat->{$pid};

        # yeah, what happends if the start time is different... it seems that a new
        # process with the same process-id were created... for this reason I have to
        # check if the start time is equal!
        if ($ipid->{sttime} && $ipid->{sttime} == $lpid->{sttime}) {
            for my $k (qw(minflt cminflt mayflt cmayflt utime stime cutime cstime)) {
                croak "$class: different keys in statistics"
                    unless defined $ipid->{$k};
                croak "$class: value of '$k' is not a number"
                    unless $ipid->{$k} =~ /^\d+(\.\d+|)$/ && $lpid->{$k} =~ /^\d+(\.\d+|)$/;

                # we held this value for the next init stat
                my $tmp      = $lpid->{$k};
                $lpid->{$k} -= $ipid->{$k};
                if ($lpid->{$k} > 0 && $uptime > 0) {
                    $lpid->{$k} = sprintf('%.2f', $lpid->{$k} / $uptime);
                } else {
                    $lpid->{$k} = sprintf('%.2f', $lpid->{$k});
                }
                $ipid->{$k} = $tmp;
            }
            # total workload
            $lpid->{ttime} = sprintf('%.2f', $lpid->{stime} + $lpid->{utime});
        } else {
            # if the start time wasn't equal than we store the process to init
            for my $k (qw(minflt cminflt mayflt cmayflt utime stime cutime cstime sttime)) {
                $ipid->{$k} = $lpid->{$k};
                delete $lstat->{$pid};
            }
        }
    }
}

sub _uptime {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    open my $fh, '<', $file->{uptime} or croak "$class: unable to open $file->{uptime} ($!)";
    my ($up, $idle) = split /\s+/, <$fh>;
    close($fh);
    return $up;
}

sub _calsec {
    my $self = shift;
    my ($s, $m, $h, $d) = (shift, 0, 0, 0);
    $s >= 86400 and $d = sprintf('%i', $s / 86400) and $s = $s % 86400;
    $s >= 3600  and $h = sprintf('%i', $s / 3600)  and $s = $s % 3600;
    $s >= 60    and $m = sprintf('%i', $s / 60)    and $s = $s % 60;
    return ($d, $h, $m, $s);
}

1;
