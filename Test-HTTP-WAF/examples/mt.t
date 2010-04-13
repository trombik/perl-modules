#
#===============================================================================
#
#         FILE:  mt.t
#
#       AUTHOR:  Tomoyuki Sakurai, <cherry@trombik.org>
#      CREATED:  01/19/10 11:10:29
#===============================================================================

use strict;
use warnings;

use Test::HTTP::WAF;

run_is;

__END__
=== normal request
--- input GET
http://example.com/
--- status
200
=== comment spam (email)
--- input header REQUEST
POST http://example.com/m/mt-comments.cgi
Content-Type: application/x-www-form-urlencoded
Host: example.com

email=foo
--- status
403
=== comment spam (url)
--- input header REQUEST
POST http://example.com/m/mt-comments.cgi
Content-Type: application/x-www-form-urlencoded
Host: example.com

url=foo
--- status
403
