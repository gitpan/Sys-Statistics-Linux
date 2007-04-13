=head1 NAME

Sys::Statistics::Linux - Front-end module to collect system statistics

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

Sys::Statistics::Linux is the front-end module to Sys-Statistics-Linux and collects
different linux system informations like processor workload, memory usage, network and
disk statistics and a lot more. Refer to the documentation of the distribution
modules to get informations about all possible statistics.

=head1 TECHNICAL NOTE

This distribution collects statistics by the virtual F</proc> filesystem (procfs) and is developed
on default vanilla kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390
and s390x architecture as well), Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions
2.4 and 2.6 and should run on all linux kernels with a default vanilla kernel as well.
It is possible that this module doesn't run on all distributions if the procfs is too much modified.

For example the linux kernel 2.4 can compiled with the option "CONFIG_BLK_STATS". It is possible to
activate or deactivate the block statistics for devices with this option. These statistics doesn't
exist in /proc/partitions if this option isn't activated. Since linux kernel 2.5 these statistics are
in /proc/diskstats.

=head1 DELTAS

The options C<CpuStats>, C<ProcStats>, C<PgSwStats>, C<NetStats>, C<DiskStats> and C<Processes>
are deltas, for this reason it's necessary to initialize the statistics first before the data
be generated with C<get()>. These statistics can be initialized with the methods C<new()>, C<set()>
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
can delete, set pause or create new statistics with C<set()> and re-init all statistics with
C<init()>.

The options must be set with on of the following values:

   -1 - set pause on statistics but wouldn't delete them
    0 - delete statistics and destroy the object
    1 - create a new object and init statistics if necessary
    2 - create a new object if not exists but wouldn't init statistics

To get more informations about the statistics refer the different modules of the distribution.

   SysInfo     -  Collect system informations             with Sys::Statistics::Linux::SysInfo.
   CpuStats    -  Collect cpu statistics                  with Sys::Statistics::Linux::CpuStats.
   ProcStats   -  Collect process statistics              with Sys::Statistics::Linux::ProcStats.
   MemStats    -  Collect memory statistics               with Sys::Statistics::Linux::MemStats.
   PgSwStats   -  Collect paging and swapping statistics  with Sys::Statistics::Linux::PgSwStats.
   NetStats    -  Collect net statistics                  with Sys::Statistics::Linux::NetStats.
   SockStats   -  Collect socket statistics               with Sys::Statistics::Linux::SockStats.
   DiskStats   -  Collect disk statistics                 with Sys::Statistics::Linux::DiskStats.
   DiskUsage   -  Collect the disk usage                  with Sys::Statistics::Linux::DiskUsage.
   LoadAVG     -  Collect the load average                with Sys::Statistics::Linux::LoadAVG.
   FileStats   -  Collect inode statistics                with Sys::Statistics::Linux::FileStats.
   Processes   -  Collect process statistics              with Sys::Statistics::Linux::Processes.

=head1 METHODS

=head2 new()

Call C<new()> to create a new Sys::Statistics::Linux object. You can call C<new()> with options.
This options would be hand off to the C<set()> method.

Without options

         my $lxs = new Sys::Statistics::Linux;

Or with options

         my $lxs = Sys::Statistics::Linux->new(CpuStats => 1);

Would do nothing

         my $lxs = Sys::Statistics::Linux->new(CpuStats => 0);

It's possible to call C<new()> with a hash reference of options.

         my %options = (
            CpuStats => 1,
            MemStats => 1
         );

         my $lxs = Sys::Statistics::Linux->new(\%options);

Take a look to C<set()> for more informations.

=head2 set()

Call C<set()> to activate or deactivate options. The following example would call C<new()> and C<init()>
of C<Sys::Statistics::Linux::CpuStats> and delete the object of C<Sys::Statistics::Linux::SysInfo>:

         $lxs->set(
            CpuStats  => -1, # activated, but paused, wouldn't delete the object
            Processes =>  0, # deactivate - would delete the statistics and destroy the object
            PgSwStats =>  1, # activate the statistic and calls C<new()> and C<init()> if necessary
            NetStats  =>  2, # activate the statistic and call C<new()> if necessary but not C<init()>
         );

It's possible to call C<set()> with a hash reference of options.

         my %options = (
            CpuStats => 2,
            MemStats => 2
         );

         $lxs->set(\%options);

=head2 get()

Call C<get()> to get the collected statistics. C<get()> returns the statistics as a hash reference.

         my $stats = $lxs->get;

