#!/usr/bin/perl

# $Id: meth.t,v 1.4 2003/11/22 00:49:18 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 42;

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
                                 view    => Class::Meta::PUBLIC ),
        "Create foo_meth" );

    isa_ok($meth, 'Class::Meta::Method');

    # Test its accessors.
    is( $meth->my_name, "foo_meth", "Check foo_meth name" );
    is( $meth->my_desc, "The foo method", "Check foo_meth desc" );
    is( $meth->my_label, "Foo method", "Check foo_meth label" );
    ok( $meth->my_view == Class::Meta::PUBLIC, "Check foo_meth view" );
    ok( $meth->my_context == Class::Meta::CLASS, "Check foo_meth context" );
    is ($meth->call(__PACKAGE__), 'foo', 'Call the foo_meth method' );

    # Okay, now test to make sure that an attempt to create a method directly
    # fails.
    eval { my $meth = Class::Meta::Method->new };
    ok( my $err = $@, "Get method construction exception");
    like( $err, qr/Package 'Class::Meta::TestPerson' cannot create/,
        "Caught proper exception");

    # Now try it without a name.
    eval{ $c->add_meth() };
    ok( $err = $@, "Caught no name exception");
    like( $err, qr/Parameter 'name' is required in call to new/,
        "Caught proper no name exception");

    # Try a duplicately-named method.
    eval{ $c->add_meth(name => 'foo_meth') };
    ok( $err = $@, "Caught dupe name exception");
    like( $err, qr/Method 'foo_meth' already exists in class/,
        "Caught proper dupe name exception");

    # Try a of bogus visibility.
    eval { $c->add_meth( name => 'new_meth',
                         view  => 10) };
    ok( $err = $@, "Caught another bogus view exception");
    like( $err, qr/Not a valid view parameter: '10'/,
        "Caught another proper bogus view exception");

    # Try a of bogus context.
    eval { $c->add_meth( name => 'new_meth',
                         context  => 10) };
    ok( $err = $@, "Caught another bogus context exception");
    like( $err, qr/Not a valid context parameter: '10'/,
        "Caught another proper bogus context exception");

    # Try a bogus caller.
    eval { $c->add_meth( name => 'new_meth',
                         caller => 'foo' ) };
    ok( $err = $@, "Caught bogus caller exception");
    like( $err, qr/Parameter caller must be a code reference/,
        "Caught proper bogus caller exception");

    # Now test all of the defaults.
    sub new_meth { 22 }
    ok( $meth = $c->add_meth( name => 'new_meth' ), "Create 'new_meth'" );
    isa_ok($meth, 'Class::Meta::Method');

    # Test its accessors.
    is( $meth->my_name, "new_meth", "Check new_meth name" );
    ok( ! defined $meth->my_desc, "Check new_meth desc" );
    ok( ! defined $meth->my_label, "Check new_meth label" );
    ok( $meth->my_view == Class::Meta::PUBLIC, "Check new_meth view" );
    ok( $meth->my_context == Class::Meta::OBJECT, "Check new_meth context" );
    is( $meth->call(__PACKAGE__), '22', 'Call the new_meth method' );
}

# Now try subclassing Class::Meta.

package Class::Meta::SubClass;
BEGIN { @Class::Meta::SubClass::ISA = qw(Class::Meta) }
sub add_meth {
    Class::Meta::Method->new( shift->SUPER::my_class, @_);
}

package Class::Meta::AnotherTest;
use strict;

BEGIN {
    # Import Test::More functions into this package.
    Test::More->import;

    # Create a new Class::Meta object.
    ok( my $c = Class::Meta::SubClass->new
        (another => __PACKAGE__), "Create subclassed CM object" );
    isa_ok($c, 'Class::Meta');
    isa_ok($c, 'Class::Meta::SubClass');
    sub foo_meth { 100 }
    ok( my $meth = $c->add_meth( name => 'foo_meth'),
        'Create subclassed foo_meth' );

    isa_ok($meth, 'Class::Meta::Method');

    # Test its accessors.
    is( $meth->my_name, "foo_meth", "Check new foo_meth name" );
    ok( ! defined $meth->my_desc, "Check new foo_meth desc" );
    ok( ! defined $meth->my_label, "Check new foo_meth label" );
    ok( $meth->my_view == Class::Meta::PUBLIC, "Check new foo_meth view" );
    ok( $meth->my_context == Class::Meta::OBJECT, "Check new foo_meth context" );
    is( $meth->call(__PACKAGE__), '100', 'Call the new foo_meth method' );
}
