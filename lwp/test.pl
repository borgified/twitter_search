#!/usr/bin/perl

use LWP::UserAgent;

my $ua = LWP::UserAgent->new;
$ua->agent("MyApp/0.1 ");

# Pass request to the user agent and get a response back
my $res = $ua->get('http://twitter.com/dtw');

# Check the outcome of the response
if ($res->is_success) {
	print $res->content;
} else {
	print $res->status_line, "\n";
}
