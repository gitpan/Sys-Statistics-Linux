use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux;

my @diskusage = qw(
    total
    usage
    free
    usageper
    mountpoint
);

my $sys = Sys::Statistics::Linux->new();
$sys->set(diskusage => 1);
my $stats = $sys->get;

for my $dev (keys %{$stats->diskusage}) {
   ok(defined $stats->diskusage->{$dev}->{$_}, "checking diskusage $_") for @diskusage;
   last; # we check only one device, that should be enough
}
