package Test::HTTP::WAF;
use strict;
use warnings;
use Test::Base -Base;
use LWP::UserAgent;
use Test::HTTP::WAF::Filter;
use Carp qw{ carp croak };

our $VERSION = 0.02;

our @EXPORT = qw{ $UA };
our $UA = LWP::UserAgent->new( agent => __PACKAGE__ . "/$VERSION" );

filters {
    input  => 'chomp',
    status => 'chomp',
};

# Core ModSecurity Rule Set, id 960015 requires Accept header in
# modsecurity_crs_21_protocol_anomalies.conf
$UA->default_header( Accept => 'text/html,*/*;q=0.5' );

1;
__END__

=head1 NAME

Test::HTTP::WAF - Test Web Application Firewall with Perl.

=head1 SYNOPSIS

    use strict;
    use warnings;
    use Test::HTTP::WAF;
    run_is;
    __END__
    === normal request, should be successful
    --- input GET
    http://localhost/
    --- status
    200
    === Unicode Full/Half Width Abuse Attack Attempt (id:950116)
    --- input GET
    http://localhost/?key=%uFF00
    --- status
    400
    === Same, but different attack vector
    --- input header REQUEST
    GET http://localhost/
    MyHeader: %uFF00
    --- status
    400
    === id 950116 (POST)
    --- input header REQUEST
    POST http://localhost/
    Content-Type: application/x-www-form-urlencoded

    key1=%uFF00

=cut

=head1 DESCRIPTION

Test WAF, Web Application Firewall, with Perl. Writing WAF rules is easy, but
testing the rule is not. This module provides a unified way of test-driven
signature development. The primary test target is ModSecurity, however, any WAF
can be tested.

=head1 EXPORTED VARIABLES

=head2 $UA

L<LWP::UserAgent> object for the test. The agent is initialized with default
values. See L<LWP::UserAgent>.

You can modify default behaviour of the agent in the test.

    $UA->default_header( MyHeader => 'Test::Base rulez' );

User-Agent and Accept headers are specified with "Test::HTTP::WAF/$VERSION" and
"text/html,*/*;q=0.5", respectively. The Core ModSecurity Rule Set requires
them by default (at the time of this writing). You can override these by
writing your own header or modifying $UA.

=cut

=head1 DATA SECTION

See L<Test::HTTP::WAF::Filter>.

=head1 SEE ALSO

L<Test::Base>, L<LWP>, ModSecurity L<http://www.modsecurity.org/>,
L<Test::HTTP::WAF::Filter>

=head1 AUTHOR

Tomoyuki Sakurai, E<lt>cherry@trombik.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Tomoyuki Sakurai

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

=cut
