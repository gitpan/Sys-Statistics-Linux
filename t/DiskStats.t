use strict;
use warnings;
use Test::More;
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

# I try to set this option in an eval box first because
# it could be that this test fails if the linux kernel
# version is <= 2.4 and if the kernel is not compiled with
# CONFIG_BLK_STATS=y
eval { $lxs->set(DiskStats => 1) };

if ($@) {
   if ($@ =~ /CONFIG_BLK_STATS/) {
      plan skip_all => "your system seems not to be compiled with CONFIG_BLK_STATS=y! DiskStats will not run on your system!";
   } else {
      plan tests => 1;
      fail("$@");
   }
} else {
   plan tests => 8;
   $lxs->set(DiskStats => 1);
   sleep(1);
   my $stats = $lxs->get;

   for my $dev (keys %{$stats->{DiskStats}}) {
      ok(defined $stats->{DiskStats}->{$dev}->{$_}, "checking DiskStats $_") for keys %DiskStats;
      last; # we check only one device, that should be enough
   }
}
