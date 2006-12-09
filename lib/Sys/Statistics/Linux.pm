=head1 NAME

Sys::Statistics::Linux - Collect linux system statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux;

   my $lxs = new Sys::Statistics::Linux;

   $lxs->set(
      SysInfo   => 1,
      CpuStats  => 1,
      ProcStats => 1,
      MemStats  => 1,
      PgSwStats => 1,
      NetStats  => 1,
      SockStats => 1,
      DiskStats => 1,
      DiskUsage => 1,
      LoadAVG   => 1,
      FileStats => 1,
      Processes => 1,
   );

   sleep 1;

   my $stat = $lxs->get;

=head1 DESCRIPTION

This module is the main package from the distribution Sys::Statistics::Linux and collects
different linux system informations like processor workload, memory usage, network and
disk statisitcs and other system informations. Refer to the documentation of the distribution
modules to get more informations about all possible statistics and system informations.

=head1 TECHNICAL NOTE

This distribution collects statistics by the virtual F</proc> filesystem (procfs) and is developed
on default vanilla kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390
and s390x architecture as well), Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions
2.4 and 2.6 and should run on all linux kernels with a default vanilla kernel as well. It is possible
that this module doesn't run on all distributions if the procfs is too much modified.

Further it is necessary to run it as a user with the authorization to read the F</proc> filesystem.

=head1 DELTAS

The options C<CpuStats>, C<ProcStats>, C<PgSwStats>, C<NetStats>, C<DiskStats> and C<Processes>
are deltas, for this reason it's necessary to initialize the statistics first, before the data
be generated with C<get()>. The statistics can be initialized with the methods C<new()>, C<set()>
and C<init()>. Each option that is set to TRUE (1) will be initialized by the call of C<new()>
or C<set()>. The call of C<init()> reinitialize all statistics that are set to 1. By the call
of C<get()> the initial statistics will be updated automatically. Please refer the METHOD section
to get more information about the calls of C<new()>, C<set()> and C<get()>.

Another exigence is that you need to sleep for while - at least for one second - before you
call C<get()> if you want to get useful statistics. The options C<SysInfo>, C<MemStats>,
C<SockStats>, C<DiskUsage>, C<LoadAVG> and C<FileStats> are no deltas. If you need only one
of this informations you don't need to sleep before the call of C<get()>.

The C<get()> function collects all requested informations and returns a hash reference with the
statistics. The inital statistics will be updated. You can turn on and off options with C<set()>.

=head1 OPTIONS

All options are identical with the package names of the distribution. To activate the gathering
of statistics you have to set the options by the call of C<new()> or C<set()>. In addition you
can deactivate - respectively delete - statistics with C<set()> and re-init all statistics with
C<init()>.

The options must be set with a BOOLEAN value (1|0).

   1 - activate (initialize)
   0 - deactivate (delete)

To get more informations about each option refer the different modules of the distribution.

   SysInfo     -  Collect system informations             with L<Sys::Statistics::Linux::SysInfo>.
   CpuStats    -  Collect cpu statistics                  with L<Sys::Statistics::Linux::CpuStats>.
   ProcStats   -  Collect process statistics              with L<Sys::Statistics::Linux::ProcStats>.
   MemStats    -  Collect memory statistics               with L<Sys::Statistics::Linux::MemStats>.
   PgSwStats   -  Collect paging and swapping statistics  with L<Sys::Statistics::Linux::PgSwStats>.
   NetStats    -  Collect net statistics                  with L<Sys::Statistics::Linux::NetStats>.
   SockStats   -  Collect socket statistics               with L<Sys::Statistics::Linux::SockStats>.
   DiskStats   -  Collect disk statistics                 with L<Sys::Statistics::Linux::DiskStats>.
   DiskUsage   -  Collect the disk usage                  with L<Sys::Statistics::Linux::DiskUsage>.
   LoadAVG     -  Collect the load average                with L<Sys::Statistics::Linux::LoadAVG>.
   FileStats   -  Collect inode statistics                with L<Sys::Statistics::Linux::FileStats>.
   Processes   -  Collect process statistics              with L<Sys::Statistics::Linux::Processes>.

=head1 METHODS

=head2 new()

Call C<new()> to create a new Statistic object. Necessary statistics will be initialized.

Without options

         my $lxs = new Sys::Statistics::Linux;

