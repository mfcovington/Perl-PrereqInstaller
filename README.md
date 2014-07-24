[![Build Status](https://travis-ci.org/mfcovington/module-extract-install.svg?branch=master)](https://travis-ci.org/mfcovington/module-extract-install) [![Coverage Status](https://coveralls.io/repos/mfcovington/module-extract-install/badge.png?branch=master)](https://coveralls.io/r/mfcovington/module-extract-install?branch=master)

# NAME

Module::Extract::Install - Install missing modules explicitly
loaded by a Perl script or module

# VERSION

Version 0.4.3

# SYNOPSIS

Via command line:

    cpanm-missing file.pl

    cpanm-missing-deep path/to/directory

Via a script:

    use Module::Extract::Install;

    my $installer = Module::Extract::Install->new;
    $installer->check_modules(@files);
    $installer->check_modules_deep($directory);

    my @uninstalled = $installer->not_installed;
    my @installed   = $installer->previously_installed;

    $installer->cpanm;

    my @newly_installed = $installer->newly_installed;
    my @failed_install  = $installer->failed_install;

# DESCRIPTION

Extract the names of the modules explicitly loaded in a Perl script or
module and install them if they are not already installed. Since this
module relies on [Module::Extract::Use](https://metacpan.org/pod/Module::Extract::Use), it has
the same caveats regarding identifying loaded modules. Therefore,
modules that are loaded dynamically (e.g., `eval "require $class"`)
will not be installed.

Command-line usage is possible with `cpanm-missing` and
`cpanm-missing-deep`, scripts that are installed along with this
module.

- new

    Initializes a new Module::Extract::Install object.

- check\_modules( FILES )

    Analyzes FILES to generate a list of modules explicitly loaded in
    FILES and identifies which are not currently installed. Subsequent
    calls of this method will continue adding to the lists of modules
    that are not installed (or already installed).

- check\_modules\_deep( DIRECTORY, PATTERN )

    Traverses a DIRECTORY and runs `check_modules()` on files that match
    PATTERN, a case-insensitive regular expression. If omitted, PATTERN
    defaults to `^.+\.p[lm]$` and matches files ending in `.pl` or
    `.pm`. Subsequent calls of this method will continue adding to the
    lists of modules that are not installed (or already installed).

- cpanm

    Use cpanm to install loaded modules that are not currently installed.

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

# SEE ALSO

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

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

# SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc Module::Extract::Install

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
