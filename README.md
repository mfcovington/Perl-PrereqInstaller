# NAME

Module::Extract::Install - Install uninstalled modules explicitly
loaded by a Perl script or module

# SYNOPSIS

    use Module::Extract::Install;

    my $installer = Module::Extract::Install->new;
    $installer->check_modules($file);

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

- new

    Makes an object. The object doesn't do anything just yet, but you need
    it to call the methods.

- check\_modules( FILE )

    Analyzes FILE to generate a list of modules explicitly loaded in FILE
    and identifies which are not currently installed.

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

- cpanm

    Use cpanm to install loaded modules that are not currently installed.

# SEE ALSO

[Module::Extract::Use](https://metacpan.org/pod/Module::Extract::Use)

# SOURCE AVAILABILITY

The source code is on Github:
[https://github.com/mfcovington/module-extract-install](https://github.com/mfcovington/module-extract-install)

# AUTHOR

Michael F. Covington <mfcovington@gmail.com>

# COPYRIGHT AND LICENSE

Copyright (c) 2014, Michael F. Covington, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.
