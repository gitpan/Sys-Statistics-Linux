=head1 NAME

Sys::Statistics::Linux::DiskUsage - Collect linux disk usage.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::DiskUsage;

   my $lxs   = new Sys::Statistics::Linux::DiskUsage;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects disk usage statistics by the command C</bin/df -k>and is developed on default vanilla
kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390 and s390x architecture as well),
Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions 2.4 and 2.6 and should run on all linux
kernels with a default vanilla kernel as well. It is possible that this module doesn't run on all distributions
if the output of C</bin/df -k> is too much changed.

Further it is necessary to run it as a user with the authorization to execute the C</bin/df> command.

=head1 DISK USAGE INFORMATIONS

Generated by F</bin/df -k>.

   total       -  The total size of the disk.
   usage       -  The used disk space in kilobytes.
   free        -  The free disk space in kilobytes.
   usageper    -  The used disk space in percent.
   mountpoint  -  The moint point of the disk.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = new Sys::Statistics::Linux::DiskUsage;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

   my $stats = $lxs->get;

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
our $VERSION = '0.03';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      files => {
         df => '/bin/df -k',
      }
   );
   return bless \%self, $class;
}

sub get {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my (%disk_usage, $disk_name);

   open my $fh, "$file->{df}|" or croak "$class: unable to execute $file->{df} ($!)";

   # filter the header
   {my $null = <$fh>;}

   while (my $line = <$fh>) {
      $line =~ s/%//g;

      if ($line =~ /^(.+?)\s+(.+)$/ && !$disk_name) {
         @{$disk_usage{$1}}{qw(total usage free usageper mountpoint)} = (split /\s+/, $2)[0..4];
      } elsif ($line =~ /^(.+?)\s*$/ && !$disk_name) {
         # it can be that the disk name is to long and the rest
         # of the disk informations are in the next line ...
         $disk_name = $1;
      } elsif ($line =~ /^\s+(.*)$/ && $disk_name) {
         # this line should contain the rest informations for the
         # disk name that we stored in the last loop
         @{$disk_usage{$disk_name}}{qw(total usage free usageper mountpoint)} = (split /\s+/, $1)[0..4];
         undef $disk_name;
      } else {
         # okay, it should never be the issue that we get a
         # line that we couldn't split, but for sure we undef
         # the disk_name if it's set
         undef $disk_name if $disk_name;
      }
   }

   close($fh);
   return \%disk_usage;
}

1;
