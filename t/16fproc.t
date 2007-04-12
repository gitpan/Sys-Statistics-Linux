use strict;
use warnings;
use Test::More tests => 1;
use Sys::Statistics::Linux;

my $lxs = new Sys::Statistics::Linux;

$lxs->set( Processes => 1 );

sleep 1;

my $stat = $lxs->get();

my $foo = $lxs->fproc({cmd => qr/init/});

ok(@{$foo}, "checking fproc");
