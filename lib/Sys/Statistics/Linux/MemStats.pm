=head1 NAME

Sys::Statistics::Linux::MemStats - Collect linux memory informations.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::MemStats;

    my $lxs  = Sys::Statistics::Linux::MemStats->new;
    my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::MemStats gathers memory statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 MEMORY INFORMATIONS

Generated by F</proc/meminfo>.

    memused         -  Total size of used memory in kilobytes.
    memfree         -  Total size of free memory in kilobytes.
    memusedper      -  Total size of used memory in percent.
    memtotal        -  Total size of memory in kilobytes.
    buffers         -  Total size of buffers used from memory in kilobytes.
    cached          -  Total size of cached memory in kilobytes.
    realfree        -  Total size of memory is real free (memfree + buffers + cached).
    realfreeper     -  Total size of memory is real free in percent of total memory.
    swapused        -  Total size of swap space is used is kilobytes.
    swapfree        -  Total size of swap space is free in kilobytes.
    swapusedper     -  Total size of swap space is used in percent.
    swaptotal       -  Total size of swap space in kilobytes.
    swapcached      -  Memory that once was swapped out, is swapped back in but still also is in the swapfile.
    active          -  Memory that has been used more recently and usually not reclaimed unless absolutely necessary.
    inactive        -  Memory which has been less recently used and is more eligible to be reclaimed for other purposes.

    The following statistics are only available by kernels from 2.6.

    slab            -  Total size of memory in kilobytes that used by kernel for data structure allocations.
    dirty           -  Total size of memory pages in kilobytes that waits to be written back to disk.
    mapped          -  Total size of memory in kilbytes that is mapped by devices or libraries with mmap.
    writeback       -  Total size of memory that was written back to disk.
    committed_as    -  The amount of memory presently allocated on the system.

    The following statistic is only available by kernels from 2.6.9.

    commitlimit     -  Total amount of memory currently available to be allocated on the system.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::MemStats->new;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

    my $stat = $lxs->get;

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

package Sys::Statistics::Linux::MemStats;
our $VERSION = '0.11';

use strict;
use warnings;
use Carp qw(croak);

sub new {
    my $class = shift;
    my %self = (
        files => {
            meminfo => '/proc/meminfo',
        }
    );
    return bless \%self, $class;
}

sub get {
    my $self    = shift;
    my $class   = ref($self);
    my $file    = $self->{files};
    my %meminfo = ();

    open my $fh, '<', $file->{meminfo} or croak "$class: unable to open $file->{meminfo} ($!)";

    # MemTotal:      1035648 kB
    # MemFree:         15220 kB
    # Buffers:          4280 kB
    # Cached:          47664 kB
    # SwapCached:     473988 kB
    # Active:         661992 kB
    # Inactive:       314312 kB
    # HighTotal:      130884 kB
    # HighFree:          264 kB
    # LowTotal:       904764 kB
    # LowFree:         14956 kB
    # SwapTotal:     1951856 kB
    # SwapFree:      1164864 kB
    # Dirty:             520 kB
    # Writeback:           0 kB
    # AnonPages:      908892 kB
    # Mapped:          34308 kB
    # Slab:            19284 kB
    # SReclaimable:     7532 kB
    # SUnreclaim:      11752 kB
    # PageTables:       3056 kB
    # NFS_Unstable:        0 kB
    # Bounce:              0 kB
    # CommitLimit:   2469680 kB
    # Committed_AS:  1699568 kB
    # VmallocTotal:   114680 kB
    # VmallocUsed:     12284 kB
    # VmallocChunk:   100992 kB

    while (my $line = <$fh>) {
        next unless $line =~ /^
            (
                (?:Mem|Swap)(?:Total|Free)|
                Buffers|Cached|SwapCached|
                Active|Inactive|Dirty|Writeback|
                Mapped|Slab|Commit(?:Limit|ted_AS)
            ):\s*(\d+)
        /x;
        my ($n, $v) = ($1, $2);
        $n =~ tr/A-Z/a-z/;
        $meminfo{$n} = $v;
    }

    close($fh);

    $meminfo{memused}     = sprintf('%u', $meminfo{memtotal} - $meminfo{memfree});
    $meminfo{memusedper}  = sprintf('%.2f', 100 * $meminfo{memused} / $meminfo{memtotal});
    $meminfo{swapused}    = sprintf('%u', $meminfo{swaptotal} - $meminfo{swapfree});
    $meminfo{realfree}    = sprintf('%u', $meminfo{memfree} + $meminfo{buffers} + $meminfo{cached});
    $meminfo{realfreeper} = sprintf('%.2f', 100 * $meminfo{realfree} / $meminfo{memtotal});

    # maybe there is no swap space on the machine
    if (!$meminfo{swaptotal}) {
        $meminfo{swapusedper} = '0.00';
    } else {
        $meminfo{swapusedper} = sprintf('%.2f', 100 * $meminfo{swapused} / $meminfo{swaptotal});
    }

    return \%meminfo;
}

1;
