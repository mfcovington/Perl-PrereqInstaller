#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use Module::Extract::Install;

my $file = $ARGV[0];

my $installer = Module::Extract::Install->new;
$installer->check_modules($file);

my @uninstalled = $installer->get_uninstalled_modules;
my @installed = $installer->get_installed_modules;

print "UNINSTALLED: $_\n" for @uninstalled;
print "INSTALLED: $_\n" for @installed;

$installer->cpanm;
