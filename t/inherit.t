#!perl -w

# $Id: inherit.t,v 1.5 2004/01/08 18:37:52 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 95;

##############################################################################
# Create a simple class.
##############################################################################

package Test::One;

BEGIN {
    Test::More->import;
    use_ok( 'Class::Meta');
    use_ok( 'Class::Meta::Types::Numeric', 'affordance');
    use_ok( 'Class::Meta::Types::String', 'affordance');
}

BEGIN {
    ok( my $c = Class::Meta->new( key     => 'one',
                                  package => __PACKAGE__,
                                  name    => 'One Class',
                                  desc    => 'Test One Class.'),
        "Create One's Class::Meta" );

    # Add a constructor.
    ok( $c->add_constructor( name => 'new',
                             create  => 1 ),
        "Create One's construtor" );

    # Add a couple of attributes with created methods.
    ok( $c->add_attribute( name     => 'id',
                           view     => Class::Meta::PUBLIC,
                           authz    => Class::Meta::READ,
                           create   => Class::Meta::GET,
                           type     => 'integer',
                           label    => 'ID',
                           desc     => "The object's ID.",
                           required => 1,
                           default  => undef,
                       ),
        "Create One's ID attribute" );

    ok( $c->add_attribute( name     => 'name',
                           view     => Class::Meta::PUBLIC,
                           authz    => Class::Meta::RDWR,
                           create   => Class::Meta::GETSET,
                           type     => 'string',
                           length      => 256,
                           label    => 'Name',
                           field    => 'text',
                           desc     => "The object's name.",
                           required => 1,
                           default  => '',
                       ),
        "Create One's name attribute" );

    ok( $c->add_method(name => 'foo'), "Add foo method to One" );
    ok( $c->add_method(name => 'bar'), "Add bar method to One" );
    ok( $c->build, "Build Test::One" );
}
sub foo { __PACKAGE__ }
sub bar { __PACKAGE__ }

package Test::Two;
use base 'Test::One';

BEGIN {
    Test::More->import;
    main::use_ok( 'Class::Meta');
}

BEGIN {
    ok( my $c = Class::Meta->new( key     => 'two',
                                  package => __PACKAGE__,
                                  name    => 'Two Class',
                                  desc    => 'Test Two Class.'),
        "Create Two's Class::Meta" );

    # Add another constructor.
    ok( $c->add_constructor(name => 'two_new'), "Create Two's ctor" );

    # Add an attribute.
    ok( $c->add_attribute( name     => 'description',
                           view     => Class::Meta::PUBLIC,
                           authz    => Class::Meta::RDWR,
                           create   => Class::Meta::GETSET,
                           type     => 'string',
                           label    => 'Description',
                           field    => 'text',
                           desc     => "The object's description.",
                           required => 1,
                           default  => '',
                       ),
        "Create Two's description attribute" );

    # Make sure that adding an attribute with the same name as in a parent class
    # causes an exception.
    eval {
        $c->add_attribute( name     => 'name',
                           view     => Class::Meta::PUBLIC,
                           authz    => Class::Meta::RDWR,
                           create   => Class::Meta::GETSET,
                           type     => 'string',
                           length      => 256,
                           label    => 'Name',
                           field    => 'text',
                           desc     => "The object's name.",
                           required => 1,
                           default  => '',
                       )
    };

    ok( my $err = $@, "Catch duplicate attribute exception" );
    like( $err, qr/Attribute 'name' already exists in class 'Test::One'/,
          "Check error message" );

    # Add a method.
    ok( $c->add_method(name => 'woah'), "Add woah method to One" );
    # Add an overriding method.
    ok( $c->add_method(name => 'bar'), "Add bar method to Two" );

    ok( $c->build, "Build Test::Two" );
}

sub woah { __PACKAGE__ }
sub bar { __PACKAGE__ }

package main;

# Check out Test::One's class object.
ok( my $one_class = Test::One->my_class, "Get One's Class object" );
isa_ok( $one_class, 'Class::Meta::Class' );
ok( $one_class->is_a('Test::One'), "Check it's for Test::One" );
ok( ! $one_class->is_a('Test::Two'), "Check it's not for Test::Two" );

# Check One's attributes.
ok( my @one_attributes = $one_class->attributes, "Get attributes" );
is( scalar @one_attributes, 2, "Check for two attributes" );
is( $one_attributes[0]->name, 'id', "Check for id attribute" );
is( $one_attributes[1]->name, 'name', "Check for name attribute" );

# Check out Test::Two's class object.
ok( my $two_class = Test::Two->my_class, "Get Two's Class object" );
isa_ok( $two_class, 'Class::Meta::Class' );
ok( $two_class->is_a('Test::One'), "Check it's for Test::One" );
ok( $two_class->is_a('Test::Two'), "Check it's for Test::Two" );

