package Module::Extract::Install;
use strict;
use warnings;
use Carp;
use File::Find;
use Perl::PrereqScanner;

=head1 NAME

Module::Extract::Install - Install missing modules explicitly
loaded by a Perl script or module

=head1 VERSION

Version 0.4.4

=cut

our $VERSION = '0.4.4';

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Extract the names of the modules explicitly loaded in a Perl script or
module and install them if they are not already installed. Since this
module relies on L<Module::Extract::Use|Module::Extract::Use>, it has
the same caveats regarding identifying loaded modules. Therefore,
modules that are loaded dynamically (e.g., C<eval "require $class">)
will not be installed.

Command-line usage is possible with C<cpanm-missing> and
C<cpanm-missing-deep>, scripts that are installed along with this
module.

=cut

=over 4

=item new

Initializes a new Module::Extract::Install object.

=cut

sub new {
    my $class = shift;

    my $self = {
        _not_installed        => {},
        _previously_installed => {},
        _newly_installed      => {},
        _failed_install       => {},
    };
    bless $self, $class;

    return $self;
}

=item check_modules( FILES )

Analyzes FILES to generate a list of modules explicitly loaded in
FILES and identifies which are not currently installed. Subsequent
calls of this method will continue adding to the lists of modules
that are not installed (or already installed).

=cut

sub check_modules {
    my ( $self, @file_list ) = @_;

    my $scanner = Perl::PrereqScanner->new;

    # Some pragmas and/or modules misbehave or are irrelevant
    my %banned = (
        'autodie'  => 1,
        'base'     => 1,
        'feature'  => 1,
        'overload' => 1,
        'perl'     => 1,
        'strict'   => 1,
        'vars'     => 1,
        'warnings' => 1,
    );

    # Ignore things such as 'Prototype mismatch' and deprecation warnings
    my $NOWARN = 0;
    $SIG{'__WARN__'} = sub { warn $_[0] unless $NOWARN };

    for my $file (@file_list) {
        next unless -e $file;
        next if -s $file >= 1048576;
        my @module_list = keys %{ ${ $scanner->scan_file($file) }{'requirements'} };

        # # Temporary method for error handling:
        # if ( $extractor->error ) {
        #     carp "Problem extracting modules used in $file";
        # }

        for my $module (@module_list) {
            next if exists $banned{$module};

            $NOWARN = 1;
            eval "require $module;";
            $NOWARN = 0;
            if ($@) {
                $self->{_not_installed}{$module}++;
            }
            else {
                $self->{_previously_installed}{$module}++;
            }
        }
    }
}

=item check_modules_deep( DIRECTORY, PATTERN )

Traverses a DIRECTORY and runs C<check_modules()> on files that match
PATTERN, a case-insensitive regular expression. If omitted, PATTERN
defaults to C<^.+\.p[lm]$> and matches files ending in C<.pl> or
C<.pm>. Subsequent calls of this method will continue adding to the
lists of modules that are not installed (or already installed).

=cut

sub check_modules_deep {
    my ( $self, $directory, $pattern ) = @_;

    $pattern = defined $pattern ? qr/$pattern/i : qr/^.+\.p[lm]$/i;

    print "\n";
    print "Files found:\n";
    find(
        sub {
            return unless /$pattern/;
            print "  $File::Find::dir/$_\n";
            $self->check_modules($_);
        },
        $directory
    );
    print "\n";
}

=item cpanm

Use cpanm to install loaded modules that are not currently installed.

=cut

sub cpanm {
    my $self = shift;

    my @modules = sort keys %{ $self->{_not_installed} };
    for (@modules) {
        my $exit_status = system("cpanm $_");
        if ($exit_status) {
            $self->{_failed_install}{$_}++;
        }
        else {
            delete $self->{_not_installed}{$_};
            delete $self->{_failed_install}{$_};
            $self->{_newly_installed}{$_}++;
        }
    }
}

=item not_installed

Returns an alphabetical list of unique modules that were explicitly
loaded, but need to be installed. Modules are removed from this list
upon installation.

=cut

sub not_installed {
    my $self = shift;
    return sort keys %{ $self->{_not_installed} };
}

=item previously_installed

Returns an alphabetical list of unique installed modules that were
explicitly loaded.

=cut

sub previously_installed {
    my $self = shift;
    return sort keys %{ $self->{_previously_installed} };
}

=item newly_installed

Returns an alphabetical list of unique modules that were
explicitly loaded, needed to be installed, and were successfully
installed.

=cut

sub newly_installed {
    my $self = shift;
    return sort keys %{ $self->{_newly_installed} };
}

=item failed_install

Returns an alphabetical list of unique modules that were
explicitly loaded and needed to be installed, but whose installation
failed.

=cut

sub failed_install {
    my $self = shift;
    return sort keys %{ $self->{_failed_install} };
}

=back

=head1 SEE ALSO

L<Module::Extract::Use|Module::Extract::Use>

=head1 SOURCE AVAILABILITY

The source code is on Github:
L<https://github.com/mfcovington/module-extract-install>

=head1 AUTHOR

Michael F. Covington, <mfcovington@gmail.com>

=head1 BUGS

Please report any bugs or feature requests at
L<https://github.com/mfcovington/module-extract-install/issues>.

=head1 INSTALLATION

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc Module::Extract::Install

=head1 LICENSE AND COPYRIGHT

Copyright 2014 Michael F. Covington.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

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

=cut

1;
