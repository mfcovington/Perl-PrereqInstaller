#!/usr/bin/env perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Module::Extract::Install' ) || print "Bail out!\n";
}

diag( "Testing Module::Extract::Install $Module::Extract::Install::VERSION, Perl $], $^X" );
