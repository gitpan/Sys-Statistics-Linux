use strict;
use warnings;
use Test::More;
use Sys::Statistics::Linux;

if (-r "/proc/$$/stat") {
    plan tests => 1;
} else {
    plan skip_all => "your system doesn't provide process statistics - /proc/<pid> is not readable";
    exit(0);
}

my $sys = Sys::Statistics::Linux->new();
$sys->set(processes => 1);
sleep 1;
my $stat = $sys->get;
my $foo  = $stat->psfind({cmd => qr/\w/});
ok(@{$foo}, "checking psfind");
