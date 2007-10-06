use ExtUtils::MakeMaker;
die 'OS unsupported! Sorry, but this system seems not to be a linux system!'
   unless $^O =~ /linux/i;
WriteMakefile
(
          'NAME' => 'Sys::Statistics::Linux',
          'VERSION_FROM' => 'lib/Sys/Statistics/Linux.pm',
          'PREREQ_PM' => {
                           'Carp' => '0',
                           'Test::More' => '0',
                           'UNIVERSAL' => '0',
                           'UNIVERSAL::require' => '0'
                         },
          'INSTALLDIRS' => 'site',
          'EXE_FILES' => [],
          'PL_FILES' => {}
        )
;