=head2 init()

The call of C<init()> re-init all statistics that are necessary for deltas and if the option is higher than 0.

         $lxs->init;

=head2 search(), fproc()

Both methods provides a simple search engine to find special statistics. Both methods except a filter
as a hash reference as the first argument. If your data comes from extern - maybe from a client that
send his statistics to the server - you can set the statistics as the second argument. The second
argument have to be a hash reference as well.

The C<search()> method search for statistics and rebuilds the hash tree until that keys that matched
your filter and returns the hits as a hash reference.

        my $hits = $lxs->search({
           Processes => {
              cmd   => qr/\[su\]/,
              owner => qr/root/
           },
           CpuStats => {
              total  => 'gt:50',
              iowait => '>10'
           },
           DiskUsage => {
              '/dev/sda1' => {
                 usageper => 'gt:80'
              }
           }
        });

This would return the following matches:

    * processes with the command C<[su]>
    * processes with the owner C<root>
    * all cpu where the C<total> usage is grather than 50
    * all cpu where C<iowait> is grather than 10
    * only that disk where C<usageper> is higher than 80

If your statistics comes from extern, than you can set the full statistics as the second argument.

        my %stats = (
           CpuStats => {
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
               
        my %filter = (
           CpuStats => {
              total => 'gt:50'
           }
        );

        my $hits = $lxs->search(\%filter, \%stats);

The C<fproc()> method search for processes only and returns a array reference with all process IDs that
matched the filter. Example:

        my $pids = $lxs->fproc({ cmd => qr/init/, owner => 'eq:apache' });

You can set the statistics as second argument as well if your statistics comes from extern.

        my $pids = $lxs->fproc(\%filter, \%stats);

This would return the following process ids:

    * processes that matched the command C<init>
    * processes with the owner C<apache>

There are different match operators available:

    * gt or > - grather than
    * lt or < - less than
    * eq or = - is equal
    * ne or ! - is not equal

Notation examples:

    gt:50  or  >50
    lt:50  or  <50
    eq:50  or  =50
    ne:50  or  !50

Both argumnents have to be set as a hash reference.

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
         $lxs->set(SysStats => 0);

         # $stats contains CpuStats and MemStats
         sleep(1);
         $stats = $lxs->get;
         print Dumper($stats);

Set and get a time stamp:

         use warnings;
         use strict;
         use Sys::Statistics::Linux;

         my $lxs = new Sys::Statistics::Linux;
         $lxs->settime('%Y/%m/%d %H:%M:%S');
         print "$lxs->gettime\n";

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

=head1 DEPENDENCIED

    Test::More
    Carp

=head1 EXPORTS

No exports.

=head1 TODOS

   * Dynamic loader for options/modules.
   * Maybe Sys::Statistics::Linux::Formatter to format statistics
     for inserts into a database or a nice output to files.
   * Are there any wishs from your side? Send me a mail!

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux;
our $VERSION = '0.09_14';

use strict;
use warnings;
use Carp qw(croak);
use POSIX qw(strftime);
use constant RXOPTION => qr/^[0-2\-1]$/;

sub new {
   my $class = shift;
   my $self = bless {
      opts  => {
         SysInfo   =>  0,
         CpuStats  =>  0,
         ProcStats =>  0,
         MemStats  =>  0,
         PgSwStats =>  0,
         NetStats  =>  0,
         SockStats =>  0,
         DiskStats =>  0,
         DiskUsage =>  0,
         LoadAVG   =>  0,
         FileStats =>  0,
         Processes =>  0,
      },
      init  => {},
      stats => {},
      obj   => {},
   }, $class; 
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
      croak "$class: invalid option '$opt'"
         unless exists $opts->{$opt};
      croak "$class: invalid value for '$opt'"
         unless $sets->{$opt} =~ RXOPTION;

      $opts->{$opt} = $sets->{$opt};

      if ($opts->{$opt} > 0) {
         my $package = $class."::".$opt;

         # require mod if not loaded
         unless (defined &{$package.'::new'}) {
            my $require = $package;
            $require =~ s/::/\//g;
            require "$require.pm"
               or croak "$class: unable to load $require.pm";
         }

         # create a new object if the object doesn't exist
         $obj->{$opt} = $package->new()
            unless $obj->{$opt};

         # get initial statistics if init() is defined and the
         # option is set to 1
         $obj->{$opt}->init() 
            if $opts->{$opt} == 1
            && defined &{$package.'::init'};

      } elsif ($opts->{$opt} == 0) {
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
         && $opts->{$opt} > 0;
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
         if $opts->{$opt} > 0;
   }

   return $stats;
}

sub search {
   my $self   = shift;
   my $class  = ref($self);

   croak "$class: first argument have to be a hash ref"
     unless $_[0] && ref($_[0]) eq 'HASH';
   croak "$class: second argument have to be a hash ref"
     if $_[1] && ref($_[1]) ne 'HASH';

   my ($filter, $stats) = @_ == 2 ? @_ : (shift, $self->{stats});

   # $stats and $filter must be set
   return undef unless %{$stats} && %{$filter};

   my $opts   = $self->{opts};
   my %hits   = ();

   foreach my $opt (keys %{$filter}) {

      # this 2 croaks are the only croaks in this loop
      croak "$class: not a hash ref opt '$opt'"
         unless ref($filter->{$opt}) eq 'HASH';
      croak "$class: invalid option '$opt'"
         unless exists $opts->{$opt};

      # next if the object isn't loaded
      next unless exists $stats->{$opt};

      # some sub refs
      my $fref = $filter->{$opt};
      my $sref = $stats->{$opt};

      # we search for matches for each key that is defined
      # in %filter and rebuild the tree until that key that
      # matched the searched string

      foreach my $x (keys %{$fref}) {

         # if $fref->{$x} is a hash ref than the next key have to
         # match the statistic key. this is used for statistics
         # like NetStats or Processes that uses a hash key for the
         # device name or process id. NetStats example:
         #
         # if
         #
         #    $fref->{eth0}->{ttbyt}
         #
         # is defined as filter, than the key "eth0" have to match
         #
         #    $sref->{eth0}
         #
         # than we look if "ttbyt" matched the searched string

         if (ref($fref->{$x}) eq 'HASH') {

            # if the key $sref->{eth0} doesn't exists
            # than we continue with the next defined filter
            next unless exists $sref->{$x};

            while ( my ($name, $value) = each %{$fref->{$x}} ) {
               $hits{$opt}{$x}{$name} = $sref->{$x}->{$name}
                  if exists $sref->{$x}->{$name}
                  && $class->_diff($sref->{$x}->{$name}, $value);
            }

         # if ref($fref->{$x}) is return a regexp or 'nothing' than we
         # search for matches in all key-value pairs that matched

         } elsif (ref($fref->{$x}) =~ /^(Regexp|)$/) {
            foreach my $key (keys %{$sref}) {
               if (ref($sref->{$key}) eq 'HASH') {
                  $hits{$opt}{$key}{$x} = $sref->{$key}->{$x}
                     if exists $sref->{$key}->{$x}
                     && $class->_diff($sref->{$key}->{$x}, $fref->{$x});
               } else {
                  $hits{$opt}{$x} = $sref->{$x}
                     if exists $sref->{$x}
                     && $class->_diff($sref->{$x}, $fref->{$x});
                  last;
               }
            }
         }
      }
   }

   return %hits ? \%hits : undef;
}

sub fproc {
   my $self   = shift;
   my $class  = ref($self);

   croak "$class: first argument have to be a hash ref"
     unless $_[0] && ref($_[0]) eq 'HASH';
   croak "$class: second argument have to be a hash ref"
     if $_[1] && ref($_[1]) ne 'HASH';

   my ($filter, $stats) = @_ == 2 ? @_ : (shift, $self->{stats});

   return undef unless %{$stats->{Processes}} && %{$filter};

   my @hits = ();
   my $sref = $stats->{Processes};

   foreach my $pid (keys %{$sref}) {
      my $proc = $sref->{$pid};

      while ( my ($key, $value) = each %{$filter} ) {
         push @hits, $pid
            if exists $proc->{$key}
            && $class->_diff($proc->{$key}, $value);
      }
   }

   return @hits ? \@hits : undef;
}

#
# private stuff
#

sub _diff {
   my ($c, $x, $y) = @_;

   return 1
      if ( ref($y) eq 'Regexp'  &&  $x =~ $y )
      || ( $y =~ s/^(eq:|=)//   &&  $x eq $y )
      || ( $y =~ s/^(ne:|!)//   &&  $x ne $y )
      || ( $y =~ s/^(gt:|>)//   &&  $y =~ /^\d+$/  &&  $x > $y )
      || ( $y =~ s/^(lt:|<)//   &&  $y =~ /^\d+$/  &&  $x < $y );

   return undef;
}

sub _struct {
   my $class = shift;

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
