package Perl::PrereqInstaller;
use strict;
use warnings;
use Carp;
use Cwd;
use File::Find;
use Perl::PrereqScanner;

=head1 NAME

Perl::PrereqInstaller - Install missing modules explicitly
loaded by a Perl script or module

=head1 VERSION

Version 0.5.0

=cut

our $VERSION = '0.5.0';

=head1 SYNOPSIS

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

=head1 DESCRIPTION

Extract the names of the modules explicitly loaded in Perl scripts and
modules, check which modules are not installed, and install the
missing modules. Since this module relies on
L<Perl::PrereqScanner|Perl::PrereqScanner> to statically identify
dependencies, it has the same caveats regarding identifying loaded
modules. Therefore, modules that are loaded dynamically (e.g.,
C<eval "require $class">) will not be identified as dependencies or
installed.

=head2 Command-line tool

Command-line usage is possible with C<install-perl-prereqs>
(co-installed with this module).

    install-perl-prereqs FILE_OR_DIR [FILE_OR_DIR ...]
        -h, --help
        -d, --dry-run
        -v, --version

=head2 Methods for scanning, installing, and reporting results

=over 4

=item new

Initializes a new Perl::PrereqInstaller object.

=cut

sub new {
    my $class = shift;

    my $self = {
        _not_installed        => {},
        _previously_installed => {},
        _newly_installed      => {},
        _failed_install       => {},
        _scan_errors          => [],
        _scan_warnings        => {},
        _banned => { # Some pragmas and/or modules misbehave or are irrelevant
            'autodie'  => 1,
            'base'     => 1,
            'feature'  => 1,
            'overload' => 1,
            'perl'     => 1,
            'strict'   => 1,
            'vars'     => 1,
            'warnings' => 1,
        },
    };
    bless $self, $class;

    return $self;
}

=item scan( FILES and/or DIRECTORIES )

Analyzes specified FILES and files within specified DIRECTORIES to
generate a list of modules explicitly loaded and identify which are
not currently installed. Subsequent use of C<scan()> will update the
lists of modules that are not installed (or already installed).

=cut

sub scan {
    my ( $self, @path_list ) = @_;
    my $pattern = qr/^.+\.p[lm]$/i;

    print "\n";
    print "Files scanned:\n";

    for my $path (@path_list) {
        if ( -f $path ) {
            print "  $path\n";
            $self->_check_modules("$path");
        }
        elsif ( -d $path ) {
            find(
                sub {
                    return unless /$pattern/;
                    my $cwd  = getcwd;
                    my $file_path = "$cwd/$_";
                    print "  $file_path\n";
                    $self->_check_modules("$file_path");
                },
                $path
            );
        }
        else { print "Something is wrong.\n"; }
    }
    print "\n";
}

sub _check_modules {
    my ( $self, @file_list ) = @_;

    my $scanner = Perl::PrereqScanner->new;

    for my $file (@file_list) {
        next unless -e $file;
        next if -s $file >= 1048576;

        my $prereqs;
        eval { $prereqs = $scanner->scan_file($file) };
        if ($@) {
            push @{ $self->{_scan_errors} }, $file;
            next;
        }
        my @module_list = keys %{ $$prereqs{'requirements'} };

        for my $module (@module_list) {
            next if exists $self->{_banned}{$module};

            my $CATCH_WARNING = 1;
            $SIG{'__WARN__'}
                = sub { _catch_warning( $self, $file, $_[0], $CATCH_WARNING ) };
            eval "require $module;";
            $CATCH_WARNING = 0;
            if ($@) {
                $self->{_not_installed}{$module}++;
            }
            else {
                $self->{_previously_installed}{$module}++;
            }
        }
    }
}

sub _catch_warning {
    my ( $self, $file, $warning, $CATCH_WARNING ) = @_;

    if ($CATCH_WARNING) {
        chomp $warning;
        push @{ $self->{_scan_warnings}{$file} }, $warning;
    }
    else { warn $warning }
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

=item report

Write (to STDOUT) a summary of scan/install results.

=cut

=back

=head2 Methods for accessing scan/install status

=over 4

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

=item scan_errors

Returns a list of files that produced a parsing error
when being scanned. These files are skipped.

=cut

sub scan_errors {
    my $self = shift;
    return @{ $self->{_scan_errors} };
}

=item scan_warnings

Returns a hash of arrays containing the names of files (the keys) that
raised warnings (the array contents) during parsing. These warnings
are likely indicative of issues with the code in the parsed files
rather than actual parsing problems.

=cut

sub scan_warnings {
    my $self = shift;
    return %{ $self->{_scan_warnings} };
}

=back

=head1 SEE ALSO

L<lib::xi|lib::xi>
L<Perl::PrereqScanner|Perl::PrereqScanner>
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

To install this module from GitHub using cpanm:

    cpanm git@github.com:mfcovington/Perl-PrereqInstaller.git

Alternatively, download and run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install


=head1 SUPPORT AND DOCUMENTATION

You can find documentation for this module with the perldoc command.

    perldoc Perl::PrereqInstaller

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
