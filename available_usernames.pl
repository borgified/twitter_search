#!/usr/bin/env perl

use warnings;
use strict;
use Net::Twitter;
use Scalar::Util 'blessed';
use DBI;
use Algorithm::Combinatorics qw(:all);

my %config = do '/secret/twitter.config';

my $consumer_key		= $config{consumer_key};
my $consumer_secret		= $config{consumer_secret};
my $token			= $config{token};
my $token_secret		= $config{token_secret};


#my $my_cnf = '/secret/my_cnf.cnf';

#my $dbh = DBI->connect("DBI:mysql:"
#                        . ";mysql_read_default_file=$my_cnf"
#                        .';mysql_read_default_group=twitter_search',
#                        undef,
#                        undef
#                        ) or die "something went wrong ($DBI::errstr)";


# As of 13-Aug-2010, Twitter requires OAuth for authenticated requests
my $nt = Net::Twitter->new(
    traits   => [qw/OAuth API::REST/],
    consumer_key        => $consumer_key,
    consumer_secret     => $consumer_secret,
    access_token        => $token,
    access_token_secret => $token_secret,
);

my $arrayref;

my $ar=&gen_names;
#my $names=shift(@$ar);
my $arg=shift(@ARGV);
my $names=$$ar[$arg];

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

### verbose output for testing gen_names
#my $ar=&gen_names;
#my $x=0;
#foreach my $item (@$ar){
#	print "$item\n";
#	$x++;
#	print "$x ====================\n";
#}


### generate usernames
#input: none
#output: array of comma delimited usernames strings of 100 users each
sub gen_names{

	my @alphabet=("a".."z");
	my @number=("0".."9");
	my @other=("_");
	my @results;

	my @alphanumeric = (@alphabet,@number,@other);

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
