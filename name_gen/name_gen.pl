#!/usr/bin/perl 
use strict;
use warnings;
use Algorithm::Combinatorics qw(:all);
my @alphabet=("a".."z");
my @number=("0".."9");

my @alphanumeric = (@alphabet,@number);

my $length = 4;

my $iter = variations_with_repetition(\@alphanumeric,$length);

while (my $p = $iter->next){
	print @$p,"\n";
}
