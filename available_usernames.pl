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

eval {

	#$arrayref=$nt->lookup_users( {screen_name => 'a,blkasdfjk,c'});

};

if ( my $err = $@ ) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');

    warn "HTTP Response Code: ", $err->code, "\n",
         "HTTP Message......: ", $err->message, "\n",
         "Twitter error.....: ", $err->error, "\n";
}


foreach my $hash (@$arrayref){

#	foreach my $key (keys %$hash){
#		print "$key: $$hash{$key}\n";
#	}

	print "$$hash{screen_name} $$hash{id} $$hash{friends_count} $$hash{followers_count} $$hash{statuses_count}\n";

}


my $ar=&gen_names;
my $x=0;
foreach my $item (@$ar){
	print "$item\n";
	$x++;
	print "$x ====================\n";
}


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
		$twitter_handles=$twitter_handles.join('',@$p)."($i),";
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
