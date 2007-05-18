use strict;
use warnings;
use Test::More tests => 18;
use Sys::Statistics::Linux;

my %NetStats = (
   rxbyt => undef,
   rxpcks => undef,
   rxerrs => undef,
   rxdrop => undef,
   rxfifo => undef,
   rxframe => undef,
   rxcompr => undef,
   rxmulti => undef,
   txbyt => undef,
   txpcks => undef,
   txerrs => undef,
   txdrop => undef,
   txfifo => undef,
   txcolls => undef,
   txcarr => undef,
   txcompr => undef,
   ttpcks => undef,
   ttbyt => undef,
);

my $lxs = new Sys::Statistics::Linux;
$lxs->set(NetStats => 1);
sleep(1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->{NetStats}}) {
   ok(defined $stats->{NetStats}->{$dev}->{$_}, "checking NetStats $_") for keys %NetStats;
   last; # we check only one device, that should be enough
}
