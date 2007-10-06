use strict;
use warnings;
use Test::More tests => 11;
use Sys::Statistics::Linux;
use Data::Dumper;

my $lxs = Sys::Statistics::Linux->new;

$lxs->set(
   CpuStats  => 1,
   ProcStats => 1,
   MemStats  => 1,
   DiskUsage => 1,
   Processes => 1,
);

sleep 1;

my $stat = $lxs->get();

# just some simple searches that should match every time
my $foo = $lxs->search({
   CpuStats  => { total => 'lt:101' },
   ProcStats => { count => 'ne:1' },
   MemStats  => { memtotal => 'gt:1' },
   DiskUsage => { usageper => qr/\d+/ },
   Processes => { 1 => { ppid => 'eq:0' } },
});

ok(defined %{$foo->{$_}}, "checking $_") for keys %{$foo};

my %filter = (
    CpuStats => {
        system => 'lt:52',
        total  => 'gt:50',
        idle   => qr/^49\.00\z/,
        nice   => 'ne:1',
        user   => 'eq:0.00',
        iowait => 'gt:0.01',
    }
);

my %stats = (
    CpuStats => {
        cpu => {
            system => '51.00',
            total  => '51.00',
            idle   => '49.00',
            nice   => '0.00',
            user   => '0.00',
            iowait => '1.00'
        }
    }
);
 
my $hits = $lxs->search(\%filter, \%stats);

ok($hits->{CpuStats}->{cpu}->{system} == $stats{CpuStats}{cpu}{system}, "checking system");
ok($hits->{CpuStats}->{cpu}->{total}  == $stats{CpuStats}{cpu}{total},  "checking total");
ok($hits->{CpuStats}->{cpu}->{idle}   == $stats{CpuStats}{cpu}{idle},   "checking idle");
ok($hits->{CpuStats}->{cpu}->{nice}   == $stats{CpuStats}{cpu}{nice},   "checking nice");
ok($hits->{CpuStats}->{cpu}->{user}   == $stats{CpuStats}{cpu}{user},   "checking user");
ok($hits->{CpuStats}->{cpu}->{iowait} == $stats{CpuStats}{cpu}{iowait}, "checking iowait");
