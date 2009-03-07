use strict;
use warnings;
use Test::More tests => 10;
use Sys::Statistics::Linux;

my @filestats = qw(
   fhalloc
   fhfree
   fhmax
   inalloc
   infree
   inmax
   dentries
   unused
   agelimit
   wantpages
);

my $sys = Sys::Statistics::Linux->new();
$sys->set(filestats => 1);
my $stats = $sys->get;
ok(defined $stats->filestats->{$_}, "checking filestats $_") for @filestats;
