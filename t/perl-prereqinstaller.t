#!/usr/bin/env perl
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More tests => 9;

BEGIN {
    eval "use Perl::PrereqInstaller";
}

# FYI: You owe me $3.50 if you put 'A::Non::Existent::Perl::Module' on CPAN.
require A::Non::Existent::Perl::Module if 0;

my $installer = Perl::PrereqInstaller->new;

$installer->check_modules($0);
$installer->{_not_installed}{'--version'} = 1;

my @not_installed = $installer->not_installed;
my @installed     = $installer->previously_installed;

diag('Ignore the warnings about A::Non::Existent::Perl::Module not being found. This is intentional.');
$installer->cpanm;

my @newly_installed     = $installer->newly_installed;
my @failed_install      = $installer->failed_install;
my @still_not_installed = $installer->not_installed;

isa_ok( $installer, 'Perl::PrereqInstaller' );
is_deeply( \@installed, ['Test::More'],
    'Find modules that are already installed' );
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

$installer->check_modules('t/bad/scan-error.pl');
my @scan_errors = $installer->scan_errors;
is_deeply( \@scan_errors, ['t/bad/scan-error.pl'],
    'Report files with scan errors' );

my $deep_installer = Perl::PrereqInstaller->new;
$deep_installer->check_modules_deep("t/deep");
my @not_installed_deep = $deep_installer->not_installed;
my @installed_deep     = $deep_installer->previously_installed;

is_deeply( \@installed_deep, ['Test::More'],
    'Find modules that are already installed deep' );
is_deeply(
    \@not_installed_deep,
    ['Another::Non::Existent::Perl::Module'],
    'Find modules that are not yet installed deep'
);
