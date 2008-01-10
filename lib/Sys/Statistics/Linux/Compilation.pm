=head1 NAME

Sys::Statistics::Linux::Compilation - Statistics compilation.

=head1 SYNOPSIS

    use Sys::Statistics::Linux;

    my $lxs  = Sys::Statistics::Linux->new( loadavg => 1 );
    my $stat = $lxs->get;

    foreach my $key ($stat->loadavg) {
        print $key, " ", $stat->loadavg($key), "\n";
    }

    # or

    use Sys::Statistics::Linux::LoadAVG;
    use Sys::Statistics::Linux::Compilation;

    my $lxs  = Sys::Statistics::Linux::LoadAVG->new();
    my $load = $lxs->get;
    my $stat = Sys::Statistics::Linux::Compilation->new({ loadavg => $load });

    foreach my $key ($stat->loadavg) {
        print $key, " ", $stat->loadavg($key), "\n";
    }

    # or

    foreach my $key ($stat->loadavg) {
        print $key, " ", $stat->loadavg->{$key}, "\n";
    }

=head1 DESCRIPTION

This module provides different methods to access and filter the statistics compilation.

=head1 METHODS

=head2 new()

Create a new C<Compilation> object. This creator is only useful if you
don't call C<get()> of C<Sys::Statistics::Linux>. You can create a new
object with:

    my $lxs  = Sys::Statistics::Linux::LoadAVG->new();
    my $load = $lxs->get;
    my $stat = Sys::Statistics::Linux::Compilation->new({ loadavg => $load });

=head2 Statistic methods

=over 4

=item sysinfo()

=item cpuinfo()

=item cpustats()

=item procstats()

=item memstats()

=item pgswstats()

=item netstats()

=item sockstats()

=item diskstats()

=item diskusage()

=item loadavg()

=item filestats()

=item processes()

=back

All methods returns the statistics as a hash reference in scalar context. In list all methods
returns the first level keys of the statistics. Example:

    my $net  = $stat->netstats;                 # netstats as a hash reference
    my @dev  = $stat->netstats;                 # the devices eth0, eth1, ...
    my $eth0 = $stat->netstats('eth0');         # eth0 statistics as a hash reference
    my @keys = $stat->netstats('eth0');         # the statistic keys
    my @vals = $stat->netstats('eth0', @keys);  # the values for @keys

I was thinking about to return all keys sorted but if you need that you can call

    my @dev  = sort $stat->netstats;
    my @keys = sort $stat->netstats('eth0');

LoadAVG example:

    my $load = $stat->loadavg;                  # loadavg as a hash reference
    my @keys = $stat->loadavg;                  # the statistic keys
    my @vals = $stat->loadavg(@keys);           # the values for @keys

=head2 pstop()

This method is looking for top processes and returns a sorted list of PIDs as an array or
array reference depending on the context. It expected two values: a key name and the number
of top processes to return.

As example you want to get the top 5 processes with the highest cpu usage:

    my @top5 = $stat->pstop( ttime => 5 );
    # or as a reference
    my $top5 = $stat->pstop( ttime => 5 );

If you want to get all processes:

    my @top_all = $stat->pstop( ttime => $FALSE );
    # or just
    my @top_all = $stat->pstop( 'ttime' );

=head2 search(), psfind()

Both methods provides a simple scan engine to find special statistics. Both methods except a filter
as a hash reference as the first argument. If your data comes from extern - maybe from a client that
send his statistics to the server - you can set the statistics as the second argument. The second
argument have to be a hash reference as well.

The method C<search()> scans for statistics and rebuilds the hash tree until that keys that matched
your filter and returns the hits as a hash reference.

    my $hits = $stat->search({
        processes => {
            cmd   => qr/\[su\]/,
            owner => qr/root/
        },
        cpustats => {
            idle   => 'lt:10',
            iowait => 'gt:10'
        },
        diskusage => {
            '/dev/sda1' => {
                usageper => 'gt:80'
            }
        }
    });

This would return the following matches:

    * processes with the command "[su]"
    * processes with the owner "root"
    * all cpu where "idle" is less than 50
    * all cpu where "iowait" is grather than 10
    * only disk '/dev/sda1' if "usageper" is grather than 80

If the statistics are not gathered by the current process then you can handoff statistics as an
argument.

    my %stats = (
        cpustats => {
            cpu => {
                system => '51.00',
                total  => '51.00',
                idle   => '49.00',
                nice   => '0.00',
                user   => '0.00',
                iowait => '0.00'
            }
        }
    );

    my $stat = Sys::Statistics::Linux::Compilation(\%stats);

    my %filter = (
        cpustats => {
            total => 'gt:50'
        }
    );

    my $hits = $stat->search(\%filter);

The method C<psfind()> scans for processes only and returns a array reference with all process
IDs that matched the filter. Example:

    my $pids = $stat->psfind({ cmd => qr/init/, owner => 'eq:apache' });

You can handoff the statistics as second argument as well.

    my $pids = $stat->psfind(\%filter, \%stats);

This would return the following process ids:

    * processes that matched the command "init"
    * processes with the owner "apache"

There are different match operators available:

    gt  -  grather than
    lt  -  less than
    eq  -  is equal
    ne  -  is not equal

Notation examples:

    gt:50
    lt:50
    eq:50
    ne:50

Both argumnents have to be set as a hash reference.

Note: the operators < > = ! are not available any more. It's possible that in further releases
could be different changes for C<search()> and C<psfind()>. So please take a look to the 
documentation if you use it.

