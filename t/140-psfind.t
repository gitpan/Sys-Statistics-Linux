use strict;
use warnings;
use Test::More tests => 1;
use Sys::Statistics::Linux;

my $sys = Sys::Statistics::Linux->new();
$sys->set(processes => 1);
sleep 1;
my $stat = $sys->get;
my $foo  = $stat->psfind({cmd => qr/\w/});
ok(@{$foo}, "checking psfind");
