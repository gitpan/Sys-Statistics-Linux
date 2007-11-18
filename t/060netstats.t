use strict;
use warnings;
use Test::More tests => 18;
use Sys::Statistics::Linux;

my @netstats = qw(
   rxbyt
   rxpcks
   rxerrs
   rxdrop
   rxfifo
   rxframe
   rxcompr
   rxmulti
   txbyt
   txpcks
   txerrs
   txdrop
   txfifo
   txcolls
   txcarr
   txcompr
   ttpcks
   ttbyt
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(netstats => 1);
sleep(1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->netstats}) {
   ok(defined $stats->netstats->{$dev}->{$_}, "checking netstats $_") for @netstats;
   last; # we check only one device, that should be enough
}
