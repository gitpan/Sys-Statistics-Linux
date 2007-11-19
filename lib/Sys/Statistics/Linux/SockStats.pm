=head1 NAME

Sys::Statistics::Linux::SockStats - Collect linux socket statistics.

=head1 SYNOPSIS

    use Sys::Statistics::Linux::SockStats;

    my $lxs  = Sys::Statistics::Linux::SockStats->new;
    my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::SockStats gathers socket statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 SOCKET STATISTICS

Generated by F</proc/net/sockstat>.

    used    -  Total number of used sockets.
    tcp     -  Number of tcp sockets in use.
    udp     -  Number of udp sockets in use.
    raw     -  Number of raw sockets in use.
    ipfrag  -  Number of ip fragments in use (only available by kernels > 2.2).

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

    my $lxs = Sys::Statistics::Linux::SockStats->new;

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

package Sys::Statistics::Linux::SockStats;
our $VERSION = '0.06';

use strict;
use warnings;
use Carp qw(croak);

sub new {
    my $class = shift;
    my %self = (
        files => {
            sockstats  => '/proc/net/sockstat',
        }
    );
    return bless \%self, $class;
}

sub get {
    my $self = shift;
    my $class = ref $self;
    my $file  = $self->{files};
    my %socks = ();

    open my $fh, '<', $file->{sockstats} or croak "$class: unable to open $file->{sockstats} ($!)";

    while (my $line = <$fh>) {
        if ($line =~ /sockets: used (\d+)/) {
            $socks{used} = $1;
        } elsif ($line =~ /TCP: inuse (\d+)/) {
            $socks{tcp} = $1;
        } elsif ($line =~ /UDP: inuse (\d+)/) {
            $socks{udp} = $1;
        } elsif ($line =~ /RAW: inuse (\d+)/) {
            $socks{raw} = $1;
        } elsif ($line =~ /FRAG: inuse (\d+)/) {
            $socks{ipfrag} = $1;
        }
    }

    close($fh);
    return \%socks;
}

1;
