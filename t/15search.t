use strict;
use warnings;
use Test::More tests => 4;
use Sys::Statistics::Linux;

my $lxs = new Sys::Statistics::Linux;

$lxs->set(
   CpuStats  => 1,
   MemStats  => 1,
   DiskUsage => 1,
   Processes => 1,
);

sleep 1;

my $stat = $lxs->get();

my $foo = $lxs->search({
   CpuStats  => { total => 'lt:101' },
   MemStats  => { memtotal => 'gt:1' },
   DiskUsage => { usageper => qr/\d+/ },
   Processes => { 1 => { ppid => 'eq:0' } },
});

ok(defined %{$foo->{$_}}, "checking $_") for keys %{$foo};
