use strict;
use warnings;
use Test::More tests => 10;
use Sys::Statistics::Linux;

my %FileStats = (
   fhalloc => undef,
   fhfree => undef,
   fhmax => undef,
   inalloc => undef,
   infree => undef,
   inmax => undef,
   dentries => undef,
   unused => undef,
   agelimit => undef,
   wantpages => undef,
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(FileStats => 1);
my $stats = $lxs->get;

ok(defined $stats->{FileStats}->{$_}, "checking FileStats $_") for keys %FileStats;
