use strict;
use warnings;
use Test::More tests => 33;
use Sys::Statistics::Linux;

my %Processes = (
   ppid => undef,
   nlwp => undef,
   owner => undef,
   pgrp => undef,
   state => undef,
   session => undef,
   ttynr => undef,
   minflt => undef,
   cminflt => undef,
   mayflt => undef,
   cmayflt => undef,
   stime => undef,
   utime => undef,
   ttime => undef,
   cstime => undef,
   cutime => undef,
   prior => undef,
   nice => undef,
   sttime => undef,
   actime => undef,
   vsize => undef,
   nswap => undef,
   cnswap => undef,
   cpu => undef,
   size => undef,
   resident => undef,
   share => undef,
   trs => undef,
   drs => undef,
   lrs => undef,
   dtp => undef,
   cmd => undef,
   cmdline => undef,
);

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(Processes => 1);
sleep(1);
my $stats = $lxs->get;

for my $dev (keys %{$stats->{Processes}}) {
   ok(defined $stats->{Processes}->{$dev}->{$_}, "checking Processes $_") for keys %Processes;
   last; # we check only one process, that should be enough
}
