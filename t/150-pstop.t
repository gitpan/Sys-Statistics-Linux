use strict;
use warnings;
use Test::More tests => 1;
use Sys::Statistics::Linux;

my $sys = Sys::Statistics::Linux->new();
$sys->set(processes => 1);
sleep 1;
my $stat  = $sys->get;
my @top   = $stat->pstop( ttime => 5 );
my $count = scalar keys %{ $stat->{processes} };

# maybe the user has no rights to read /proc/<pid>
if ($count > 5) {
    $count = 5;
}

ok(@top == $count, "checking psfind");
