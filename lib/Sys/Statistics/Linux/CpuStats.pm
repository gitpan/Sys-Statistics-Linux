=head1 NAME

Sys::Statistics::Linux::CpuStats - Collect linux cpu statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::CpuStats;

   my $lxs = new Sys::Statistics::Linux::CpuStats;
   $lxs->init;
   sleep 1;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects statistics by the virtual F</proc> filesystem (procfs) and is developed on default vanilla
kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390 and s390x architecture as well),
Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions 2.4 and 2.6 and should run on all linux
kernels with a default vanilla kernel as well. It is possible that this module doesn't run on all distributions
if the procfs is too much changed.

Further it is necessary to run it as a user with the authorization to read the F</proc> filesystem.

=head1 DELTAS

It's necessary to initialize the statistics by calling C<init()>, because the statistics are deltas between
the call of C<init()> and C<get()>. By calling C<get()> the deltas be generated and the initial values will
be updated automatically. This way making it possible that the call of C<init()> is only necessary
after the call of C<new()>. Further it's recommended to sleep for a while - at least one second - between
the call of C<init()> and/or C<get()> if you want to get useful statistics.

=head1 CPU STATISTICS

Generated by F</proc/stat> for each cpu (cpu0, cpu1 ...). F<cpu> without a number is the summary.

   user    -  Percentage of CPU utilization at the user level.
   nice    -  Percentage of CPU utilization at the user level with nice priority.
   system  -  Percentage of CPU utilization at the system level.
   idle    -  Percentage of time the CPU is in idle state.
   iowait  -  Percentage of time the CPU is in idle state because an i/o operation is waiting for a disk.
              This statistic is only available by kernel versions higher than 2.4. Otherwise this statistic
              exists but will be ever 0.
   total   -  Total percentage of CPU utilization (user + nice + system).

=head1 METHODS

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

package Sys::Statistics::Linux::CpuStats;
our $VERSION = '0.07';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      files => {
         stat => '/proc/stat',
      }
   );
   return bless \%self, $class;
}

sub init {
   my $self = shift;
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
   my (%stats, $iowait, $irq, $softirq);

   open my $fh, '<', $file->{stat} or croak "$class: unable to open $file->{stat} ($!)";

   while (my $line = <$fh>) {
      if ($line =~ /^(cpu.*?)\s+(.*)$/) {
         my $cpu = \%{$stats{$1}};
         (@{$cpu}{qw(user nice system idle)}, $iowait, $irq, $softirq) = split /\s+/, $2;
         # iowait, irq and softirq are only set 
         # by kernel versions higher than 2.4
         $cpu->{iowait}  = $iowait  || 0;
         $cpu->{irq}     = $irq     if defined $irq;
         $cpu->{softirq} = $softirq if defined $softirq;
      }
   }

   close($fh);
   return \%stats;
}

sub _deltas {
   my $self  = shift;
   my $class = ref $self;
   my $istat = $self->{init};
   my $lstat = $self->{stats};

   foreach my $cpu (keys %{$lstat}) {
      my $icpu = $istat->{$cpu};
      my $dcpu = $lstat->{$cpu};
      my $uptime;

      while (my ($k, $v) = each %{$dcpu}) {
         croak "$class: different keys in statistics"
            unless defined $icpu->{$k};
         croak "$class: value of '$k' is not a number"
            unless $v =~ /^\d+$/ && $dcpu->{$k} =~ /^\d+$/;
         $dcpu->{$k} -= $icpu->{$k};
         $icpu->{$k}  = $v;
         $uptime += $dcpu->{$k};
      }

      foreach my $k (keys %{$dcpu}) {
         if ($dcpu->{$k} > 0) {
            $dcpu->{$k} = sprintf('%.2f', 100 * $dcpu->{$k} / $uptime);
         } else {
            $dcpu->{$k} = sprintf('%.2f', $dcpu->{$k});
         }
      }

      $dcpu->{total} = sprintf('%.2f', $dcpu->{user} + $dcpu->{nice} + $dcpu->{system});
      delete $dcpu->{irq}     if exists $dcpu->{irq};
      delete $dcpu->{softirq} if exists $dcpu->{softirq};
   }
}

1;
