=head1 NAME

Sys::Statistics::Linux::Processes - Collect linux process statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::Processes;

   my $lxs = new Sys::Statistics::Linux::Processes;
   $lxs->init;
   sleep 1;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects process statistics from the F</proc> filesystem. It is tested on x86 hardware
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

=head1 PROCESS STATISTICS

Generated by F</proc/E<lt>numberE<gt>/statm>, F</proc/E<lt>numberE<gt>/stat>,
F</proc/E<lt>numberE<gt>/status>, F</proc/E<lt>numberE<gt>/cmdline> and F<getpwuid()>.

Note that if F</etc/passwd> isn't readable, the key owner is set to F<N/a>.

   pid       -  The process ID.
   ppid      -  The parent process ID of the process.
   owner     -  The owner name of the process.
   pgrp      -  The group ID of the process.
   state     -  The status of the process.
   session   -  The session ID of the process.
   ttynr     -  The tty the process use.
   minflt    -  The number of minor faults the process made.
   cminflt   -  The number of minor faults the child process made.
   mayflt    -  The number of mayor faults the process made.
   cmayflt   -  The number of mayor faults the child process made.
   stime     -  The number of jiffies the process have beed scheduled in kernel mode.
   utime     -  The number of jiffies the process have beed scheduled in user mode.
   cstime    -  The number of jiffies the process waited for childrens have been scheduled in kernel mode.
   cutime    -  The number of jiffies the process waited for childrens have been scheduled in user mode.
   prior     -  The priority of the process (+15).
   nice      -  The nice level of the process.
   sttime    -  The time in jiffies the process started after system boot.
   actime    -  The time in D:H:M (days, hours, minutes) the process is active.
   vsize     -  The size of virtual memory of the process.
   nswap     -  The size of swap space of the process.
   cnswap    -  The size of swap space of the childrens of the process.
   cpu       -  The CPU number the process was last executed on.
   size      -  The total program size of the process.
   resident  -  Number of resident set size, this includes the text, data and stack space.
   share     -  Total size of shared pages of the process.
   trs       -  Total text size of the process.
   drs       -  Total data/stack size of the process.
   lrs       -  Total library size of the process.
   dtp       -  Total size of dirty pages of the process (unused since kernel 2.6).
   cmd       -  Command of the process.
   cmdline   -  Command line of the process.

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

B<perldoc -f getpwuid>

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::Processes;
our $VERSION = '0.01';

use strict;
use warnings;
use IO::File;
use Carp qw(croak);

sub new {
   return bless {
      files => {
         basedir   => '/proc',
         uptime    => '/proc/uptime',
         p_stat    => 'stat',
         p_statm   => 'statm',
         p_status  => 'status',
         p_cmdline => 'cmdline',
      },
      init  => {},
      stats => {},
   }, shift;
}

