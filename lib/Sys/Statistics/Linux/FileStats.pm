=head1 NAME

Sys::Statistics::Linux::FileStats - Collect linux file statistics.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::FileStats;

    my $lxs  = Sys::Statistics::Linux::FileStats->new;
    my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::FileStats gathers file statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 FILE STATISTICS

Generated by F</proc/sys/fs/file-nr>, F</proc/sys/fs/inode-nr> and F</proc/sys/fs/dentry-state>.

    fhalloc    -  Number of allocated file handles.
    fhfree     -  Number of free file handles.
    fhmax      -  Number of maximum file handles.
    inalloc    -  Number of allocated inodes.
    infree     -  Number of free inodes.
    inmax      -  Number of maximum inodes.
    dentries   -  Dirty directory cache entries.
    unused     -  Free diretory cache size.
    agelimit   -  Time in seconds the dirty cache entries can be reclaimed.
    wantpages  -  Pages that are requested by the system when memory is short.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::FileStats->new;

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

package Sys::Statistics::Linux::FileStats;

use strict;
use warnings;
use Carp qw(croak);

our $VERSION = '0.07';

sub new {
    my $class = shift;
    my %self = (
        files => {
            file_nr  => '/proc/sys/fs/file-nr',
            inode_nr => '/proc/sys/fs/inode-nr',
            dentries => '/proc/sys/fs/dentry-state',
        }
    );
    return bless \%self, $class;
}

sub get {
    my $self  = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my %stats = ();

    {
        open my $fh, '<', $file->{file_nr} or croak "$class: unable to open $file->{file_nr} ($!)";
        @stats{qw(fhalloc fhfree fhmax)} = (split /\s+/, <$fh>)[0..2];
        close($fh);
    }

    {
        open my $fh, '<', $file->{inode_nr} or croak "$class: unable to open $file->{inode_nr} ($!)";
        @stats{qw(inalloc infree)} = (split /\s+/, <$fh>)[0..1];
        $stats{inmax} = $stats{inalloc} + $stats{infree};
        close($fh);
    }

    {
        open my $fh, '<', $file->{dentries} or croak "$class: unable to open $file->{dentries} ($!)";
        @stats{qw(dentries unused agelimit wantpages)} = (split /\s+/, <$fh>)[0..3];
        close($fh);
    }

    return \%stats;
}

1;