Or with options

         my $lxs = Sys::Statistics::Linux->new(CpuStats => 1);

Will do nothing

         my $lxs = Sys::Statistics::Linux->new(CpuStats => 0);

It's possible to call C<new()> with a hash reference of options.

         my %options = (
            CpuStats => 1,
            MemStats => 1
         );

         my $lxs = Sys::Statistics::Linux->new(\%options);

=head2 set()

Call C<set()> to activate (initialize) or deactivate (delete) options.

         $lxs->set(
            CpuStats => 1, # activate
            SysInfo  => 0, # deactivate
         );

It's possible to call C<set()> with a hash reference of options.

         my %options = (
            CpuStats => 1,
            MemStats => 1
         );

         $lxs->set(\%options);

Activate options with C<set()> will initialize necessary statistics.

         $lxs->set(CpuStats => 1); # initialize it
         $lxs->set(CpuStats => 1); # initialize it again

=head2 get()

Call C<get()> to get the collected statistics. C<get()> returns the statistics as a hash reference.

         my $stats = $lxs->get;

=head2 init()

The call of C<init()> re-init all statistics that are necessary for deltas and if the option is set to 1.

         $lxs->init;

=head2 settime()

Call C<settime()> to define a POSIX formatted time stamp, generated with localtime().

         $lxs->settime('%Y/%m/%d %H:%M:%S');

To get more informations about the formats take a look at C<strftime()> of POSIX.pm
or the manpage C<strftime(3)>.

=head2 gettime()

C<gettime()> returns a POSIX formatted time stamp, @foo in list and $bar in scalar context.
If the time format isn't set then the default format "%Y-%m-%d %H:%M:%S" will be set automatically.
You can also set a time format with C<gettime()>.

         my $date_time = $lxs->gettime;

Or

         my ($date, $time) = $lxs->gettime;

Or

         my ($date, $time) = $lxs->gettime('%Y/%m/%d %H:%M:%S');

=head1 EXAMPLES

A very simple perl script could looks like this:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;

         my $lxs = Sys::Statistics::Linux->new( CpuStats => 1 );
         sleep(1);
         my $stats = $lxs->get;
         my $cpu   = $stats->{CpuStats}->{cpu};

         print "Statistics for CpuStats (all)\n";
         print "  user      $cpu->{user}\n";
         print "  nice      $cpu->{nice}\n";
         print "  system    $cpu->{system}\n";
         print "  idle      $cpu->{idle}\n";
         print "  ioWait    $cpu->{iowait}\n";
         print "  total     $cpu->{total}\n";

Example to collect network statistics with a nice output:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;

         $| = 1;

         my $header  = 20;
         my $average = 1;
         my $columns = 8;
         my $options = { NetStats => 1 };

         my @order = qw(
            rxbyt rxpcks rxerrs rxdrop rxfifo rxframe rxcompr rxmulti
            txbyt txpcks txerrs txdrop txfifo txcolls txcarr txcompr
         );

         my $lxs = Sys::Statistics::Linux->new( $options );

         my $h = $header;

         while (1) {
            sleep($average);
            my $stats = $lxs->get;
            if ($h == $header) {
               printf "%${columns}s", $_ for ('iface', @order);
               print "\n";
            }
            foreach my $device (keys %{$stats->{NetStats}}) {
               my $dstat = $stats->{NetStats}->{$device};
               printf "%${columns}s", $device;
               printf "%${columns}s", $dstat->{$_} for @order;
               print "\n";
            }
            $h = $header if --$h == 0;
         }

Activate and deactivate statistics:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;
         use Data::Dumper;

         my $lxs = new Sys::Statistics::Linux;

         # set the options
         $lxs->set(
            SysInfo  => 1,
            CpuStats => 1,
            MemStats => 1
         );

         # sleep to get useful statistics for CpuStats
         sleep(1);

         # $stats contains SysInfo, CpuStats and MemStats
         my $stats = $lxs->get;
         print Dumper($stats);

         # we deactivate CpuStats
         $lxs->set(CpuStats => 0);

         # $stats contains SysInfo and MemStats
         $stats = $lxs->get;
         print Dumper($stats);

Set and get a time stamp:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;

         my $lxs = new Sys::Statistics::Linux;
         $lxs->settime('%Y/%m/%d %H:%M:%S');
         print $lxs->gettime, "\n";

