#!/usr/bin/perl

use strict;
use Data::Dumper;

my $site = {};
while (my $file = shift @ARGV) {
  open (FILE , "cut -d',' -f1 $file |");
  while (<FILE>) {
   chomp($_);
   $site->{$_} = 1;
  }
  close(FILE);
}

print join("\n",sort keys %$site)."\n";

