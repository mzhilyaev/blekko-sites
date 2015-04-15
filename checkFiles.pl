#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use List::Util qw(sum);
use Getopt::Long;
use Switch;

my $file = @ARGV[0];
open (FILE , "<$file");
my @sites = ();
while (<FILE>) {
  chomp($_);
  $_ =~ s/^www\.//;
  push @sites, $_;
}
close(FILE);

my $catSites = {};
for my $site (@sites) {
  my $out = `grep -l $site data/*st | tr "\012" ","`;
  $out =~ s/,$//;
  my @cats = split(/,/, $out);
  for my $cat (@cats) {
    if (!$catSites->{$cat}) {
      $catSites->{$cat} = [];
    }
    push @{$catSites->{$cat}}, $site;
  }
}

print Dumper($catSites);

