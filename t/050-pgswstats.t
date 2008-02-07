use strict;
use warnings;
use Test::More tests => 4;
use Sys::Statistics::Linux;

my @pgswstats = qw(
   pgpgin
   pgpgout
   pswpin
   pswpout
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(pgswstats => 1);
sleep(1);
my $stats = $lxs->get;
ok(defined $stats->pgswstats->{$_}, "checking pgswstats $_") for @pgswstats;
