#
#===============================================================================
#
#         FILE:  mod_security_core.t
#
#  DESCRIPTION:  
#
#        FILES:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Tomoyuki Sakurai <cherry@trombik.org>
#      COMPANY:  OpenBSD Support Japan Inc.
#      VERSION:  1.0
#      CREATED:  02/10/08 19:26:33 JST
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use FindBin qw{ $Bin };
use lib "$Bin/../lib";
use Test::HTTP::WAF;

if ( $ENV{TEST_AUTHOR} ) {
    plan tests => 1 * blocks;
}
else {
    plan skip_all => "Set TEST_AUTHOR environment variable to test Core ModSecurity Rules";
}

run_is;
__END__
=== normal request
--- input chomp GET
http://localhost/
--- status chomp
200
=== id 990902
--- input GET
http://localhost/nessustest
--- status
404
=== id 960017
--- input GET
http://127.0.0.1/
--- status
400
=== id 950012
--- input header REQUEST
GET http://localhost/
Transfer-Encoding: foo, bar
--- status
400
=== id 950116
--- input GET
http://localhost/?key=%uFF00
--- status
400
=== id 950116
--- input header REQUEST
GET http://localhost/
MyHeader: %uFF00
--- status
400
=== id 950116 (POST)
--- input header REQUEST
POST http://localhost/
User-Agent: Foo

key=value
key1= %uFF00
key 2=value
--- status
400

