=head1 NAME

Sys::Statistics::Linux::DiskStats - Collect linux disk statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::DiskStats;

   my $lxs = new Sys::Statistics::Linux::DiskStats;
   $lxs->init;
   sleep 1;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects disk statistics from the F</proc> filesystem. It is tested on x86 hardware
with the distributions SuSE (SuSE on s390 and s390x architecture as well), Red Hat, Debian
and Mandrake on kernel versions 2.4 and 2.6 but should also running on other linux distributions
with the same kernel release number. To run this module it is necessary to start it as root or
another user with the authorization to read the F</proc> filesystem.

=head1 DELTAS

It's necessary to initialize the statistics by calling C<init()>, because the statistics are deltas between
the call of C<init()> and C<get()>. By calling C<get()> the deltas be generated and the initial values
be updated automatically. This way making it possible that the call of C<init()> is only necessary
after the call of C<new()>. Further it's recommended to sleep for a while - at least one second - between
the call of C<init()> and/or C<get()> if you want to get useful statistics.

=head1 DISK STATISTICS

Generated by F</proc/diskstats> or F</proc/partitions>.

   major   -  The mayor number of the disk
   minor   -  The minor number of the disk
   rdreq   -  Number of read requests that were made to physical disk.
   rdbyt   -  Number of bytes that were read from physical disk.
   wrtreq  -  Number of write requests that were made to physical disk.
   wrtbyt  -  Number of bytes that were written to physical disk.
   ttreq   -  Total number of requests were made from/to physical disk.
   ttbyt   -  Total number of bytes transmitted from/to physical disk.

=head1 METHODS

=head2 All methods

   C<new()>
   C<init()>
   C<get()>

=head2 new()

Call C<new()> to create a new object.

   my $lxs = new Sys::Statistics::Linux::CpuStats;

=head2 init()

Call C<init()> to initialize the statistics.

   $lxs->init;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

   my $stats = $lxs->get;

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

package Sys::Statistics::Linux::DiskStats;
our $VERSION = '0.01';

use strict;
use warnings;
use IO::File;
use Carp qw(croak);

sub new {
   return bless {
      files => {
         diskstats => '/proc/diskstats',
         partitions => '/proc/partitions',
      },
      init  => {},
      stats => {},
      blocksize => 512
   }, shift;
}

sub init {
   my $self = shift;
   $self->{init} = $self->_load;
}

sub get {
   my $self  = shift;
   my $class = ref $self;

   croak "$class: there are no initial statistics defined"
      unless %{$self->{init}};

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
   my $bksz  = $self->{blocksize};
   my $fh    = new IO::File;
   my %stats;

   # one of the both must be opened for the disk statistics!
   # if diskstats (2.6) doesn't exists then let's try to read
   # the partitions (2.4)

   if ($fh->open($file->{diskstats}, 'r')) {
      while (my $line = <$fh>) {
         if ($line =~ /^\s+(\d+)\s+(\d+)\s+(.+?)\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+$/ && defined $4 && defined $6) {
            for my $x ($stats{$3}) {
               $x->{major}   = $1;
               $x->{minor}   = $2;
               $x->{rdreq}   = $4;
               $x->{rdbyt}   = $5 * $bksz;
               $x->{wrtreq}  = $6;
               $x->{wrtbyt}  = $7 * $bksz;
               $x->{ttreq}  += $x->{rdreq} + $x->{wrtreq};
               $x->{ttbyt}  += $x->{rdbyt} + $x->{wrtbyt};
            }
         } elsif ($line =~ /^\s+(\d+)\s+(\d+)\s+(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/) {
            for my $x ($stats{$3}) {
               $x->{major}   = $1;
               $x->{minor}   = $2;
               $x->{rdreq}   = $4;
               $x->{rdbyt}   = $5 * $bksz;
               $x->{wrtreq}  = $6;
               $x->{wrtbyt}  = $7 * $bksz;
               $x->{ttreq}  += $x->{rdreq} + $x->{wrtreq};
               $x->{ttbyt}  += $x->{rdbyt} + $x->{wrtbyt};
            }
         } else {
            next;
         }
      }
      $fh->close;
   } elsif ($fh->open($file->{partitions}, 'r')) {
      while (my $line = <$fh>) {
         $line =~ tr/A-Z/a-z/;
         next unless $line =~ /^\s+(\d+)\s+(\d+)\s+\d+\s+(.+?)\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+\s+\d+$/ && defined $4 && defined $6;
         for my $x ($stats{$3}) {
            $x->{major}   = $1;
            $x->{minor}   = $2;
            $x->{rdreq}   = $4;
            $x->{rdbyt}   = $5 * $bksz;
            $x->{wrtreq}  = $6;
            $x->{wrtbyt}  = $7 * $bksz;
            $x->{ttreq}  += $x->{rdreq} + $x->{wrtreq};
            $x->{ttbyt}  += $x->{rdbyt} + $x->{wrtbyt};
         }
      }
      $fh->close;
   } else {
      croak "$class: unable to open $file->{diskstats} or $file->{partitions} ($!)";
   }

   return \%stats;
}

sub _deltas {
   my $self  = shift;
   my $class = ref $self;
   my $istat = $self->{init};
   my $lstat = $self->{stats};

   foreach my $dev (keys %{$lstat}) {
      unless (exists $istat->{$dev}) {
         delete $lstat->{$dev};
         next;
      }

      my $idev = $istat->{$dev};
      my $ldev = $lstat->{$dev};

      while (my ($k, $v) = each %{$ldev}) {
         croak "$class: different keys in statistics"
            unless defined $idev->{$k};
         croak "$class: value of '$k' is not a number"
            unless $v =~ /^\d+$/ && $ldev->{$k} =~ /^\d+$/;
         $ldev->{$k} -= $idev->{$k};
         $idev->{$k}  = $v;
      }
   }
}

1;
