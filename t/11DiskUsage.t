use strict;
use warnings;
use Test::More tests => 5;
use Sys::Statistics::Linux;

my %DiskUsage = (
   total => undef,
   usage => undef,
   free => undef,
   usageper => undef,
   mountpoint => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(DiskUsage => 1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->{DiskUsage}}) {
   ok(defined $stats->{DiskUsage}->{$dev}->{$_}, "checking DiskUsage $_") for keys %DiskUsage;
   last; # we check only one device, that should be enough
}
