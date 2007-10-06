use strict;
use warnings;
use Test::More tests => 1;
use Sys::Statistics::Linux;

my $lxs = Sys::Statistics::Linux->new;

$lxs->set( Processes => 1 );

sleep 1;

my $stat = $lxs->get();

my $foo = $lxs->psfind({cmd => qr/init/});

ok(@{$foo}, "checking psfind");
