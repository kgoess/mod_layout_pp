#!perl -w
use strict;
use Test::More;

BEGIN {
    if (!eval "use Apache::Test qw(:withtestmore); 1;") {
        plan skip_all => "No Apache::Test";
    }
    if (!eval "use Apache::TestUtil qw(t_cmp); 1;") {
        plan skip_all => "No Apache::TestUtil ($@)";
    }
}

use Apache::TestRequest;

my @urls = qw(
    /simple/simple.html
    /cgi/test.pl
    /wildcards/changeme.html
);
my @ignore_urls = qw(
    /simple/headers-ignore-1.html
    /simple/headers-ignore-2.html
    /wildcards/ignoreme.html
    /wildcards/index-blah.html
    /wildcards/index.html
    /wildcards/index.phtml
    /wildcards/
    /no-strict/slash/
    /no-strict/slash/index.html
);

plan tests => 6 * scalar(@urls) + 3 * scalar(@ignore_urls);

foreach my $url (@urls) {
    my $content = GET $url;

    ok $content;
    ok t_cmp(200, $content->code, "Check that the request was OK");
    my $html = $content->content;

    ok t_cmp($html, qr[This is the css],    "LayoutCSS found in $url");
    ok t_cmp($html, qr[This is the header], "LayoutHeader found in $url");
    ok t_cmp($html, qr[This is the footer], "LayoutFooter found in $url");
    ok t_cmp($html,
             qr[matched \d+ times out of \d+ over \d+ reads and \d+ passes],
             "LayoutDebug/LayoutComment found");

}

foreach my $url (@ignore_urls){
    my $content = GET $url;
    ok $content;
    ok t_cmp(200, $content->code, "Check that the request was OK");
    my $html = $content->content;

    ok ! t_cmp($html, qr[This is the header], "LayoutHeader was ignored in $url");
}
