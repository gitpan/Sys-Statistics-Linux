=head1 NAME

Sys::Statistics::Linux::LoadAVG - Collect linux load average statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::LoadAVG;

   my $lxs   = new Sys::Statistics::Linux::LoadAVG;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects statistics by the virtual F</proc> filesystem (procfs) and is developed on default vanilla
kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390 and s390x architecture as well),
Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions 2.4 and 2.6 and should run on all linux
kernels with a default vanilla kernel as well. It is possible that this module doesn't run on all distributions
if the procfs is too much changed.

Further it is necessary to run it as a user with the authorization to read the F</proc> filesystem.

=head1 LOAD AVERAGE STATISTICS

Generated by F</proc/loadavg>.

   avg_1   -  The average processor workload of the last minute.
   avg_5   -  The average processor workload of the last five minutes.
   avg_15  -  The average processor workload of the last fifteen minutes.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = new Sys::Statistics::Linux::LoadAVG;

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

package Sys::Statistics::Linux::LoadAVG;
our $VERSION = '0.02';

use strict;
use warnings;
use IO::File;
use Carp qw(croak);

sub new {
   return bless {
      files => {
         loadavg => '/proc/loadavg',
      },
      stats => {},
   }, shift;
}

sub get {
   my $self  = shift;
   $self->{stats} = $self->_load;
   return $self->{stats};
}

#
# private stuff
#

sub _load {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my $fh    = new IO::File;
   my %lavg;

   $fh->open($file->{loadavg}, 'r') or croak "$class: unable to open $file->{loadavg} ($!)";

   ( $lavg{avg_1}
   , $lavg{avg_5}
   , $lavg{avg_15}
   ) = (split /\s+/, <$fh>)[0..2];

   $fh->close;
   return \%lavg;
}

1;
