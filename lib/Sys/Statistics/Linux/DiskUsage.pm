=head1 NAME

Sys::Statistics::Linux::DiskUsage - Collect linux disk usage.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::DiskUsage;

   my $lxs  = new Sys::Statistics::Linux::DiskUsage;
   my $stat = $lxs->get;

=head1 DESCRIPTION

Sys::Statistics::Linux::DiskUsage gathers the disk usage with the command C<df>.

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 DISK USAGE INFORMATIONS

Generated by F</bin/df -kP>.

   total       -  The total size of the disk.
   usage       -  The used disk space in kilobytes.
   free        -  The free disk space in kilobytes.
   usageper    -  The used disk space in percent.
   mountpoint  -  The moint point of the disk.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = Sys::Statistics::Linux::DiskUsage->new;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

   my $stat = $lxs->get;

=head1 EXPORTS

No exports.

=head1 SEE ALSO

B<df(1)>

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

package Sys::Statistics::Linux::DiskUsage;
our $VERSION = '0.06';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      cmd => {
         path => '/bin',
         df => 'df -kP',
      }
   );
   return bless \%self, $class;
}

sub get {
   my $self  = shift;
   my $class = ref $self;
   my $cmd   = $self->{cmd};
   my (%disk_usage, $disk_name);

   local $ENV{PATH} = $cmd->{path};
   open my $fh, "$cmd->{df}|" or croak "$class: unable to execute '$cmd->{df}' ($!)";

   # filter the header
   {my $null = <$fh>;}

   while (my $line = <$fh>) {
      next unless $line =~ /^(.+?)\s+(.+)$/ && !$disk_name;
      @{$disk_usage{$1}}{qw(
         total
         usage
         free
         usageper
         mountpoint
      )} = (split /\s+/, $2)[0..4];
      $disk_usage{$1}{usageper} =~ s/%//;
   }

   close($fh);
   return \%disk_usage;
}

1;
