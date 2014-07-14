#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Module::Extract::Install;

my $file = $ARGV[0];

my $installer = Module::Extract::Install->new;
$installer->check_modules($file);

print "NOT INSTALLED: $_\n" for $installer->not_installed;
print "INSTALLED: $_\n"     for $installer->previously_installed;

$installer->cpanm;

print "NEWLY INSTALLED: $_\n" for $installer->newly_installed;
print "UNINSTALLED: $_\n"     for $installer->not_installed;
print "FAILED: $_\n"          for $installer->failed_install;
