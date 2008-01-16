=head1 NAME

Sys::Statistics::Linux - Front-end module to collect system statistics

=head1 SYNOPSIS

    use Sys::Statistics::Linux;

    my $lxs = Sys::Statistics::Linux->new(
        sysinfo   => 1,
        cpustats  => 1,
        procstats => 1,
        memstats  => 1,
        pgswstats => 1,
        netstats  => 1,
        sockstats => 1,
        diskstats => 1,
        diskusage => 1,
        loadavg   => 1,
        filestats => 1,
        processes => 1,
    );

    sleep 1;

    # $stat is a Sys::Statistics::Linux::Compilation object
    my $stat = $lxs->get;

    foreach my $key ($stat->loadavg) {
        print $key, " ", $stat->loadavg($key), "\n";
    }

=head1 DESCRIPTION

Sys::Statistics::Linux is a front-end module and gather different linux system informations
like processor workload, memory usage, network and disk statistics and a lot more. Refer the
documentation of the distribution modules to get more informations about all possible statistics.

=head1 MOTIVATION

My motivation is very simple. Every linux administrator knows the well-known tool sar of sysstat.
It helps me a lot of time to search for system bottlenecks and to solve problems but it's hard to
parse the output and to store different statistics into a database. So I though to develope
Sys::Statistics::Linux. It's not a replacement but it should make it simpler to you to write your
own system monitor.

If Sys::Statistics::Linux doesn't provide statistics that are strongly needed then let me know it.

=head1 TECHNICAL NOTE

This distribution collects statistics by the virtual F</proc> filesystem (procfs) and is
developed on default vanilla kernels. It is tested on x86 hardware with the distributions RHEL,
Fedora, Debian, Ubuntu, Asianux, Slackware, Mandriva, SuSE (SuSE on s390 and s390x architecture
as well but a long time ago) and openSUSE on kernel versions 2.4 and/or 2.6 and should run on all
linux kernels with a default vanilla kernel as well. It's possible that it doesn't run on all linux
distributions if some procfs features are deactivated or too much modified. As example the linux
kernel 2.4 can compiled with the option C<CONFIG_BLK_STATS> what turn on or off block statistics
for devices.

=head1 DELTAS

The statistics for C<CpuStats>, C<ProcStats>, C<PgSwStats>, C<NetStats>, C<DiskStats> and C<Processes>
are deltas, for this reason it's necessary to initialize the statistics first before the data
can be prepared by C<get()>. These statistics can be initialized with the methods C<new()>,
C<set()> and C<init()>. Any option that is set to 1 will be initialized by the call of C<new()>
or C<set()>. The call of init() re-initialize all statistics that are set to 1 or 2. By the call
of C<get()> the initial statistics will be updated automatically. Please refer the METHOD section
to get more information about the calls of C<new()>, C<set()>, C<init()> and C<get()>.

Another exigence is to sleep for while - at least for one second - before the call of C<get()>
if you want to get useful statistics. The statistics for C<SysInfo>, C<MemStats>, C<SockStats>,
C<DiskUsage>, C<LoadAVG> and C<FileStats> are no deltas. If you need only one of these informations
you don't need to sleep before the call of C<get()>.

The method C<get()> prepares all requested statistics and returns the statistics as a
C<Sys::Statistics::Linux::Compilation> object. The inital statistics will be updated.

=head1 OPTIONS

All options are identical with the package names of the distribution in lowercase. To activate
the gathering of statistics you have to set the options by the call of C<new()> or C<set()>.
In addition you can deactivate statistics with C<set()>.

The options must be set with one of the following values:

    0 - deactivate statistics
    1 - activate and init statistics
    2 - activate statistics but don't init

In addition it's possible to handoff a process list for option C<Processes>.

    my $lxs = Sys::Statistics::Linux->new(
        processes => {
            init => 1,
            pids => [ 1, 2, 3 ]
        }
    );

To get more informations about the statistics refer the different modules of the distribution.

    sysinfo     -  Collect system informations             with Sys::Statistics::Linux::SysInfo.
    cpustats    -  Collect cpu statistics                  with Sys::Statistics::Linux::CpuStats.
    procstats   -  Collect process statistics              with Sys::Statistics::Linux::ProcStats.
    memstats    -  Collect memory statistics               with Sys::Statistics::Linux::MemStats.
    pgswstats   -  Collect paging and swapping statistics  with Sys::Statistics::Linux::PgSwStats.
    netstats    -  Collect net statistics                  with Sys::Statistics::Linux::NetStats.
    sockstats   -  Collect socket statistics               with Sys::Statistics::Linux::SockStats.
    diskstats   -  Collect disk statistics                 with Sys::Statistics::Linux::DiskStats.
    diskusage   -  Collect the disk usage                  with Sys::Statistics::Linux::DiskUsage.
    loadavg     -  Collect the load average                with Sys::Statistics::Linux::LoadAVG.
    filestats   -  Collect inode statistics                with Sys::Statistics::Linux::FileStats.
    processes   -  Collect process statistics              with Sys::Statistics::Linux::Processes.

