use strict;
use warnings;
use Test::More tests => 4;
use Sys::Statistics::Linux;

my @cpuinfo = qw(
    model_name
    cpu_mhz
    cache_size
    bogomips
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(cpuinfo => 1);
my $stats = $lxs->get;

foreach my $cpu ($stats->cpuinfo) {
    ok(defined $stats->cpuinfo->{$cpu}->{$_}, "checking cpuinfo $_") for @cpuinfo;
    last;
}
