#!/usr/bin/perl -w

# $Id: class.t,v 1.7 2004/01/08 17:56:32 david Exp $

use strict;
use Test::More tests => 9;
BEGIN { use_ok( 'Class::Meta') }

# Make sure we can't instantiate a class object from here.
my $class;
eval { $class = Class::Meta::Class->new };
ok( my $err = $@, 'Error creating class' );
like($err, qr/^Package 'main' cannot create.*objects/,
     'Check error message' );

# Now try inheritance.
package Class::Meta::FooSub;

@Class::Meta::FooSub::ISA = qw(Class::Meta);
use Carp;
$SIG{__WARN__} = \&Carp::cluck;

# Set up simple settings.
my $spec = { name  => 'Foo Class',
             desc  => 'Foo Class description',
             package => 'FooClass',
             key   => 'foo' };
# This should be okay.
main::ok( $class = Class::Meta::Class->new($spec),
          'Subclass can create class objects' );

# Test the simple accessors.
main::is( $class->name, $spec->{name}, 'name' );
main::is( $class->desc, $spec->{desc}, 'name' );
main::is( $class->key, $spec->{key}, 'name' );

# This should throw an exception because we can only create a class once.
eval { $class = Class::Meta::Class->new($spec) };
main::ok($err = $@, 'Error creating duplicate class' );
main::like($err, qr/^Class object for class 'FooClass' already exists/,
     'Check duplicate class error message' );
