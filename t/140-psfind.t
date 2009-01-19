use strict;
use warnings;
use Test::More tests => 1;
use Sys::Statistics::Linux;

my $lxs = Sys::Statistics::Linux->new;
$lxs->set(processes => 1);
sleep 1;
my $stat = $lxs->get;
my $foo  = $stat->psfind({cmd => qr/\w/});
ok(@{$foo}, "checking psfind");
