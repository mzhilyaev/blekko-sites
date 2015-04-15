#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use List::Util qw(sum);
use Getopt::Long;
use Switch;

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

