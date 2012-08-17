#!/usr/bin/env perl

use warnings;
use strict;
use Net::Twitter;
use Scalar::Util 'blessed';
use Algorithm::Combinatorics qw(:all);

my %config = do '/secret/twitter.config';

my $consumer_key		= $config{consumer_key};
my $consumer_secret		= $config{consumer_secret};
my $token			= $config{token};
my $token_secret		= $config{token_secret};

# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);

#this is to hold the results that come back from querying twitter
my $arrayref;

#$ar contains array ref to all the different combinations of usernames possible
#valid chars and length of username are all configured within &gen_names
#the array looks like this: ('aaa,aab,aac,...','baa,bab,bac,...',...) where each
#element in the array is a comma separated string composed of a 100 twitter handles
#to test. (lookup_users allows max 100 user queries)
my $ar=&gen_names;

#the @ARGV given determines which set of 100 twitter handles to use... ie. $arg=0 is the
#first set of 100 user handles. (used as array index)
my $arg=shift(@ARGV);
my $names=$$ar[$arg];

#lookup_users only returns back valid users, not missing ones, so we create a hash
#using the list of 100 twitter handles that was used as input to lookup_users.
#then fill in each key's value with the user's twitter id according to what lookup_users
#returns. those hash keys not having a corresponding value means lookup_users was not able
#to get their id, so those keys must be either unclaimed accounts or suspended ones or
#just somehow invalid (these accounts are manually placed in the "weird" file)
my %results_hash;
my @names = split(/,/,$names);
foreach my $name (@names){
	$results_hash{$name}="";
}

eval {

	$arrayref=$nt->lookup_users( {screen_name => $names});
	#$arrayref=$nt->lookup_users( {screen_name => 'aaa,aa0,ccc'});

};

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}

open(OUTPUT,">>results.txt") or die $!;
print OUTPUT "===========================\n";

#this loop stores the result of lookup_users into a text file, just a couple fields per
#account. also stores the found twitter id for each user into the %results_hash we prepared
#earlier.
foreach my $hash (@$arrayref){

#	foreach my $key (keys %$hash){
#		print "$key: $$hash{$key}\n";
#	}

	print OUTPUT "$$hash{screen_name} $$hash{id} $$hash{friends_count} $$hash{followers_count} $$hash{statuses_count}\n";
#	print "$$hash{screen_name} $$hash{id} $$hash{friends_count} $$hash{followers_count} $$hash{statuses_count}\n";

	my $screen_name=$$hash{screen_name};
	$screen_name=~tr/A-Z/a-z/;
	$results_hash{$screen_name}=$$hash{id};

}

#print back out the filled out %results_hash so we can see which accounts (hash keys)
#dont have a value (twitter id) attached to it.
my $count=0;
foreach my $screen_name (sort keys %results_hash){
	if($results_hash{$screen_name} eq ''){
		print "$count $screen_name may be available\n";
	}else{
		print "$count $screen_name $results_hash{$screen_name}\n";
	}
	$count++;
}

print "rate limit status\n";
my $status=$nt->rate_limit_status;
foreach my $item (sort keys %$status){
	print "$item $$status{$item};\n" unless($item eq 'photos');
}

### generate usernames
#input: none
#output: array of comma delimited usernames strings of 100 users each
sub gen_names{

#modify the below 3 variables to alter the pool of allowed twitter username chars
	my @alphabet=("a".."z");
	my @number=("0".."9");
	my @other=("_");

	my @results;

	my @alphanumeric = (@alphabet,@number,@other);

#modify this variable if you want to test longer usernames
	my $length = 3;

	my $iter = variations_with_repetition(\@alphanumeric,$length);
	my $i=0;
	my $twitter_handles="";
	while (my $p = $iter->next){
		#$twitter_handles=$twitter_handles.join('',@$p)."($i),";
		$twitter_handles=$twitter_handles.join('',@$p).",";
		if($i>=99){
			$i=0;
			chop($twitter_handles); #remove last comma
			push(@results, $twitter_handles);
			$twitter_handles="";
		}else{
			$i++;
		}
	}

#these next two lines take care of the last few items that did not
#make it to 99 to be pushed into @results

	chop($twitter_handles); #remove last comma
	push(@results, $twitter_handles);
	
	return \@results;

}
