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

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(diskusage => 1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->diskusage}) {
   ok(defined $stats->diskusage->{$dev}->{$_}, "checking diskusage $_") for @diskusage;
   last; # we check only one device, that should be enough
}
