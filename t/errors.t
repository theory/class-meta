#!perl -w

# $Id: errors.t,v 1.3 2004/01/28 21:45:33 david Exp $

##############################################################################
# Set up the tests.
##############################################################################
use strict;
use Test::More tests => 189;

BEGIN {
    main::use_ok('Class::Meta');
    main::use_ok('Class::Meta::Types::String');
}

package Class::Meta::Testing;

##############################################################################
# Create a simple class.
##############################################################################

BEGIN {
    my $cm = Class::Meta->new;
    $cm->add_constructor( name => 'new' );
    $cm->add_attribute( name => 'tail', type => 'string' );
    $cm->build;
}

package main;

##############################################################################
# Test Class::Meta errors.
eval { Class::Meta->new('foo') };
chk('odd number to Class::Meta->new',
    qr/Odd number of parameters in call to new()/);

my $cm = Class::Meta->new( package => 'foo' );
eval { Class::Meta->new( package => 'foo' ) };

##############################################################################
# Test Class::Meta::Attribute errors.
eval { Class::Meta::Attribute->new };
chk('Attribute->new protected',
    qr/ cannot create Class::Meta::Attribute objects/);

eval { $cm->add_attribute('foo') };
chk('odd number to Class::Meta::Attribute->new',
    qr/Odd number of parameters in call to new()/);

eval { $cm->add_attribute(desc => 'foo') };
chk('Attribute name required',
    qr/Parameter 'name' is required in call to new()/);

eval { $cm->add_attribute(name => 'fo&o') };
chk('Invalid attribute name',
    qr/Attribute 'fo&o' is not a valid attribute name/);

# Create an attribute to use for a few tests. It's private so that there are
# no accessors.
ok( my $attr = $cm->add_attribute( name => 'foo',
                                   type => 'string',
                                   view => Class::Meta::PRIVATE),
    "Create 'foo' attribute");

eval { $cm->add_attribute( name => 'foo') };
chk('Attribute exists', qr/Attribute 'foo' already exists/);

for my $p (qw(view authz create context)) {
    eval { $cm->add_attribute( name => 'hey', $p => 100) };
    chk("Invalid Attribute $p", qr/Not a valid $p parameter: '100'/);
}

eval { $attr->get };
chk('No attribute get method', qr/Cannot get attribute 'foo'/);

eval { $attr->set };
chk('No attribute set method', qr/Cannot set attribute 'foo'/);

eval { Class::Meta::Attribute->build };
chk('Attribute->build protected',
    qr/ cannot call Class::Meta::Attribute->build/);

##############################################################################
# Test Class::Meta::Class errors.
eval { Class::Meta::Class->new };
chk('Class->new protected',
    qr/ cannot create Class::Meta::Class objects/);

eval { Class::Meta->new( package => 'foo' ) };
chk('Duplicate class', qr/Class object for class 'foo' already exists/);

eval { Class::Meta::Class->build };
chk('Class->build protected',
    qr/ cannot call Class::Meta::Class->build/);

##############################################################################
# Test Class::Meta::Constructor errors.
eval { Class::Meta::Constructor->new };
chk('Constructor->new protected',
    qr/ cannot create Class::Meta::Constructor objects/);

eval { $cm->add_constructor('foo') };
chk('odd number to Class::Meta::Constructor->new',
    qr/Odd number of parameters in call to new()/);

eval { $cm->add_constructor(desc => 'foo') };
chk('Constructor name required',
    qr/Parameter 'name' is required in call to new()/);

eval { $cm->add_constructor(name => 'fo&o') };
chk('Invalid constructor name',
    qr/Constructor 'fo&o' is not a valid constructor name/);

# Create an constructor to use for a few tests. It's private so that it
# can't be called from here.
ok( my $ctor = $cm->add_constructor( name => 'newer',
                                     view => Class::Meta::PRIVATE),
    "Create 'newer' constructor");

eval { $cm->add_constructor( name => 'newer') };
chk('Constructor exists', qr/Method 'newer' already exists/);

eval { $cm->add_constructor( name => 'hey', view => 100) };
chk("Invalid Constructor view", qr/Not a valid view parameter: '100'/);

eval { $cm->add_constructor( name => 'hey', caller => 100) };
chk("Invalid Constructor caller",
    qr/Parameter caller must be a code reference/);

