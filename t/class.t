#!/usr/bin/perl -w

use strict;
use Test::More tests => 9;
BEGIN { use_ok( 'Class::Meta') }

# Make sure we can't instantiate a class object from here.
my $class;
eval { $class = Class::Meta::Class->new };
ok(my $err = $@, 'Error creating class' );
like($err, qr/^Package 'main' cannot create.*objects/,
     'Check error message' );

# Now try inheritance.
package Class::Meta::FooSub;

@Class::Meta::FooSub::ISA = qw(Class::Meta);

# Set up simple settings.
my $spec = { name => 'Foo Class',
	     desc => 'Foo Class description',
	     key  => 'foo' };
# This should be okay.
main::ok( $class = Class::Meta::Class->new('FooClass', $spec),
	  'Subclass can create class objects' );

# Test the simple accessors.
main::is( $class->my_name, $spec->{name}, 'my_name' );
main::is( $class->my_desc, $spec->{desc}, 'my_name' );
main::is( $class->my_key, $spec->{key}, 'my_name' );


# This should throw an exception because we can only create a class once.
eval { $class = Class::Meta::Class->new('FooClass') };
main::ok($err = $@, 'Error creating duplicate class' );
main::like($err, qr/^Class object for class 'FooClass' already exists/,
     'Check duplicate class error message' );
