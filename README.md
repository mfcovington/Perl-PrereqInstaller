[![Build Status](https://travis-ci.org/mfcovington/Perl-PrereqInstaller.svg?branch=master)](https://travis-ci.org/mfcovington/Perl-PrereqInstaller) [![Coverage Status](https://coveralls.io/repos/mfcovington/Perl-PrereqInstaller/badge.png?branch=master)](https://coveralls.io/r/mfcovington/Perl-PrereqInstaller?branch=master)

# NAME

Perl::PrereqInstaller - Install missing modules explicitly
loaded by a Perl script or module

# VERSION

Version 0.5.0

# SYNOPSIS

Scan, Install, and report results via command line:

    install-perl-prereqs lib/ bin/

Scan, Install, and report results via script:

    use Perl::PrereqInstaller;
    my $installer = Perl::PrereqInstaller->new;
    $installer->scan( @files, @directories );
    $installer->cpanm;
    $installer->report;

Access scan/install status via script:

    my @not_installed  = $installer->not_installed;
    my @prev_installed = $installer->previously_installed;

    my @newly_installed = $installer->newly_installed;
    my @failed_install  = $installer->failed_install;

    my @scan_errors   = $installer->scan_errors;
    my %scan_warnings = $installer->scan_warnings;

# DESCRIPTION

Extract the names of the modules explicitly loaded in Perl scripts and
modules, check which modules are not installed, and install the
missing modules. Since this module relies on
[Perl::PrereqScanner](https://metacpan.org/pod/Perl::PrereqScanner) to statically identify
dependencies, it has the same caveats regarding identifying loaded
modules. Therefore, modules that are loaded dynamically (e.g.,
`eval "require $class"`) will not be identified as dependencies or
installed.

## Command-line tool

Command-line usage is possible with `install-perl-prereqs`
(co-installed with this module).

    install-perl-prereqs FILE_OR_DIR [FILE_OR_DIR ...]
        -h, --help
        -d, --dry-run
        -v, --version

## Methods for scanning, installing, and reporting results

- new

    Initializes a new Perl::PrereqInstaller object.

- scan( FILES and/or DIRECTORIES )

    Analyzes specified FILES and files within specified DIRECTORIES to
    generate a list of modules explicitly loaded and identify which are
    not currently installed. Subsequent use of `scan()` will update the
    lists of modules that are not installed (or already installed).

- cpanm

    Use cpanm to install loaded modules that are not currently installed.

- report

    Write (to STDOUT) a summary of scan/install results.

## Methods for accessing scan/install status

- not\_installed

    Returns an alphabetical list of unique modules that were explicitly
    loaded, but need to be installed. Modules are removed from this list
    upon installation.

- previously\_installed

    Returns an alphabetical list of unique installed modules that were
    explicitly loaded.

- newly\_installed

    Returns an alphabetical list of unique modules that were
    explicitly loaded, needed to be installed, and were successfully
    installed.

- failed\_install

    Returns an alphabetical list of unique modules that were
    explicitly loaded and needed to be installed, but whose installation
    failed.

- scan\_errors

    Returns a list of files that produced a parsing error
    when being scanned. These files are skipped.

- scan\_warnings

    Returns a hash of arrays containing the names of files (the keys) that
    raised warnings (the array contents) during parsing. These warnings
    are likely indicative of issues with the code in the parsed files
    rather than actual parsing problems.

# SEE ALSO

[lib::xi](https://metacpan.org/pod/lib::xi)
[Perl::PrereqScanner](https://metacpan.org/pod/Perl::PrereqScanner)
[Module::Extract::Use](https://metacpan.org/pod/Module::Extract::Use)

# SOURCE AVAILABILITY

The source code is on Github:
[https://github.com/mfcovington/module-extract-install](https://github.com/mfcovington/module-extract-install)

# AUTHOR

Michael F. Covington, <mfcovington@gmail.com>

# BUGS

Please report any bugs or feature requests at
[https://github.com/mfcovington/module-extract-install/issues](https://github.com/mfcovington/module-extract-install/issues).

# INSTALLATION

To install this module from GitHub using cpanm:

    cpanm git@github.com:mfcovington/Perl-PrereqInstaller.git

Alternatively, download and run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

# SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc Perl::PrereqInstaller

# LICENSE AND COPYRIGHT

Copyright 2014 Michael F. Covington.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
