#!/usr/bin/perl
use strict;
use warnings;

if (my $foo = &foo) {
    print "ok\n";
} else {
    print "nok\n";
}

sub foo { 0 }
