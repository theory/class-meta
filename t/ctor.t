#!/usr/bin/perl

# $Id: ctor.t,v 1.2 2003/11/22 00:23:29 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 39;

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

    # Create a constructor.
    sub inst { bless {} }
    ok( my $ctor = $c->add_ctor( name    => 'inst',
                                 desc    => 'The inst constructor',
                                 label   => 'inst Constructor',
                                 view     => Class::Meta::PUBLIC ),
        "Create 'inst' ctor");
    isa_ok($ctor, 'Class::Meta::Constructor');

    # Test its accessors.
    is( $ctor->my_name, "inst", "Check inst name" );
    is( $ctor->my_desc, "The inst constructor", "Check inst desc" );
    is( $ctor->my_label, "inst Constructor", "Check inst label" );
    ok( $ctor->my_view == Class::Meta::PUBLIC, "Check inst view" );
    isa_ok( $ctor->call(__PACKAGE__), __PACKAGE__);

    # Okay, now test to make sure that an attempt to create a constructor
    # directly fails.
    eval { my $ctor = Class::Meta::Constructor->new };
    ok( my $err = $@, "Get constructor construction exception");
    like( $err, qr/Package 'Class::Meta::TestPerson' cannot create/,
        "Caught proper exception");

    # Now try it without a name.
    eval{ $c->add_ctor() };
    ok( $err = $@, "Caught no name exception");
    like( $err, qr/Parameter 'name' is required in call to new/,
        "Caught proper no name exception");

    # Try a duplicately-named constructor.
    eval{ $c->add_ctor(name => 'inst') };
    ok( $err = $@, "Caught dupe name exception");
    like( $err, qr/Method 'inst' already exists in class/,
        "Caught proper dupe name exception");

    # Try a couple of bogus visibilities.
    eval { $c->add_ctor( name => 'new_ctor',
                         view  => 25) };
    ok( $err = $@, "Caught bogus view exception");
    like( $err, qr/Not a valid view parameter: '25'/,
        "Caught proper bogus view exception");
    eval { $c->add_ctor( name => 'new_ctor',
                         view  => 10) };
    ok( $err = $@, "Caught another bogus view exception");
    like( $err, qr/Not a valid view parameter: '10'/,
        "Caught another proper bogus view exception");

    # Try a bogus caller.
    eval { $c->add_meth( name => 'new_inst',
                         caller => 'foo' ) };
    ok( $err = $@, "Caught bogus caller exception");
    like( $err, qr/Parameter caller must be a code reference/,
        "Caught proper bogus caller exception");

    # Now test all of the defaults.
    sub new_ctor { 22 }
    ok( $ctor = $c->add_ctor( name => 'new_ctor' ), "Create 'new_ctor'" );
    isa_ok($ctor, 'Class::Meta::Constructor');

    # Test its accessors.
    is( $ctor->my_name, "new_ctor", "Check new_ctor name" );
    ok( ! defined $ctor->my_desc, "Check new_ctor desc" );
    ok( ! defined $ctor->my_label, "Check new_ctor label" );
    ok( $ctor->my_view == Class::Meta::PUBLIC, "Check new_ctor view" );
    is ($ctor->call(__PACKAGE__), '22', 'Call the new_ctor constructor' );
}

# Now try subclassing Class::Meta.

package Class::Meta::SubClass;
BEGIN { @Class::Meta::SubClass::ISA = qw(Class::Meta) }
sub add_ctor {
    Class::Meta::Constructor->new( shift->SUPER::my_class, @_);
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

    sub foo_ctor { bless {} }
    ok( my $ctor = $c->add_ctor( name => 'foo_ctor'),
        'Create subclassed foo_ctor' );

    isa_ok($ctor, 'Class::Meta::Constructor');

    # Test its accessors.
    is( $ctor->my_name, "foo_ctor", "Check new foo_ctor name" );
    ok( ! defined $ctor->my_desc, "Check new foo_ctor desc" );
    ok( ! defined $ctor->my_label, "Check new foo_ctor label" );
    ok( $ctor->my_view == Class::Meta::PUBLIC, "Check new foo_ctor view" );
    isa_ok($ctor->call(__PACKAGE__), __PACKAGE__);
}
