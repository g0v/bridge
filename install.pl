#!/usr/bin/env perl

use 5.026;
use utf8;
use open IO => ":locale";
use strict;
use warnings;
use Getopt::Std;

my %opts;
getopts('f', \%opts);

my $MB_VERSION = "1.26.0";
my $MB_BIN = "matterbridge";
my $MB_URL = "https://github.com/42wim/matterbridge/releases/download/v{$MB_VERSION}/matterbridge-${MB_VERSION}-linux-64bit";

my $template_path = "matterbridge.toml.template";

system "curl -L -o ${MB_BIN} ${MB_URL}" if $opts{f} or not -x $MB_BIN;
chmod 0755, ${MB_BIN};

sub load_dotenv {
    open my $dotenv, ".env" or die "Cannot read .env: $!\n";
    my %dotenv = map { /^(.*)=(.*)$/ && $1 => $2 } <$dotenv>;
    %ENV = %{{ %ENV, %dotenv }};
}

sub gen_config {
    my $outfile = shift;
    open my $fh, $template_path or die "Cannot read $template_path: $!\n";
    my $template = join "", map { s/\[% (.*?) %\]/$ENV{$1}/g; $_ } <$fh>;
    open my $out, ">$outfile" or die "Cannot write to $outfile: $!\n";
    print $out $template;
}

&load_dotenv;
gen_config("matterbridge.toml");
