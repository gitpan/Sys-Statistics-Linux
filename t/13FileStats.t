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

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(filestats => 1);
my $stats = $lxs->get;
ok(defined $stats->filestats->{$_}, "checking filestats $_") for @filestats;
