=head1 NAME

Sys::Statistics::Linux::DiskStats - Collect linux disk statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::DiskStats;

   my $lxs = new Sys::Statistics::Linux::DiskStats;
   $lxs->init;
   sleep 1;
   my $stats = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::DiskStats gathers disk statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 DISK STATISTICS

Generated by F</proc/diskstats> or F</proc/partitions>.

   major   -  The mayor number of the disk
   minor   -  The minor number of the disk
   rdreq   -  Number of read requests that were made to physical disk per second.
   rdbyt   -  Number of bytes that were read from physical disk per second.
   wrtreq  -  Number of write requests that were made to physical disk per second.
   wrtbyt  -  Number of bytes that were written to physical disk per second.
   ttreq   -  Total number of requests were made from/to physical disk per second.
   ttbyt   -  Total number of bytes transmitted from/to physical disk per second.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = new Sys::Statistics::Linux::DiskStats;

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
our $VERSION = '0.12';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      files => {
         diskstats => '/proc/diskstats',
         partitions => '/proc/partitions',
         uptime => '/proc/uptime',
      },
      # --------------------------------------------------------------
      # The sectors are equivalent with blocks and have a size of 512
      # bytes since 2.4 kernels. This value is needed to calculate the
      # amount of disk i/o's in bytes.
      # --------------------------------------------------------------
      blocksize => 512,
   );
   return bless \%self, $class;
}

sub init {
   my $self = shift;
   $self->{uptime} = $self->_uptime;
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
   my $bksz  = $self->{blocksize};
   my (%stats, $fh);

   # --------------------------------------------------------
   # one of the both must be opened for the disk statistics!
   # if diskstats (2.6) doesn't exists then let's try to read
   # the partitions (2.4)
   #
   # /usr/src/linux/Documentation/iostat.txt shortcut
   #
   # ... the statistics fields are those after the device name.
   #
   # Field  1 -- # of reads issued
   #     This is the total number of reads completed successfully.
   # Field  2 -- # of reads merged, field 6 -- # of writes merged
   #     Reads and writes which are adjacent to each other may be merged for
   #     efficiency.  Thus two 4K reads may become one 8K read before it is
   #     ultimately handed to the disk, and so it will be counted (and queued)
   #     as only one I/O.  This field lets you know how often this was done.
   # Field  3 -- # of sectors read
   #     This is the total number of sectors read successfully.
   # Field  4 -- # of milliseconds spent reading
   #     This is the total number of milliseconds spent by all reads (as
   #     measured from __make_request() to end_that_request_last()).
   # Field  5 -- # of writes completed
   #     This is the total number of writes completed successfully.
   # Field  7 -- # of sectors written
   #     This is the total number of sectors written successfully.
   # Field  8 -- # of milliseconds spent writing
   #     This is the total number of milliseconds spent by all writes (as
   #     measured from __make_request() to end_that_request_last()).
   # Field  9 -- # of I/Os currently in progress
   #     The only field that should go to zero. Incremented as requests are
   #     given to appropriate request_queue_t and decremented as they finish.
   # Field 10 -- # of milliseconds spent doing I/Os
   #     This field is increases so long as field 9 is nonzero.
   # Field 11 -- weighted # of milliseconds spent doing I/Os
   #     This field is incremented at each I/O start, I/O completion, I/O
   #     merge, or read of these stats by the number of I/Os in progress
   #     (field 9) times the number of milliseconds spent doing I/O since the
   #     last update of this field.  This can provide an easy measure of both
   #     I/O completion time and the backlog that may be accumulating.
   # --------------------------------------------------------

   if (open $fh, '<', $file->{diskstats}) {
      while (my $line = <$fh>) {
         if ($line =~ /^\s+(\d+)\s+(\d+)\s+(.+?)\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+$/) {
            for my $x ($stats{$3}) { # $3 -> the device name
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

         # --------------------------------------------------------
         # Field  1 -- # of reads issued
         #     This is the total number of reads issued to this partition.
         # Field  2 -- # of sectors read
         #     This is the total number of sectors requested to be read from this
         #     partition.
         # Field  3 -- # of writes issued
         #     This is the total number of writes issued to this partition.
         # Field  4 -- # of sectors written
         #     This is the total number of sectors requested to be written to
         #     this partition.
         # --------------------------------------------------------

         elsif ($line =~ /^\s+(\d+)\s+(\d+)\s+(.+?)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/) {
            for my $x ($stats{$3}) { # $3 -> the device name
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
      }
      close($fh);
   } elsif (open $fh, '<', $file->{partitions}) {
      while (my $line = <$fh>) {
         next unless $line =~ /^\s+(\d+)\s+(\d+)\s+\d+\s+(.+?)\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+(\d+)\s+\d+\s+\d+\s+\d+\s+\d+$/;
         for my $x ($stats{$3}) { # $3 -> the device name
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
      close($fh);
   } else {
      croak "$class: unable to open $file->{diskstats} or $file->{partitions} ($!)";
   }

   croak "$class: no diskstats found! your system seems not to be compiled with CONFIG_BLK_STATS=y"
      unless -e $file->{diskstats} || %stats;

   return \%stats;
}

sub _deltas {
   my $self   = shift;
   my $class  = ref $self;
   my $istat  = $self->{init};
   my $lstat  = $self->{stats};
   my $uptime = $self->_uptime;
   my $delta  = sprintf('%.2f', $uptime - $self->{uptime});
   $self->{uptime} = $uptime;

   foreach my $dev (keys %{$lstat}) {
      unless (exists $istat->{$dev}) {
         delete $lstat->{$dev};
         next;
      }

      my $idev = $istat->{$dev};
      my $ldev = $lstat->{$dev};

      while (my ($k, $v) = each %{$ldev}) {
         next if $k =~ /^major\z|^minor\z/;

         croak "$class: different keys in statistics"
            unless defined $idev->{$k};
         croak "$class: value of '$k' is not a number"
            unless $v =~ /^\d+$/ && $ldev->{$k} =~ /^\d+$/;

         $ldev->{$k} =
            $ldev->{$k} == $idev->{$k}
               ? sprintf('%.2f', 0)
               : $delta > 0
                  ? sprintf('%.2f', ($ldev->{$k} - $idev->{$k}) / $delta)
                  : sprintf('%.2f', $ldev->{$k} - $idev->{$k});

         $idev->{$k}  = $v;
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

1;
