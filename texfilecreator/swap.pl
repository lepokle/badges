#!/usr/bin/env perl

use strict;
use warnings;

use File::Slurp;

my @lines = File::Slurp::read_file($ARGV[0]);
for(my $i = 0; $i < scalar @lines; $i += 2) {
    my $line1 = $lines[$i];
    my $line2 = $lines[$i + 1];

    print "$line2";
    print "$line1";
}