=head1 METHODS

=head2 new()

Call C<new()> to create a new Sys::Statistics::Linux object. You can call C<new()> with options.
This options would be handoff to the method C<set()>.

Without options

    my $lxs = Sys::Statistics::Linux->new();

Or with options

    my $lxs = Sys::Statistics::Linux->new( cpustats => 1 );

Would do nothing

    my $lxs = Sys::Statistics::Linux->new( cpustats => 0 );

It's possible to call C<new()> with a hash reference of options.

    my %options = (
        cpustats => 1,
        memstats => 1
    );

    my $lxs = Sys::Statistics::Linux->new(\%options);

=head2 set()

Call C<set()> to activate or deactivate options. The following example would call C<new()> and
C<init()> of C<Sys::Statistics::Linux::CpuStats> and delete the object of
C<Sys::Statistics::Linux::SysInfo>:

    $lxs->set(
        processes =>  0, # deactivate this statistic
        pgswstats =>  1, # activate the statistic and calls new() and init() if necessary
        netstats  =>  2, # activate the statistic and call new() if necessary but not init()
    );

It's possible to call C<set()> with a hash reference of options.

    my %options = (
        cpustats => 2,
        memstats => 2
    );

    $lxs->set(\%options);

=head2 get()

Call C<get()> to get the collected statistics. C<get()> returns a Sys::Statistics::Linux::Compilation object.

    my $stat = $lxs->get;

Now the statistcs are available with

    $stat->cpustats

    # or

    $stat->{cpustats}

Take a look to the documentation of C<Sys::Statistics::Linux::Compilation> for more informations.

=head2 init()

The call of init() initiate all activated statistics that are necessary for deltas. That could be helpful
if your script runs in a endless loop with a high sleep interval. Don't forget that if you call C<get()>
that the statistics are average values since the last time they were initiated.

The following example would calculate average statistics for 30 minutes:

    # initiate cpustats
    my $lxs = Sys::Statistics::Linux->new( cpustats => 1 );

    while ( 1 ) {
        sleep(1800);
        my $stat = $lxs->get;
    }

If you just want a current snapshot of the system each 30 minutes and not the average
the following example would be better for you:

    # don't initiate cpustats
    my $lxs = Sys::Statistics::Linux->new( cpustats => 2 );

    while ( 1 ) {
        sleep(1800);
        $lxs->init;
        sleep(1);
        my $stat = $lxs->get;
    }

=head2 settime()

Call C<settime()> to define a POSIX formatted time stamp, generated with localtime().

    $lxs->settime('%Y/%m/%d %H:%M:%S');

To get more informations about the formats take a look at C<strftime()> of POSIX.pm
or the manpage C<strftime(3)>.

=head2 gettime()

C<gettime()> returns a POSIX formatted time stamp, @foo in list and $bar in scalar context.
If the time format isn't set then the default format "%Y-%m-%d %H:%M:%S" will be set
automatically. You can also set a time format with C<gettime()>.

    my $date_time = $lxs->gettime;

Or

    my ($date, $time) = $lxs->gettime;

Or

    my ($date, $time) = $lxs->gettime('%Y/%m/%d %H:%M:%S');

=head1 EXAMPLES

A very simple perl script could looks like this:

    use strict;
    use warnings;
    use Sys::Statistics::Linux;

    my $lxs = Sys::Statistics::Linux->new( cpustats => 1 );
    sleep(1);
    my $stat = $lxs->get;
    my $cpu  = $stat->cpustats->{cpu};

    print "Statistics for CpuStats (all)\n";
    print "  user      $cpu->{user}\n";
    print "  nice      $cpu->{nice}\n";
    print "  system    $cpu->{system}\n";
    print "  idle      $cpu->{idle}\n";
    print "  ioWait    $cpu->{iowait}\n";
    print "  total     $cpu->{total}\n";

Set and get a time stamp:

    use strict;
    use warnings;
    use Sys::Statistics::Linux;

    my $lxs = Sys::Statistics::Linux->new();
    $lxs->settime('%Y/%m/%d %H:%M:%S');
    print "$lxs->gettime\n";

If you're not sure you can use the the C<Data::Dumper> module to learn more about the hash structure:

    use strict;
    use warnings;
    use Sys::Statistics::Linux;
    use Data::Dumper;

    my $lxs = Sys::Statistics::Linux->new( cpustats => 1 );
    sleep(1);
    my $stat = $lxs->get;

    print Dumper($stat);

