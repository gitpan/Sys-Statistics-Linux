use ExtUtils::MakeMaker;
die 'Sorry, but this system seems not to be a linux system!'
   unless $^O =~ /linux/i;
WriteMakefile
(
          'PL_FILES' => {},
          'INSTALLDIRS' => 'site',
          'NAME' => 'Sys::Statistics::Linux',
          'EXE_FILES' => [],
          'VERSION_FROM' => 'lib/Sys/Statistics/Linux.pm',
          'PREREQ_PM' => {
                           'Test::More' => 0,
                           'IO::File' => 0,
                           'Carp' => 0
                         }
        )
;