sub init {
   my $self = shift;
   $self->{init} = $self->_init;
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

sub _init {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my $fh    = new IO::File;
   my %stats;

   $stats{uptime} = $self->_uptime;

   opendir my $pdir, $file->{basedir}
      or croak "$class: unable to open directory $file->{basedir}";

   foreach my $pid ( grep /^\d+$/, readdir $pdir ) {
      if ($fh->open("$file->{basedir}/$pid/$file->{p_stat}", 'r')) {
         @{$stats{$pid}}{qw(
            minflt cminflt mayflt cmayflt utime
            stime cutime cstime sttime
         )} = (split /\s+/, <$fh>)[9..16,21];
         $fh->close;
      } else {
         delete $stats{$pid};
         next;
      }
   }

   closedir $pdir;
   return \%stats;
}

sub _load {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my $fh    = new IO::File;
   my (%stats, %userids);

   $stats{uptime} = $self->_uptime;

   # we get all the PIDs from the /proc filesystem. if we are unable to open a file
   # of a process, then it can be that the process doesn't exist any more and
   # we will delete the hash key.
   opendir my $pdir, $file->{basedir} or croak "$class: unable to open directory $file->{basedir} ($!)";

   foreach my $pid (grep /^\d+$/, readdir $pdir) {

      #  memory usage for each process
      if ($fh->open("$file->{basedir}/$pid/$file->{p_statm}", 'r')) {
         @{$stats{$pid}}{qw(size resident share trs drs lrs dtp)} = split /\s+/, <$fh>;
         $fh->close;
      } else {
         delete $stats{$pid};
         next;
      }

      #  different other informations for each process
      if ($fh->open("$file->{basedir}/$pid/$file->{p_stat}", 'r')) {
         @{$stats{$pid}}{qw(
            pid cmd state ppid pgrp session ttynr minflt
            cminflt mayflt cmayflt utime stime cutime cstime
            prior nice sttime vsize nswap cnswap cpu
         )} = (split /\s+/, <$fh>)[0..6,9..18,21..22,35..36,38];
         $fh->close;
      } else {
         delete $stats{$pid};
         next;
      }

      # calculate the active time of each process
      my ($d, $h, $m, $s) = $class->_calsec(sprintf('%li', $stats{uptime} - $stats{$pid}{sttime} / 100));
      $stats{$pid}{actime} = "$d:".sprintf('%02d:%02d:%02d', $h, $m, $s);

      # determine the owner of the process
      if ($fh->open("$file->{basedir}/$pid/$file->{p_status}", 'r')) {
         while (my $line = <$fh>) {
            next unless $line =~ /^Uid:(\s+|\t+)(\d+)/;
            $stats{$pid}{owner} = getpwuid($2) || 'N/a';
            last;
         }
         $fh->close;
      } else {
         delete $stats{$pid};
         next;
      }

      #  command line for each process
      if ($fh->open("$file->{basedir}/$pid/$file->{p_cmdline}", 'r')) {
         $stats{$pid}{cmdline} =  <$fh>;
         $stats{$pid}{cmdline} =~ s/\0/ /g if $stats{$pid}{cmdline};
         $stats{$pid}{cmdline} =  'N/a' unless $stats{$pid}{cmdline};
         chomp $stats{$pid}{cmdline};
         $fh->close;
      }
   }

   closedir $pdir;
   return \%stats;
}

sub _deltas {
   my $self  = shift;
   my $class = ref $self;
   my $istat = $self->{init};
   my $lstat = $self->{stats};

   croak "$class: missing key 'uptime'"
      unless $istat->{uptime} && $lstat->{uptime};
   croak "$class: value of 'uptime' is not a number"
      unless $istat->{uptime} =~ /^\d+(\.\d+|)$/ && $lstat->{uptime} =~ /^\d+(\.\d+|)$/;

   my $uptime = $istat->{uptime} - $lstat->{uptime};
   $istat->{uptime} = $lstat->{uptime};
   delete $lstat->{uptime};

   for my $pid (keys %{$lstat}) {
      my $ipid = $istat->{$pid};
      my $lpid = $lstat->{$pid};

      # if the process doesn't exist it seems to be a new process
      if ($ipid->{sttime} && $ipid->{sttime} == $lpid->{sttime}) {
         for my $k (qw(minflt cminflt mayflt cmayflt utime stime cutime cstime)) {
            croak "$class: different keys in statistics"
               unless defined $ipid->{$k};
            croak "$class: value of '$k' is not a number"
               unless $ipid->{$k} =~ /^\d+(\.\d+|)$/ && $lpid->{$k} =~ /^\d+(\.\d+|)$/;

            # we held this value for the next init stat
            my $tmp      = $lpid->{$k};
            $lpid->{$k} -= $ipid->{$k};
            $lpid->{$k}  = sprintf('%.2f', $lpid->{$k} / $uptime) if $lpid->{$k} > 0 && $uptime > 0;
            $ipid->{$k}  = $tmp;
         }
      } else {
         # we initialize the new process
         for my $k (qw(minflt cminflt mayflt cmayflt utime stime cutime cstime sttime)) {
            $ipid->{$k} = $lpid->{$k};
            delete $lstat->{$pid};
         }
      }
   }
}

sub _uptime {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my $fh    = new IO::File;
   $fh->open($file->{uptime}, 'r') or croak "$class: unable to open $file->{uptime} ($!)";
   my ($up, $idle) = split /\s+/, <$fh>;
   return ($up, $idle);
}

sub _calsec {
   my $class = shift;
   my ($s, $m, $h, $d) = (shift, 0, 0, 0);
   $s >= 86400 and $d = sprintf('%i', $s / 86400) and $s = $s % 86400;
   $s >= 3600  and $h = sprintf('%i', $s / 3600)  and $s = $s % 3600;
   $s >= 60    and $m = sprintf('%i', $s / 60)    and $s = $s % 60;
   return ($d, $h, $m, $s);
}

1;
