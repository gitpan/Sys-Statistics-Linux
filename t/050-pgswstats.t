use strict;
use warnings;
use Test::More;
use Sys::Statistics::Linux;

my @pgswstats = qw(
   pgpgin
   pgpgout
   pswpin
   pswpout
);

my $sys = Sys::Statistics::Linux->new();

if (!-r '/proc/diskstats' || !-r '/proc/partitions') {
    plan skip_all => "your system seems to be a virtual machine that doesn't provide all statistics";
    exit(0);
}

plan tests => 4;

$sys->set(pgswstats => 1);
sleep(1);
my $stats = $sys->get;
ok(defined $stats->pgswstats->{$_}, "checking pgswstats $_") for @pgswstats;
