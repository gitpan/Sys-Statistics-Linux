use strict;
use warnings;
use Module::Build;

die 'OS unsupported! Sorry, but this system seems not to be a linux system!'
   unless $^O =~ /linux/i;

die 'OS unsupported! Stupid! RTFM and let me access /proc!'
   unless -r '/proc';

my $build = Module::Build->new(
    create_readme => 1,
    license       => 'perl',
    module_name   => 'Sys::Statistics::Linux',
    dist_author   => 'Jonny Schulz',
    recommends    => { },
    sign          => 0,
    requires      => {
        'UNIVERSAL::require' => 0,
        'UNIVERSAL'          => 0,
        'Test::More'         => 0,
        'Carp'               => 0,
        'POSIX'              => 0,
        'Time::HiRes'        => 0,
    },
);

$build->create_build_script;
