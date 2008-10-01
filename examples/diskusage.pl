#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use Sys::Statistics::Linux;
use Sys::Statistics::Linux::DiskUsage;
$Sys::Statistics::Linux::DiskUsage::DF_CMD = 'df -akP';

my $sys  = Sys::Statistics::Linux->new(diskusage => 1);
my $disk = $sys->get;

print Dumper($disk);
