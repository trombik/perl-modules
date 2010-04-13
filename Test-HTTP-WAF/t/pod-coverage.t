#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

# XXX to avoid "You tried to plan twice" error in END block, use Test::Base,
# instead of Test::More.
# this is needed because Test::Base calls plan() in END block.
use Test::Base;
eval "use Test::Pod::Coverage 1.00";
plan skip_all => "Test::Pod::Coverage 1.00 required for testing POD coverage"
    if $@;
all_pod_coverage_ok();
