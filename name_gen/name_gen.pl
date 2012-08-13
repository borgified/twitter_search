#!/usr/bin/perl 
use strict;
use warnings;
use Algorithm::Combinatorics qw(:all);
my @alphabet=("a".."z");
my @number=("0".."9");
my @other=("_");

my @alphanumeric = (@alphabet,@number,@other);

my $length = 3;

my $iter = variations_with_repetition(\@alphanumeric,$length);
my $i=0;
while (my $p = $iter->next){
	$i++;
	print "$i ",@$p,"\n";
}
