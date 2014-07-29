#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Perl::PrereqInstaller;

my @files = @ARGV;

my $installer = Perl::PrereqInstaller->new;
$installer->check_modules(@files) if $installer->check_modules(@files);

print "OOPS: $_\n"          for $installer->scan_errors;
print "NOT INSTALLED: $_\n" for $installer->not_installed;
print "INSTALLED: $_\n"     for $installer->previously_installed;

$installer->cpanm;

print "NEWLY INSTALLED: $_\n" for $installer->newly_installed;
print "UNINSTALLED: $_\n"     for $installer->not_installed;
print "FAILED: $_\n"          for $installer->failed_install;
