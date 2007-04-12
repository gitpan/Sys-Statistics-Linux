use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    create_readme      => 1,
    create_makefile_pl => 'traditional',
    license            => 'perl',
    module_name        => 'Sys::Statistics::Linux',
    dist_author        => 'Jonny Schulz',
    requires => {
        'Test::More'     => 0,
        Carp             => 0,
    },
    recommends         => {},
    sign               => 0,
);
$build->create_build_script;
