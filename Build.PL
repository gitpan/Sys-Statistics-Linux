use strict;
use warnings;
use Module::Build;

die 'OS unsupported! Sorry, but this system seems not to be a linux system!'
   unless $^O =~ /linux/i;

my $build = Module::Build->new(
    create_readme      => 1,
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Sys::Statistics::Linux',
    dist_author        => 'Jonny Schulz',
    requires => {
        'UNIVERSAL::require' => 0,
        'UNIVERSAL'          => 0,
        'Test::More'         => 0,
        'Carp'               => 0,
    },
    recommends         => {},
    sign               => 0,
);
$build->create_build_script;
