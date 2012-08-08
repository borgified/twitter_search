#!/usr/bin/env perl

use warnings;
use strict;
use Net::Twitter;
use Scalar::Util 'blessed';

# When no authentication is required:
my $nt = Net::Twitter->new(legacy => 0);

my %config = do '/secret/twitter.config';

my $consumer_key	=$config{consumer_key};
my $consumer_secret	=$config{consumer_secret};
my $token			=$config{token};
my $token_secret	=$config{token_secret};


# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);

my $result = $nt->update('Hello, world!');

eval {
    my $statuses = $nt->friends_timeline({ since_id => $high_water, count => 100 });
    for my $status ( @$statuses ) {
        print "$status->{created_at} <$status->{user}{screen_name}> $status->{text}\n";
    }
};
if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}
