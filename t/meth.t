#!/usr/bin/perl

# $Id: meth.t,v 1.2 2002/05/16 18:12:47 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 11;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestPerson;
use strict;

# Make sure we can load Class::Meta.
BEGIN { main::use_ok( 'Class::Meta' ) }

BEGIN {
    # Import Test::More functions into this package.
    Test::More->import;

    # Create a new Class::Meta object.
    ok( my $c = Class::Meta->new(person => __PACKAGE__), "Create CM object" );
    isa_ok($c, 'Class::Meta');

    # Create a new method with all of the parameters set.
    sub foo_meth { 'foo' }
    ok( my $meth = $c->add_meth( name    => 'foo_meth',
                                 desc    => 'The foo method',
                                 label   => 'Foo method',
                                 context => Class::Meta::CLASS,
                                 vis     => Class::Meta::PUBLIC ),
        "Create foo_meth" );

    isa_ok($meth, 'Class::Meta::Method');

    # Test its accessors.
    is( $meth->my_name, "foo_meth", "Check foo_meth name" );
    is( $meth->my_desc, "The foo method", "Check foo_meth desc" );
    is( $meth->my_label, "Foo method", "Check foo_meth label" );
    ok( $meth->my_vis == Class::Meta::PUBLIC, "Check foo_meth vis" );
    ok( $meth->my_context == Class::Meta::CLASS, "Check foo_meth context" );
    is ($meth->call(__PACKAGE__), 'foo', 'Call the foo_meth method' );
}
