#!/usr/bin/perl

use strict;
use Data::Dumper;
use JSON;
use List::Util qw(sum);
use Getopt::Long;
use Switch;


my $json = JSON->new();
my $file = @ARGV[0];
my $alexaFile = @ARGV[1];
my $ranks = {};
#print "$file \n";
open (FILE , "<$file");
my $data = "";
while (<FILE>) {
  chomp($_);
  $data .= $_;
}
close(FILE);

open (FILE , "<$alexaFile");
my $rank = 1;

while (<FILE>) {
  chomp($_);
  $ranks->{$_} = $rank;
  $rank ++;
}
close(FILE);

my $cats = {};
my $subcats = {};

my $perl_scalar = $json->decode( $data );

sub findRank {
  my $url = shift;
  return $ranks->{$url};
}

sub findDomainRank {
  my $url = shift;
  my @chunks = split(/\./, $url);
  while (scalar(@chunks) > 1) {
    my $site = join(".", @chunks);
    if ($ranks->{$site}) {
      return $ranks->{$site};
    }
    shift @chunks;
  }
  return undef;
}

while (my ($key, $val) = each %$perl_scalar) {
  $key =~ s/^.*blekko.//;
  #print "$key\n";
  $cats -> {$key} = { sites => {} , tags => [], brank=>100000000, bsite=>''};

  if ($val->{tags}) {
    for my $tag (@{$val->{tags}}) {
      $tag =~ s/^.*blekko.//;
      $subcats->{$tag} = $key;
      push @{$cats -> {$key}->{tags}}, $tag;
    }
  }
  if ($val->{urls}) {
    for my $url (@{$val->{urls}}) {
      $url =~ s/^http:..//;
      $url =~ s/^https:..//;
      $url =~ s/^www\.//;
      $url =~ s/\/$//;
      if ($url !~ /\//) {
        my $rank = findRank($url);
        my $drank = findDomainRank($url);
        $cats -> {$key}->{sites}->{$url} = [$rank, $drank];
        if ($rank && $rank < $cats->{$key}->{brank}) {
          $cats->{$key}->{brank} = $rank;
          $cats->{$key}->{bsite} = $url;
        }
      }
    }
  }
}

my $seenCats = {};

## run closure
sub procTags {
  my $cat = shift;

  if (!$seenCats->{$cat} && $cats->{$cat}->{tags}) {
    for my $sub (@{$cats->{$cat}->{tags}}) {
      procTags($sub);
      ## add sub sites to the parent
      while (my ($site, $rank) = each %{$cats->{$sub}->{sites}}) {
        $cats->{$cat}->{sites}->{$site} = $rank;
      }
      if ($cats->{$sub}->{brank} < $cats->{$cat}->{brank}) {
        $cats->{$cat}->{brank} = $cats->{$sub}->{brank};
        $cats->{$cat}->{bsite} = $cats->{$sub}->{bsite};
      }
    }
  }
  $seenCats->{$cat} = 1;
}

for my $cat (keys %$cats) {
  procTags($cat);
}

$seenCats = {};
sub outputCat {
  my $cat = shift;

  my $marg = shift || "";
  my $rank = $cats->{$cat}->{brank};
  my $bsite = $cats->{$cat}->{bsite};
  my $len = scalar(keys %{$cats->{$cat}->{sites}});
  print "$marg$cat,$rank,$bsite,$len\n";
  $seenCats->{$cat} = 1;
  open (FILE,"> $cat.st");
  while (my ($site, $rank) = each %{$cats->{$cat}->{sites}}) {
    print FILE "$site,".join(",",@$rank)."\n";
  }
  close(FILE);
  if ($cats->{$cat}->{tags}) {
    for my $sub (@{$cats->{$cat}->{tags}}) {
      outputCat($sub, "$marg  $marg");
    }
  }
}

for my $cat (keys %$cats) {
  if (!$subcats->{$cat}) {
    outputCat($cat);
  }
}

#print Dumper($cats);
