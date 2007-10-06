use strict;
use warnings;
use Test::More tests => 3;
use Sys::Statistics::Linux;

my %LoadAVG = (
   avg_1 => undef,
   avg_5 => undef,
   avg_15 => undef,
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(LoadAVG => 1);
my $stats = $lxs->get;
ok(defined $stats->{LoadAVG}->{$_}, "checking LoadAVG $_") for keys %LoadAVG;
