use strict;
use warnings;
use Test::More tests => 6;
use Sys::Statistics::Linux;

my @cpustats = qw(
   user
   nice
   system
   idle
   iowait
   total
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(cpustats => 1);
sleep(1);
my $stats = $lxs->get;
ok(defined $stats->cpustats->{cpu}->{$_}, "checking cpustats $_") for @cpustats;