eval { $ctor->call };
chk('Cannot call constructor', qr/Cannot call constructor 'newer'/);

eval { Class::Meta::Constructor->build };
chk('Constructor->build protected',
    qr/ cannot call Class::Meta::Constructor->build/);

# Make sure that the actual constructor's own errors are thrown.
eval { Class::Meta::Testing->new( foo => 1 ) };
chk('Invalid parameter to generated constructor',
    qr/No such attribute 'foo' in Class::Meta::Testing objects/);

##############################################################################
# Test Class::Meta::Method errors.
eval { Class::Meta::Method->new };
chk('Method->new protected',
    qr/ cannot create Class::Meta::Method objects/);

eval { $cm->add_method('foo') };
chk('odd number to Class::Meta::Method->new',
    qr/Odd number of parameters in call to new()/);

eval { $cm->add_method(desc => 'foo') };
chk('Method name required',
    qr/Parameter 'name' is required in call to new()/);

eval { $cm->add_method(name => 'fo&o') };
chk('Invalid method name',
    qr/Method 'fo&o' is not a valid method name/);

# Create an method to use for a few tests. It's private so that it
# can't be called from here.
ok( my $meth = $cm->add_method( name => 'hail',
                                view => Class::Meta::PRIVATE),
    "Create 'hail' method");

eval { $cm->add_method( name => 'hail') };
chk('Method exists', qr/Method 'hail' already exists/);

for my $p (qw(view context)) {
    eval { $cm->add_method( name => 'hey', $p => 100) };
    chk("Invalid Method $p", qr/Not a valid $p parameter: '100'/);
}

eval { $cm->add_method( name => 'hey', caller => 100) };
chk("Invalid Method caller", qr/Parameter caller must be a code reference/);

eval { $meth->call };
chk('Cannot call method', qr/Cannot call method 'hail'/);

##############################################################################
# Test Class::Meta::Type errors.
eval { Class::Meta::Type->new };
chk(' Missing type', qr/Type argument required/);

eval { Class::Meta::Type->new('foo') };
chk('Invalid type', qr/Type 'foo' does not exist/);

eval { Class::Meta::Type->add };
chk('Type key required', qr/Parameter 'key' is required/);

eval { Class::Meta::Type->add( key => 'foo') };
chk('Type name required', qr/Parameter 'name' is required/);

eval { Class::Meta::Type->add( key => 'string', name => 'string' ) };
chk('Type already exists', qr/Type 'string' already defined/);

eval { Class::Meta::Type->add( key => 'foo', name => 'foo', check => {}) };
chk('Invalid type check',
    qr/Paremter 'check' in call to add\(\) must be a code reference/);

eval { Class::Meta::Type->add( key => 'foo', name => 'foo', check => [{}]) };
chk('Invalid type check array',
    qr/Paremter 'check' in call to add\(\) must be a code reference/);

eval {
    Class::Meta::Type->add( key => 'foo',
                            name => 'foo',
                            builder => 'NoBuild');
};
chk('No build', qr/No such function 'NoBuild::build\(\)'/);

eval {
    Class::Meta::Type->add( key => 'foo',
                            name => 'foo',
                            builder => 'NoAttrGet');
};
chk('No attr get', qr/No such function 'NoAttrGet::build_attr_get\(\)'/);

eval {
    Class::Meta::Type->add( key => 'foo',
                            name => 'foo',
                            builder => 'NoAttrSet');
};
chk('No attr set', qr/No such function 'NoAttrSet::build_attr_set\(\)'/);

eval { Class::Meta::Type->build };
chk('Type->build protected', qr/ cannot call Class::Meta::Type->build/);

##############################################################################
# This function handles all the tests.
##############################################################################
sub chk {
    my ($name, $qr) = @_;
    # Catch the exception.
    ok( my $err = $@, "Caught $name error" );
    # Check its message.
    like( $err, $qr, "Correct error" );
    # Make sure it refers to this file.
    like( $err, qr|at t/errors.t line|, 'Correct context' );
    # Make sure it doesn't refer to other Class::Meta files.
    unlike( $err, qr|lib/Class/Meta|, 'Not incorrect context')
}

##############################################################################
# Packages we'll use for testing type errors.
package NoAttrGet;
sub build {}

package NoAttrSet;
sub build {}
sub build_attr_get {}
