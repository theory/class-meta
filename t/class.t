#!/usr/bin/perl -w

# $Id: class.t,v 1.8 2004/01/08 21:56:43 david Exp $

use strict;
use Test::More tests => 14;
BEGIN { use_ok( 'Class::Meta') }

# Make sure we can't instantiate a class object from here.
my $class;
eval { $class = Class::Meta::Class->new };
ok( my $err = $@, 'Error creating class' );
like($err, qr/^Package 'main' cannot create.*objects/,
     'Check error message' );

# Now try inheritance.
package Class::Meta::FooSub;
use strict;
use base 'Class::Meta';
Test::More->import;

# Set up simple settings.
my $spec = { name  => 'Foo Class',
             desc  => 'Foo Class description',
             package => 'FooClass',
             key   => 'foo' };
# This should be okay.
ok( $class = Class::Meta::Class->new($spec),
          'Subclass can create class objects' );

# Test the simple accessors.
is( $class->name, $spec->{name}, 'name' );
is( $class->desc, $spec->{desc}, 'name' );
is( $class->key, $spec->{key}, 'name' );

# This should throw an exception because we can only create a class once.
eval { $class = Class::Meta::Class->new($spec) };
ok($err = $@, 'Error creating duplicate class' );
like($err, qr/^Class object for class 'FooClass' already exists/,
     'Check duplicate class error message' );

# Now try inheritance for Class.
package Class::Meta::Class::Sub;
use base 'Class::Meta::Class';

package main;
ok( my $cm = Class::Meta->new( class_class => 'Class::Meta::Class::Sub'),
    "Create Class" );
ok( $class = $cm->class, "Retrieve class" );
isa_ok($class, 'Class::Meta::Class::Sub');
isa_ok($class, 'Class::Meta::Class');
is( $class->package, __PACKAGE__, "Check an attibute");

