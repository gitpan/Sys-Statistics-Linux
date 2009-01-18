use strict;
use warnings;
use Test::More tests => 11;
use Sys::Statistics::Linux;
use Data::Dumper;

my $lxs = Sys::Statistics::Linux->new;

$lxs->set(
   cpustats  => 1,
   procstats => 1,
   memstats  => 1,
   diskusage => 1,
   processes => 1,
);

sleep 1;

my $stat = $lxs->get();

# just some simple searches that should match every time
my $foo = $stat->search({
   cpustats  => { total => 'lt:101' },
   procstats => { count => 'ne:1' },
   memstats  => { memtotal => 'gt:1' },
   diskusage => { usageper => qr/\d+/ },
   processes => { 1 => { ppid => 'eq:0' } },
});

foreach my $key (qw/cpustats procstats memstats diskusage processes/) {
    ok(exists $foo->{$key} && ref($foo->{$key}) eq 'HASH', "checking $key");
}

my %filter = (
    cpustats => {
        system => 'lt:52',
        total  => 'gt:50',
        idle   => qr/^49\.00\z/,
        nice   => 'ne:1',
        user   => 'eq:0.00',
        iowait => 'gt:0.01',
    }
);

my %stats = (
    cpustats => {
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

my $comp = Sys::Statistics::Linux::Compilation->new(\%stats);
my $hits = $comp->search(\%filter);

ok($hits->{cpustats}->{cpu}->{system} == $stats{cpustats}{cpu}{system}, "checking system");
ok($hits->{cpustats}->{cpu}->{total}  == $stats{cpustats}{cpu}{total},  "checking total");
ok($hits->{cpustats}->{cpu}->{idle}   == $stats{cpustats}{cpu}{idle},   "checking idle");
ok($hits->{cpustats}->{cpu}->{nice}   == $stats{cpustats}{cpu}{nice},   "checking nice");
ok($hits->{cpustats}->{cpu}->{user}   == $stats{cpustats}{cpu}{user},   "checking user");
ok($hits->{cpustats}->{cpu}->{iowait} == $stats{cpustats}{cpu}{iowait}, "checking iowait");
