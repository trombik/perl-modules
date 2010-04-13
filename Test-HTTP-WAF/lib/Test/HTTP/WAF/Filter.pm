package Test::HTTP::WAF::Filter;
use strict;
use warnings;
use Test::Base::Filter -base;
use Carp qw{ carp croak };

sub GET {
    my ($self, $data) = @_;
    my $res = $Test::HTTP::WAF::UA->get($data);
    return if !defined $res;
    return $res->code;
}

sub header {
    my ($self, $data) = @_;
    my ( $headers, $body ) = split(/\n\n/xms, $data, 2);
    my ( $target, @headers ) = split /\n/xms, $headers;
    my ( $method, $url ) = split /\s+/xms, $target;

    my $header = HTTP::Headers->new( map { split( /:/xms, $_, 2 ) } @headers );

    # create request body.
    # if body is defined, assume it's a form submission...
    my $content_length = 0;
    my $content = $self->_mk_content($body);
    if ( defined $content ) {
        # automatically append required headers...
        $header->content_type("application/x-www-form-urlencoded");
        $content_length = length $content;
    }
    if ( $content_length && $content_length > 0 ) {
        $header->content_length($content_length);
    }

    my $req;
    if ( defined $content ) {
        $req = HTTP::Request->new( $method, $url, $header, $content );
    }
    else {
        $req = HTTP::Request->new( $method, $url, $header );
    }
    return $req;

}

sub _mk_content {
    my $self = shift;
    my $data = shift;
    return if !defined $data;
    my @lines = map { $self->_form_urlencode($_); } split( /\n/xms, $data );
    my $content = join( '&', @lines );
    return $content;
}

sub _form_urlencode {
    my $self = shift;
    my $data = shift;
    my ($k, $v) = split(/=/x, $data);
    # http://www.din.or.jp/~ohzaki/perl.htm#JP_Escape
    $k =~  s/([^\w ])/'%' . unpack('H2', $1)/eg; ## no critic
    $k =~ tr/ /+/; ## no critic
    $v =~  s/([^\w ])/'%' . unpack('H2', $1)/eg; ## no critic
    $v =~ tr/ /+/;
    return join('=', $k, $v);
}

sub REQUEST {
    my $self = shift;
    my $req = shift;
    if ( ref $req ne 'HTTP::Request' ) {
        carp( sprintf "block id: %d gave me non-HTTP::Request\n",
            $self->seq_num );
        return;
    }
    my $res = $Test::HTTP::WAF::UA->request($req);
    return if !defined $res;
    return $res->code;
}

=head1 NAME

Test::HTTP::WAF::Filter - Filters for Test::HTTP::WAF

=head1 SYNOPSIS

    --- input GET
    http://localhost/
    --- status
    200
    --- input header REQUEST
    GET http://host.example.org/foo/
    Transfer-Encoding: foo, bar # add a new header
    User-Agent: MyUserAgent     # override the default header
    --- status
    400
    === id 950116 (POST)
    --- input header REQUEST
    POST http://localhost/
    Content-Type: application/x-www-form-urlencoded

    key1=%uFF00

=head1 FILTERS

Test::HTTP::WAF::Filter provides the following Test::Base::Filter. Capitalized
filter, like GET, is suitable for the last filter. All of capitalized filters
returns HTTP status code.

=head2 GET

A simple GET filter. Accept a line of $url, GET $url, return the HTTP status code.

=cut

=head2 header

Parse the given lines of text as an HTTP header, return HTTP::Request object.
The first line of text determines the method, the host and the path ("GET
http://host.example.org/"), which is different from real HTTP header ("GET
HTTP/1.0 /" + "Host: host.example.org").

=head3 POST support

    POST http://host.example.org/path

    key1=value1
    key2 =value2

After an empty line ("\n\n"), specify keys and values in one line per pair. The
keys and values will be form-urlencoded. Note that "key2 " in the above example
is different from "key2" (the final result is "key2+").

The filter automatically appends "Content-Type: application/x-www-form-urlencoded".

=head2 REQUEST

Request the given HTTP::Request object, i.e. dispatch HTTP request, return HTTP
status code.

=cut

=head1 SEE ALSO

L<Test::Base::Filter>, L<LWP>, ModSecurity L<http://www.modsecurity.org/>, L<Test::HTTP::WAF>

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
1;
