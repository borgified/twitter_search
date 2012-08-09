#!/usr/bin/perl 
use strict;
use warnings;

my @alphabet=("a".."b");
my @number=("0".."2");

# all letters
foreach my $item(@alphabet){
	foreach  my $item2(@alphabet){
		foreach  my $item3(@alphabet){
			push(@word,"$item$item2$item3");
		}
	}
}
foreach my $line(@word){
	chomp($line);
	print "$line\n";
}
# all numbers
foreach my $num(@number){
	foreach  my $num2(@number){
		foreach  my $num3(@number){
			print "$num$num2$num3\n";
			#push(@word,"$item$item2$item3");
		}
	}
}
# mix letter/numbers
#check if exists in hash replace first 1st, 2nd, 3rd, 
#if exists, next 
#else enter into hash

