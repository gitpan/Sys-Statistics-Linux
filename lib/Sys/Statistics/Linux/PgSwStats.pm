=head1 NAME

Sys::Statistics::Linux::PgSwStats - Collect linux paging and swapping statistics.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::PgSwStats;

    my $lxs = Sys::Statistics::Linux::PgSwStats->new;
    $lxs->init;
    sleep 1;
    my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::PgSwStats gathers paging and swapping statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 PAGING AND SWAPPING STATISTICS

Generated by F</proc/stat> or F</proc/vmstat>.

    pgpgin      -  Number of kilobytes the system has paged in from disk per second.
    pgpgout     -  Number of kilobytes the system has paged out to disk per second.
    pswpin      -  Number of kilobytes the system has swapped in from disk per second.
    pswpout     -  Number of kilobytes the system has swapped out to disk per second.

    The following statistics are only available by kernels from 2.6.

    pgfault     -  Number of page faults the system has made per second (minor + major).
    pgmajfault  -  Number of major faults per second the system required loading a memory page from disk.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::PgSwStats->new;

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

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::PgSwStats;
our $VERSION = '0.12';

use strict;
use warnings;
use Carp qw(croak);
use Time::HiRes;

sub new {
    my $class = shift;
    my %self = (
        files => {
            stat   => '/proc/stat',
            vmstat => '/proc/vmstat',
        }
    );
    return bless \%self, $class;
}

sub init {
    my $self = shift;
    $self->{time} = Time::HiRes::gettimeofday();
    $self->{init} = $self->_load;
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

sub _load {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my %stats = ();

    open my $fh, '<', $file->{stat} or croak "$class: unable to open $file->{stat} ($!)";

    while (my $line = <$fh>) {
        if ($line =~ /^page\s+(\d+)\s+(\d+)$/) {
            @stats{qw(pgpgin pgpgout)} = ($1, $2);
        } elsif ($line =~ /^swap\s+(\d+)\s+(\d+)$/) {
            @stats{qw(pswpin pswpout)} = ($1, $2);
        }
    }

    close($fh);

    # if paging and swapping are not found in /proc/stat
    # then let's try a look into /proc/vmstat (since 2.6)

    unless (defined $stats{pswpout}) {
        open my $fh, '<', $file->{vmstat} or croak "$class: unable to open $file->{vmstat} ($!)";
        while (my $line = <$fh>) {
            next unless $line =~ /^(pgpgin|pgpgout|pswpin|pswpout|pgfault|pgmajfault)\s+(\d+)/;
            $stats{$1} = $2;
        }
        close($fh);
    }

    return \%stats;
}

sub _deltas {
    my $self  = shift;
    my $class = ref $self;
    my $istat = $self->{init};
    my $lstat = $self->{stats};
    my $time  = Time::HiRes::gettimeofday();
    my $delta = sprintf('%.2f', $time - $self->{time});
    $self->{time} = $time;

    while (my ($k, $v) = each %{$lstat}) {
        croak "$class: different keys in statistics"
            unless defined $istat->{$k} && defined $lstat->{$k};
        croak "$class: value of '$k' is not a number"
            unless $v =~ /^\d+$/ && $istat->{$k} =~ /^\d+$/;

        $lstat->{$k} =
            $lstat->{$k} == $istat->{$k}
                ? sprintf('%.2f', 0)
                : $delta > 0
                    ? sprintf('%.2f', ($lstat->{$k} - $istat->{$k}) / $delta)
                    : sprintf('%.2f', $lstat->{$k} - $istat->{$k});

        $istat->{$k}  = $v;
    }
}

1;