If you're not sure you can use the the C<Data::Dumper> module to learn more about the hash structure:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;
         use Data::Dumper;

         my $lxs = Sys::Statistics::Linux->new( CpuStats => 1 );
         sleep(1);
         my $stats = $lxs->get;

         print Dumper($stats);

Take a look into the the F<examples> directory of the distribution for some examples with a nice output. :-)

=head1 EXPORTS

No exports.

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux;
our $VERSION = '0.02';

use strict;
use warnings;
use Carp qw(croak);
use POSIX qw(strftime);

use Sys::Statistics::Linux::SysInfo;
use Sys::Statistics::Linux::CpuStats;
use Sys::Statistics::Linux::ProcStats;
use Sys::Statistics::Linux::MemStats;
use Sys::Statistics::Linux::PgSwStats;
use Sys::Statistics::Linux::NetStats;
use Sys::Statistics::Linux::SockStats;
use Sys::Statistics::Linux::DiskStats;
use Sys::Statistics::Linux::DiskUsage;
use Sys::Statistics::Linux::LoadAVG;
use Sys::Statistics::Linux::FileStats;
use Sys::Statistics::Linux::Processes;

use constant BOOLEAN => qr/^(0|1)$/;
use constant STATISTICS => {
   SysInfo   => BOOLEAN,
   CpuStats  => BOOLEAN,
   ProcStats => BOOLEAN,
   MemStats  => BOOLEAN,
   PgSwStats => BOOLEAN,
   NetStats  => BOOLEAN,
   SockStats => BOOLEAN,
   DiskStats => BOOLEAN,
   DiskUsage => BOOLEAN,
   LoadAVG   => BOOLEAN,
   FileStats => BOOLEAN,
   Processes => BOOLEAN,
};

sub new {
   my $self = bless {
      opts  => {},
      init  => {},
      stats => {},
      obj   => {},
   }, shift;
   $self->set(@_) if @_;
   return $self;
}

sub set {
   my $self  = shift;
   my $class = ref $self;
   my $sets  = $class->_struct(@_);
   my $opts  = $self->{opts};
   my $obj   = $self->{obj};
   my $stats = $self->{stats};

   foreach my $opt (keys %{$sets}) {

      # validate the options
      croak "$class: wrong option '$opt'"
         unless exists STATISTICS->{$opt};
      croak "$class: wrong value for '$opt'"
         unless $sets->{$opt} =~ /${\STATISTICS->{$opt}}/;

      $opts->{$opt} = $sets->{$opt};

      if ($opts->{$opt} == 1) {
         my $package = $class."::".$opt;

         # create a new object if the object doesn't exist
         $obj->{$opt} = $package->new() unless $obj->{$opt};

         # get initial statistics if init() is defined
         $obj->{$opt}->init() if defined &{$package.'::init'};

      } else {
         # if $opts->{$opt} == 0
         delete $obj->{$opt}   if $obj->{$opt};
         delete $stats->{$opt} if $stats->{$opt};
      }
   }
}

sub init {
   my $self  = shift;
   my $class = ref $self;
   my $obj   = $self->{obj};
   my $opts  = $self->{opts};

   foreach my $opt (keys %{$opts}) {
      my $package = $class."::".$opt;
      $obj->{$opt}->init()
         if defined &{$package.'::init'}
         && $opts->{$opt} == 1;
   }
}

sub settime {
   my $self   = shift;
   my $format = $_[0] ? $_[0] : '%Y-%m-%d %H:%M:%S';
   $self->{timeformat} = $format;
}

sub gettime {
   my $self = shift;
   $self->settime(@_) unless $self->{timeformat};
   my $tm = strftime($self->{timeformat}, localtime);
   return wantarray ? split /\s+/, $tm : $tm;
}

sub get {
   my $self   = shift;
   my $opts   = $self->{opts};
   my $stats  = $self->{stats};
   my $obj    = $self->{obj};
   my $format = $self->{timeformat};

   foreach my $opt (keys %{$opts}) {
      $stats->{$opt} = $obj->{$opt}->get()
         if $opts->{$opt} == 1;
   }

   return $stats;
}

#
# private stuff
#

sub _struct {
   my $self = shift;

   return
      ref($_[0])
         ? ref($_[0]) eq 'HASH'
            ? $_[0]
            : croak "not a hash ref"
         : @_ % 2
            ? croak "odd number of elements in hash"
            : {@_};
}

1;
