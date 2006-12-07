use strict;
use warnings;
use Test::More tests => 8;
use Sys::Statistics::Linux;

my %DiskStats = (
   major => undef,
   minor => undef,
   rdreq => undef,
   rdbyt => undef,
   wrtreq => undef,
   wrtbyt => undef,
   ttreq => undef,
   ttbyt => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(DiskStats => 1);
sleep(1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->{DiskStats}}) {
   ok(defined $stats->{DiskStats}->{$dev}->{$_}, "checking DiskStats $_") for keys %DiskStats;
   last; # we check only one device, that should be enough
}