=head1 EXPORTS

No exports.

=head1 TODOS

   * Are there any wishs from your side? Send me a mail!

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

Thanks to Moritz Lenz for his suggestion for the name for this module.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::Compilation;
our $VERSION = '0.01';

use strict;
use warnings;
use Carp qw(croak);

# Creating the statistics accessors
BEGIN {
    foreach my $stat (qw/sysinfo cpuinfo procstats memstats sockstats loadavg filestats/) {
        no strict 'refs';
        *{$stat} = sub {
            use strict 'refs';
            my ($self, @keys) = @_;
            return () unless $self->{$stat};
            if (@keys) {
                return @{$self->{$stat}}{@keys};
            }
            return wantarray ? keys %{$self->{$stat}} : $self->{$stat};
        };
    }
    foreach my $stat (qw/cpustats pgswstats netstats diskstats diskusage processes/) {
        no strict 'refs';
        *{$stat} = sub {
            use strict 'refs';
            my ($self, $sub, @keys) = @_;
            return () unless $self->{$stat};
            if ($sub) {
                my $ref = $self->{$stat};
                return () unless exists $ref->{$sub};
                if (@keys) {
                    return @{$ref->{$sub}}{@keys};
                } else {
                    return wantarray ? keys %{$ref->{$sub}} : $ref->{$sub};
                }
            }
            return wantarray ? keys %{$self->{$stat}} : $self->{$stat};
        };
    }
}

sub new {
    my ($class, $stats) = @_;
    unless (ref($stats) eq 'HASH') {
        croak 'Usage: class->new( \%statistics )';
    }
    return bless $stats, $class;
}

sub search {
    my $self   = shift;
    my $filter = ref($_[0]) eq 'HASH' ? shift : {@_};
    my $class  = ref($self);
    my %hits   = ();

    foreach my $opt (keys %{$filter}) {

        unless (ref($filter->{$opt}) eq 'HASH') {
            croak "$class: not a hash ref opt '$opt'";
        }

        # next if the object isn't loaded
        next unless exists $self->{$opt};
        my $fref = $filter->{$opt};
        my $proc = $self->{$opt};
        my $subref;

        # we search for matches for each key that is defined
        # in %filter and rebuild the tree until that key that
        # matched the searched string

        foreach my $x (keys %{$fref}) {

            # if $fref->{$x} is a hash ref then the next key have to
            # match the statistic key. this is used for statistics
            # like NetStats or Processes that uses a hash key for the
            # device name or process id. NetStats example... if
            #
            #    $fref->{eth0}->{ttbyt}
            #
            # is defined as a filter then the key "eth0" have to match
            #
            #    $proc->{eth0}
            #
            # then we look if "ttbyt" matched the searched statistic name
            # and compare the values. if the comparing returns TRUE we the
            # hash is copied until the matched key-value pair.

            if (ref($fref->{$x}) eq 'HASH') {

                # if the key $proc->{eth0} doesn't exists
                # then we continue with the next defined filter
                next unless exists $proc->{$x};
                $subref = $proc->{$x};

                while ( my ($name, $value) = each %{$fref->{$x}} ) {
                    if (exists $subref->{$name} && $self->_compare($subref->{$name}, $value)) {
                        $hits{$opt}{$x}{$name} = $subref->{$name};
                    }
                }
            } else {
                foreach my $key (keys %{$proc}) {
                    if (ref($proc->{$key}) eq 'HASH') {
                        $subref = $proc->{$key};
                        if (defined $subref->{$x} && $self->_compare($subref->{$x}, $fref->{$x})) {
                            $hits{$opt}{$key}{$x} = $subref->{$x};
                        }
                    } else { # must be a scalar now
                        if (defined $proc->{$x} && $self->_compare($proc->{$x}, $fref->{$x})) {
                            $hits{$opt}{$x} = $proc->{$x}
                        }
                        last;
                    }
                }
            }
        }
    }
    return wantarray ? %hits : \%hits;
}

sub psfind {
    my $self   = shift;
    my $filter = ref($_[0]) eq 'HASH' ? shift : {@_};
    my $proc   = $self->{processes} or return undef;
    my @hits   = ();

    foreach my $pid (keys %{$proc}) {
        my $proc = $proc->{$pid};
        while ( my ($key, $value) = each %{$filter} ) {
            if (exists $proc->{$key} && $self->_compare($proc->{$key}, $value)) {
                push @hits, $pid;
            }
        }
    }

    return wantarray ? @hits : \@hits;
}

sub pstop {
    my ($self, $key, $count) = @_;
    unless ($key) {
        croak 'Usage: pstop( $key => $count )';
    }
    my $proc = $self->{processes};
    my @top = (
        map { $_->[0] }
        reverse sort { $a->[1] <=> $b->[1] }
        map { [ $_, $proc->{$_}->{$key} ] } keys %{$proc}
    );
    if ($count) {
        @top = @top[0..--$count];
    }
    return wantarray ? @top : \@top;
}

#
# private stuff
#

sub _compare {
    my ($class, $x, $y) = @_;
    if (ref($y) eq 'Regexp') {
        return $x =~ $y;
    } elsif ($y =~ s/^eq://) {
        return $x eq $y;
    } elsif ($y =~ s/^ne://) {
        return $x ne $y;
    } elsif ($y =~ s/^gt://) {
        return $x > $y;
    } elsif ($y =~ s/^lt://) {
        return $x < $y;
    } else {
        croak "$class: bad search() / psfind() operator '$y'";
    }
    return undef;
}

1;