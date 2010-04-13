# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Test-HTTP-WAF.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::Base tests => 1;
use FindBin qw{ $Bin };
use lib "$Bin/../lib";
BEGIN {
    use_ok('Test::HTTP::WAF');
}