# Check Two's attributes.
ok( my @two_attributes = $two_class->attributes, "Get attributes" );
is( scalar @two_attributes, 3, "Check for two attributes" );
is( $two_attributes[0]->name, 'id', "Check for id attribute" );
is( $one_attributes[0], $two_attributes[0], "Check for same id as One" );
is( $two_attributes[1]->name, 'name', "Check for name attribute" );
is( $one_attributes[1], $two_attributes[1], "Check for same name as One" );
is( $two_attributes[2]->name, 'description', "Check for description attribute" );

# Make sure that One's new() constructor works.
ok( my $one = Test::One->new( name => 'foo'), "Construct One object" );
isa_ok( $one, 'Test::One' );
eval { Test::One->new(name => 'foo',  description => 'bar') };
ok( my $err = $@, 'Catch bad One parameter exception' );
like( $err, qr/No such attribute 'description' in Test::One/,
      'Check bad One exception' );

# Check One's attribute accessors.
is( $one->get_name, 'foo', "Check One's name" );
ok( $one->set_name('hello'), "Set One's name" );
is( $one->get_name, 'hello', "Check One's new name" );
is( $one->get_id, undef, "Check One's id" );
eval { $one->set_id(1) };
ok( $err = $@, "Check for set_id exception" );

# Check One's attribute object accessors.
is( $one_attributes[0]->call_get($one), undef, "Check attr call id" );
ok( $one_attributes[1]->call_set($one, 'howdy'), "Call set on One" );
is( $one_attributes[1]->call_get($one), 'howdy', "Call get on One" );

# Check One's methods.
is( $one->foo, 'Test::One', "Check One->foo" );
is( $one->bar, 'Test::One', "Check One->bar" );
eval { $one->woah };
ok( $err = $@, "Catch One->woah exception" );

# Check One's method objects.
ok( my $foo = $one_class->methods('foo'), "Get foo method object" );
is( $foo->package, 'Test::One', "Check One foo's package" );
is( $foo->call($one), 'Test::One', "Check One foo's call" );
ok( my $bar = $one_class->methods('bar'), "Get bar method object" );
is( $bar->package, 'Test::One', "Check One bar's package" );
is( $bar->call($one), 'Test::One', "Check One bar's call" );

# Make sure that Two inherits new() and works with its attributes.
ok( my $two = Test::Two->new( name => 'foo'), "Construct Two object" );
isa_ok( $two, 'Test::Two' );
ok( $two = Test::Two->new(name => 'foo',  description => 'bar'),
    "Construct another Two object" );
isa_ok( $two, 'Test::Two' );

# make sure that Two's own constructor works, too.
ok( $two = Test::Two->two_new(name => 'Larry'),
    "Construct another Two object" );
isa_ok( $two, 'Test::Two' );

# Check Two's attribute accessors.
is( $two->get_id, undef, "Check Two's id" );
eval { $two->set_id(1) };
ok( $err = $@, "Check for set_id exception" );
is( $two->get_name, 'Larry', "Check Two's name" );
ok( $two->set_name('hello'), "Set Two's name" );
is( $two->get_name, 'hello', "Check Two's new name" );
is( $two->get_description, '', "Check Two's description" );
ok( $two->set_description('yello'), "Set Two's description" );
is( $two->get_description, 'yello', "Check Two's new description" );

# Check Two's attribute object accessors.
is( $two_attributes[0]->call_get($two), undef, "Check attr call id" );
is( $two_attributes[1]->call_get($two), 'hello', "Call get on Two" );
ok( $two_attributes[1]->call_set($two, 'howdy'), "Call set on Two" );
is( $two_attributes[1]->call_get($two), 'howdy', "Call get on Two again" );
is( $two_attributes[2]->call_get($two), 'yello', "Call get on Two" );
ok( $two_attributes[2]->call_set($two, 'rowdy'), "Call set on Two" );
is( $two_attributes[2]->call_get($two), 'rowdy', "Call get on Two again" );

# Check Two's methods.
is( $two->foo, 'Test::One', 'Check Two->foo' );
is( $two->bar, 'Test::Two', 'Check Two->bar' );
is( $two->woah, 'Test::Two', 'Check Two->woah' );

# Check Two's methods.
is( $two->foo, 'Test::One', "Check Two->foo" );
is( $two->bar, 'Test::Two', "Check Two->bar" );
is( $two->woah, 'Test::Two', "Check Two->woah" );

# Check Two's method objects.
ok( $foo = $two_class->methods('foo'), "Get foo method object" );
is( $foo->package, 'Test::One', "Check Two foo's package" );
is( $foo->call($two), 'Test::One', "Check Two foo's call" );
ok( $bar = $two_class->methods('bar'), "Get bar method object" );
is( $bar->package, 'Test::Two', "Check Two bar's package" );
is( $bar->call($two), 'Test::Two', "Check Two bar's call" );
ok( my $woah = $two_class->methods('woah'), "Get woah method object" );
is( $woah->package, 'Test::Two', "Check Two woah's package" );
is( $woah->call($two), 'Test::Two', "Check Two woah's call" );
