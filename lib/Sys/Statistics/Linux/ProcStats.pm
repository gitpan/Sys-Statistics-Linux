=head1 NAME

Sys::Statistics::Linux::ProcStats - Collect linux load average statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::ProcStats;

   my $lxs  = Sys::Statistics::Linux::ProcStats->new;
   my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::ProcStats gathers process statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 LOAD AVERAGE STATISTICS

Generated by F</proc/stat> and F</proc/loadavg>.

   new       -  Number of new processes that were produced per second.
   runqueue  -  The number of processes waiting for runtime.
   count     -  The total amount of processes on the system.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = Sys::Statistics::Linux::ProcStats->new;

=head2 init()

Call C<init()> to initialize the statistics.

   $lxs->init;

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

package Sys::Statistics::Linux::ProcStats;
our $VERSION = '0.10';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      files => {
         loadavg => '/proc/loadavg',
         stat => '/proc/stat',
         uptime => '/proc/uptime',
      }
   );
   return bless \%self, $class;
}

sub init {
   my $self = shift;
   $self->{uptime} = $self->_uptime;
   $self->{init}->{new} = $self->_newproc;
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
   my %lavg  = ();

   open my $fh, '<', $file->{loadavg} or croak "$class: unable to open $file->{loadavg} ($!)";

   ( $lavg{runqueue}
   , $lavg{count}
   ) = (split m@/@, (split /\s+/, <$fh>)[3]);

   close($fh);

   $lavg{new} = $self->_newproc;

   return \%lavg;
}

sub _newproc {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my $stat  = ();

   open my $fh, '<', $file->{stat} or croak "$class: unable to open $file->{stat} ($!)";

   while (my $line = <$fh>) {
      if ($line =~ /^processes\s+(\d+)/) {
         $stat = $1;
         last;
      }
   }

   close($fh);
   return $stat;
}

sub _deltas {
   my $self   = shift;
   my $class  = ref $self;
   my $istat  = $self->{init};
   my $lstat  = $self->{stats};
   my $uptime = $self->_uptime;
   my $delta  = sprintf('%.2f', $uptime - $self->{uptime});
   $self->{uptime} = $uptime;

   croak "$class: different keys in statistics"
      unless defined $istat->{new} && defined $lstat->{new};
   croak "$class: value of 'new' is not a number"
      unless $istat->{new} =~ /^\d+$/ && $lstat->{new} =~ /^\d+$/;

   my $new_init = $lstat->{new};

   $lstat->{new} =
      $lstat->{new} == $istat->{new}
         ? sprintf('%.2f', 0)
         : $delta > 0
            ? sprintf('%.2f', ($new_init - $istat->{new}) / $delta )
            : sprintf('%.2f', $new_init - $istat->{new});

   $istat->{new} = $new_init;
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