How to get processes with the highest cpu workload:

    use strict;
    use warnings;
    use Sys::Statistics::Linux;

    my $lxs = Sys::Statistics::Linux->new( processes => 1 );
    sleep(1);
    my $stat = $lxs->get;
    my $proc = $stat->processes;

    my @top5 = (
       map  { $_->[0] }
       reverse sort { $a->[1] <=> $b->[1] }
       map  { [ $_, $procs->{$_}->{ttime} ] } keys %{$proc}
    )[0..4];

=head1 BACKWARD COMPATIBILITY

The old options and keys - CpuStats, NetStats, etc - are still available together but deprecated!
It's not possible to access the statistics via C<Sys::Statistics::Linux::Compilation> and it's
not possible to call C<search()> and C<psfind()> if you use the old options.

You should use the new options and access the statistics over the accessors

    $stats->cpustats

or direct

    $stats->{cpustats}

=head1 PREREQUISITES

    UNIVERSAL
    UNIVERSAL::require
    Test::More
    Carp

=head1 EXPORTS

No exports.

=head1 TODOS

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
our $VERSION = '0.26';

use strict;
use warnings;
use Carp qw(croak);
use POSIX qw(strftime);
use UNIVERSAL;
use UNIVERSAL::require;
use Sys::Statistics::Linux::Compilation;

sub new {
    my $class = shift;
    my @options = qw(
        SysInfo   CpuStats  ProcStats
        MemStats  PgSwStats NetStats
        SockStats DiskStats DiskUsage
        LoadAVG   FileStats Processes
    );
    my $self = bless { obj  => { }, mods => { } }, $class; 
    foreach my $opt (@options) {
        $self->{opts}->{$opt} = 0;
        $self->{maps}->{$opt} = $opt;
        my $lcopt = lc($opt);
        $self->{opts}->{$lcopt} = 0;
        $self->{maps}->{$lcopt} = $opt;
    }
    $self->set(@_) if @_;
    return $self;
}

sub set {
    my $self  = shift;
    my $class = ref $self;
    my $args  = ref($_[0]) eq 'HASH' ? shift : {@_};
    my $opts  = $self->{opts};
    my $obj   = $self->{obj};
    my $mods  = $self->{mods};
    my $maps  = $self->{maps};
    my $pids  = ();

    if (ref($args->{processes}) eq 'HASH') {
        $pids = $args->{processes}->{pids};
        $args->{processes} = $args->{processes}->{init};
    }

    foreach my $opt (keys %{$args}) {
        unless (exists $opts->{$opt}) {
            croak "$class: invalid option '$opt'";
        }
        unless ($args->{$opt} =~ qr/^[012]\z/) {
            croak "$class: invalid value for '$opt'";
        }

        $opts->{$opt} = $args->{$opt};

        if ($opts->{$opt}) {
            my $package = $class.'::'.$maps->{$opt};

            # require mod if not loaded
            unless ($mods->{$package}) {
                $package->require or croak "$class: unable to load $package";
                $mods->{$package} = 1;
            }

            # create a new object if the object doesn't exist
            # or create a new process list object if $pids is set
            if ($opt eq 'processes' && $pids) {
                $obj->{$opt} = $package->new($pids);
            } elsif (!$obj->{$opt}) {
                $obj->{$opt} = $package->new;
            }

            # get initial statistics if the function init() exists
            # and the option is set to 1
            if ($opts->{$opt} == 1 && UNIVERSAL::can($package, 'init')) {
                $obj->{$opt}->init();
            }

        } elsif (exists $obj->{$opt}) {
            delete $obj->{$opt};
        }
    }
}

sub init {
    my $self  = shift;
    my $class = ref $self;
    my $maps  = $self->{maps};
    foreach my $opt (keys %{$self->{opts}}) {
        if ($self->{opts}->{$opt} > 0 && UNIVERSAL::can(ref($self->{obj}->{$opt}), 'init')) {
            $self->{obj}->{$opt}->init();
        }
    }
}

sub get {
    my $self = shift;
    my %stat = ();
    foreach my $opt (keys %{$self->{opts}}) {
        if ($self->{opts}->{$opt}) {
            $stat{$opt} = $self->{obj}->{$opt}->get();
        }
    }
    return Sys::Statistics::Linux::Compilation->new(\%stat);
}

sub settime {
    my $self = shift;
    my $format = @_ ? shift : '%Y-%m-%d %H:%M:%S';
    $self->{timeformat} = $format;
}

sub gettime {
    my $self = shift;
    $self->settime(@_) unless $self->{timeformat};
    my $tm = strftime($self->{timeformat}, localtime);
    return wantarray ? split /\s+/, $tm : $tm;
}

1;
