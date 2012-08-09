#!/usr/bin/perl 
use strict;
use warnings;

my @alphabet=("a".."z");
my @number=("0".."9");

my @alphanumeric = (@alphabet,@number);

my @word;

# all letters
foreach my $item(@alphanumeric){
	foreach  my $item2(@alphanumeric){
		foreach  my $item3(@alphanumeric){
			push(@word,"$item$item2$item3");
		}
	}
}
foreach my $line(@word){
	print "$line\n";
}

