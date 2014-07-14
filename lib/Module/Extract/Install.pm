package Module::Extract::Install;
use strict;
use warnings;
use Carp;
use Module::Extract::Use;

our $VERSION = '0.1.0';

=head1 NAME

Module::Extract::Install - Install uninstalled modules explicitly
loaded by a Perl script or module

=head1 SYNOPSIS

    use Module::Extract::Install;

    my $installer = Module::Extract::Install->new;
    $installer->check_modules($file);

    my @uninstalled = $installer->get_uninstalled_modules;
    my @installed   = $installer->get_installed_modules;

    $installer->cpanm;

=head1 DESCRIPTION

Extract the names of the modules explicitly loaded in a Perl script or
module and install them if they are not already installed. Since this
module relies on L<Module::Extract::Use|Module::Extract::Use>, it has
the same caveats regarding identifying loaded modules. Therefore,
modules that are loaded dynamically (e.g., C<eval "require $class">)
will not be installed.

=cut

=over 4

=item new

Makes an object. The object doesn't do anything just yet, but you need
it to call the methods.

=cut

sub new {
    my $class = shift;

    my $self = {
        _uninstalled => {},
        _installed   => {},
    };
    bless $self, $class;

    return $self;
}

=item check_modules( FILE )

Analyzes FILE to generate a list of modules explicitly loaded in FILE
and identifies which are not currently installed.

=cut

sub check_modules {
    my ( $self, $file ) = @_;

    my $extractor = Module::Extract::Use->new;
    my $details = $extractor->get_modules_with_details($file);

    # Temporary method for error handling:
    if ( $extractor->error ) {
        carp "Problem extracting modules used in $file";
    }

    for my $detail (@$details) {
        my $module  = $detail->module;
        my @imports = @{ $detail->imports };

        my $import_call = scalar @imports ? "$module qw(@imports)" : $module;

        eval "use $import_call;";
        if ($@) {
            $self->{_uninstalled}{$module}++;
        }
        else {
            $self->{_installed}{$module}++;
        }
    }
}

=item get_uninstalled_modules

Returns an alphabetical list of unique uninstalled modules that were
explicitly loaded.

=cut

sub get_uninstalled_modules {
    my $self = shift;
    return sort keys %{ $self->{_uninstalled} };
}

=item get_installed_modules

Returns an alphabetical list of unique installed modules that were
explicitly loaded.

=cut

sub get_installed_modules {
    my $self = shift;
    return sort keys %{ $self->{_installed} };
}

=item cpanm

Use cpanm to install loaded modules that are not currently installed.

=cut

sub cpanm {
    my $self = shift;
    my @modules = sort keys %{ $self->{_uninstalled} };
    system("cpanm $_") for @modules;
}

=back

=head1 SEE ALSO

L<Module::Extract::Use|Module::Extract::Use>

=head1 SOURCE AVAILABILITY

The source code is on Github:
L<https://github.com/mfcovington/module-extract-install>

=head1 AUTHOR

Michael F. Covington <mfcovington@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2014, Michael F. Covington, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
