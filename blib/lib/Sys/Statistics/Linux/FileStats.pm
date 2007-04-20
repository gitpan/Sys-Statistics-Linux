=head1 NAME

Sys::Statistics::Linux::FileStats - Collect linux file statistics.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::FileStats;

   my $lxs   = new Sys::Statistics::Linux::FileStats;
   my $stats = $lxs->get;

=head1 DESCRIPTION

This module collects statistics by the virtual F</proc> filesystem (procfs) and is developed on default vanilla
kernels. It is tested on x86 hardware with the distributions SuSE (SuSE on s390 and s390x architecture as well),
Red Hat, Debian, Asianux, Slackware and Mandrake on kernel versions 2.4 and 2.6 and should run on all linux
kernels with a default vanilla kernel as well. It is possible that this module doesn't run on all distributions
if the procfs is too much changed.

Further it is necessary to run it as a user with the authorization to read the F</proc> filesystem.

=head1 FILE STATISTICS

Generated by F</proc/sys/fs/file-nr>, F</proc/sys/fs/inode-nr> and F</proc/sys/fs/dentry-state>.

   fhalloc    -  Number of allocated file handles.
   fhfree     -  Number of free file handles.
   fhmax      -  Number of maximum file handles.
   inalloc    -  Number of allocated inodes.
   infree     -  Number of free inodes.
   inmax      -  Number of maximum inodes.
   dentries   -  Dirty directory cache entries.
   unused     -  Free diretory cache size.
   agelimit   -  Time in seconds the dirty cache entries can be reclaimed.
   wantpages  -  Pages that are requested by the system when memory is short.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = new Sys::Statistics::Linux::FileStats;

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

package Sys::Statistics::Linux::FileStats;
our $VERSION = '0.03';

use strict;
use warnings;
use Carp qw(croak);

sub new {
   my $class = shift;
   my %self = (
      files => {
         file_nr    => '/proc/sys/fs/file-nr',
         inode_nr   => '/proc/sys/fs/inode-nr',
         dentries   => '/proc/sys/fs/dentry-state',
      }
   );
   return bless \%self, $class;
}

sub get {
   my $self  = shift;
   my $class = ref $self;
   my $file  = $self->{files};
   my %stats = ();

   {
      open my $fh, '<', $file->{file_nr} or croak "$class: unable to open $file->{file_nr} ($!)";
      @stats{qw(fhalloc fhfree fhmax)} = (split /\s+/, <$fh>)[0..2];
      close($fh);
   }

   {
      open my $fh, '<', $file->{inode_nr} or croak "$class: unable to open $file->{inode_nr} ($!)";
      @stats{qw(inalloc infree)} = (split /\s+/, <$fh>)[0..1];
      $stats{inmax} = $stats{inalloc} + $stats{infree};
      close($fh);
   }

   {
      open my $fh, '<', $file->{dentries} or croak "$class: unable to open $file->{dentries} ($!)";
      @stats{qw(dentries unused agelimit wantpages)} = (split /\s+/, <$fh>)[0..3];
      close($fh);
   }

   return \%stats;
}

1;