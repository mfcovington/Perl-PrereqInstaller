#!/usr/bin/env perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 6;

use lib 'lib';
BEGIN {
    eval "use Module::Extract::Install";
}

# FYI: You owe me $3.50 if you put 'A::Non::Existent::Perl::Module' on CPAN.
require A::Non::Existent::Perl::Module if 0;

my $installer = Module::Extract::Install->new;

$installer->check_modules($0);
$installer->{_not_installed}{'--version'} = 1;

my @not_installed = $installer->not_installed;
my @installed     = $installer->previously_installed;

diag('Ignore the warnings about A::Non::Existent::Perl::Module not being found. This is intentional.');
$installer->cpanm;

my @newly_installed     = $installer->newly_installed;
my @failed_install      = $installer->failed_install;
my @still_not_installed = $installer->not_installed;

isa_ok( $installer, 'Module::Extract::Install' );
is_deeply(
    \@installed,
    [ 'Test::More', 'lib' ],
    'Find modules that are already installed'
);
is_deeply(
    \@not_installed,
    [ '--version', 'A::Non::Existent::Perl::Module' ],
    'Find modules that are not yet installed'
);
is_deeply( \@newly_installed, ['--version'],
    'cpanm is installed and report newly installed modules' );
is_deeply(
    \@failed_install,
    ['A::Non::Existent::Perl::Module'],
    'Report which modules fail to install'
);
is_deeply(
    \@still_not_installed,
    ['A::Non::Existent::Perl::Module'],
    'Report which modules still need to be installed'
);

done_testing();
