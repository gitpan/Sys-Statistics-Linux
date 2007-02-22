#!/usr/bin/perl
use warnings;
use strict;
use Sys::Statistics::Linux;

$|++;

use Sys::Statistics::Linux;

my $lxs = new Sys::Statistics::Linux;

$lxs->set(
#   SysInfo   => 1,
#   CpuStats  => 1,
#   ProcStats => 1,
#   MemStats  => 1,
#   PgSwStats => 1,
#   NetStats  => 1,
#   SockStats => 1,
#   DiskStats => 1,
#   DiskUsage => 1,
#   LoadAVG   => 1,
#   FileStats => 1,
   Processes => 1,
);

sleep 1;

my $stat = $lxs->get;

# lt
# gt
# ne
# qx

#$lxs->find({
find({
   Processes => { owner => qr/^root$/ },
   CpuStats  => { cpu => 'gt:80' },
});

sub find {
   #my $self   = shift;
   my $self   = $lxs;
   my $stat   = shift;
   #my $config = $self->_struct(@_);
   my $config = shift;

   return undef
      unless exists $self->{$stat};
}

=beispiel
sub find  {
   my ($self, $part, %config) = @_;
   return unless $part and keys %config > 0;
   return unless STATISTICS->{$part};

   my $return = {};
   my $stats = $self->get->{$part};

   for my $key(keys %config) {
      my $value = $config{$key};
      if(ref($value) eq 'Regexp') {
         for my $pid(keys %$stats) {
            if(exists $stats->{$pid}->{$key} and $stats->{$pid}->{$key} =~ $value) {
               $return->{$pid} = $stats->{$pid};
            }
         }
      } elsif(not ref($value)) {
      for my $pid(keys %$stats) {
         if(exists $stats->{$pid}->{$key} and $stats->{$pid}->{$key} eq $value) {
            $return->{$pid} = $stats->{$pid};
         } 
      }
   }

   return $return;
}
=cut
