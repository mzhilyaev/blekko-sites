#!/usr/bin/perl

use strict;
use Data::Dumper;

my $cats = {};
while (<STDIN>) {
   chomp($_);
   my ($site, $cat, $sub) = split(",",$_);
   next if ($site =~ /[a-z,]/);
   $site = lc($site);
   #print "$site '$cat' '$sub'\n";
   if (!$cats->{$cat}) {
    $cats->{$cat} = {};
   }
   $cats->{$cat}->{$site} = 1;

   if (!($sub eq $cat)) {
     $sub =~ s/$cat/ /g;
     $sub =~ s/[^a-zA-Z0-9]/ /g;
     $sub =~ s/^  *//g;
     $sub =~ s/  *$//g;
     $sub =~ s/  */_/g;
     $sub = $cat."_".$sub;
     if (!$cats->{$sub}) {
      $cats->{$sub} = {};
     }
     $cats->{$sub}->{$site} = 1;
   }
   #print " ==== $cat ---$sub--\n";
}
close(FILE);

while (my ($cat,$val) = each %$cats) {
  open (FILE, "> $cat.st");
  print FILE join("\n", keys %$val);
  close FILE;
}
