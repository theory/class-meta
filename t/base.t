#!perl -w

# $Id: base.t,v 1.22 2004/01/08 21:32:19 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 81;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestPerson;
use strict;

BEGIN {
    main::use_ok('Class::Meta');
    main::use_ok('Class::Meta::Types::Numeric');
    main::use_ok('Class::Meta::Types::String');
}

BEGIN {
    my $c = Class::Meta->new(
        key     => 'person',
        package => __PACKAGE__,
        name    => 'Class::Meta::TestPerson Class',
        desc    => 'Special person class just for testing Class::Meta.',
    );

    # Add a constructor.
    $c->add_constructor( name => 'new',
                         create  => 1 );

    # Add a couple of attributes with created methods.
    $c->add_attribute( name     => 'id',
                       view     => Class::Meta::PUBLIC,
                       authz    => Class::Meta::READ,
                       create   => Class::Meta::GET,
                       type     => 'integer',
                       label    => 'ID',
                       desc     => "The person object's ID.",
                       required => 1,
                       default  => undef,
                   );
    $c->add_attribute( name     => 'name',
                       view     => Class::Meta::PUBLIC,
                       authz    => Class::Meta::RDWR,
                       create   => Class::Meta::GETSET,
                       type     => 'string',
                       label    => 'Name',
                       field    => 'text',
                       desc     => "The person's name.",
                       required => 1,
                       default  => '',
                   );
    $c->add_attribute( name     => 'age',
                       view     => Class::Meta::PUBLIC,
                       authz    => Class::Meta::RDWR,
                       create   => Class::Meta::GETSET,
                       type     => 'integer',
                       label    => 'Age',
                       field    => 'text',
                       desc     => "The person's age.",
                       required => 0,
                       default  => undef,
                   );

    # Add a couple of custom methods.
    $c->add_method( name  => 'chk_pass',
                    view   => Class::Meta::PUBLIC,
                );

    $c->add_method( name  => 'shame',
                    view   => Class::Meta::PUBLIC,
                );

    $c->build;
}

sub chk_pass {
    my ($self, $un, $pw) = @_;
    return $un eq 'larry' && $pw eq 'yrral' ? 1 : 0;
}

sub shame { shift }

##############################################################################
# Do the tests.
##############################################################################

package main;
# Instantiate a base class object and test its accessors.
ok( my $t = Class::Meta::TestPerson->new, 'Class::Meta::TestPerson->new');
is( $t->id, undef, 'id is undef');
eval { $t->id(1) };

# Test string.
ok( $t->name('David'), 'name to "David"' );
is( $t->name, 'David', 'name is "David"' );
eval { $t->name([]) };
ok( my $err = $@, 'name to array ref croaks' );
like( $err, qr/^Value .* is not a valid string/, 'correct string exception' );

# Grab its metadata object.
ok( my $class = $t->my_class, "Get Class::Meta::Class object" );

# Test the is_a() method.
ok( $class->is_a('Class::Meta::TestPerson'), 'Class is_a TestPerson');

# Test the key methods.
is( $class->key, 'person', 'Key is correct');

# Test the package methods.
is($class->package, 'Class::Meta::TestPerson', 'package()');

# Test the name methods.
is( $class->name, 'Class::Meta::TestPerson Class', "Name is correct");

# Test the description methods.
is( $class->desc, 'Special person class just for testing Class::Meta.',
    "Description is correct");

# Test attributes().
ok(my @attributes = $class->attributes, "Get attributes from attributes()" );
is( scalar @attributes, 3, "Three attributes from attributes()" );
isa_ok($attributes[0], 'Class::Meta::Attribute',
       "First object is a attribute object" );
isa_ok($attributes[1], 'Class::Meta::Attribute',
       "Second object is a attribute object" );
isa_ok($attributes[2], 'Class::Meta::Attribute',
       "Third object is a attribute object" );

# Get specific attributes.
ok( @attributes = $class->attributes(qw(age name)), 'Get specific attributes' );
is( scalar @attributes, 2, "Two specific attributes from attributes()" );
isa_ok($attributes[0], 'Class::Meta::Attribute', "Attribute object type" );

is( $attributes[0]->name, 'age', 'First attr name' );
is( $attributes[1]->name, 'name', 'Second attr name' );

# Check the attributes of the "ID" attribute object.
ok( my $p = $class->attributes('id'), "Get ID attribute object" );
is( $p->name, 'id', 'ID name' );
is( $p->desc, "The person object's ID.", 'ID description' );
is( $p->view, Class::Meta::PUBLIC, 'ID view' );
is( $p->authz, Class::Meta::READ, 'ID authorization' );
is( $p->type, 'integer', 'ID type' );
is( $p->label, 'ID', 'ID label' );
ok( $p->required, "ID required" );
is( $p->default, undef, "ID default" );

# Test the attribute accessors.
ok( ! defined $p->call_get($t), 'ID not defined' );
# ID is READ, so we shouldn't be able to set it.
eval { $p->call_set($t, 10) };
ok( $err = $@, "Set val failure" );
like( $err, qr/Cannot set attribute 'id/, 'set val exception' );

# Check the attributes of the "Name" attribute object.
ok( $p = $class->attributes('name'), "Get name attribute" );
is( $p->name, 'name', 'Name name' );
is( $p->desc, "The person's name.", 'Name description' );
is( $p->view, Class::Meta::PUBLIC, 'Name view' );
is( $p->authz, Class::Meta::RDWR, 'Name authorization' );
is( $p->type, 'string', 'Name type' );
is( $p->label, 'Name', 'Name label' );
ok( $p->required, "Name required" );
is( $p->default, '', "Name default" );

# Test the attribute accessors.
is( $p->call_get($t), 'David', 'Name call_get' );
ok( $p->call_set($t, 'Larry'), 'Name call_set' );
is( $p->call_get($t), 'Larry', 'New Name call_get' );
is( $t->name, 'Larry', 'Object name');
ok( $t->name('Damian'), 'Object name' );
is( $p->call_get($t), 'Damian', 'Final Name call_get' );

# Check the attributes of the "Age" attribute object.
ok( $p = $class->attributes('age'), "Get age attribute" );
is( $p->name, 'age', 'Age name' );
is( $p->desc, "The person's age.", 'Age description' );
is( $p->view, Class::Meta::PUBLIC, 'Age view' );
is( $p->authz, Class::Meta::RDWR, 'Age authorization' );
is( $p->type, 'integer', 'Age type' );
is( $p->label, 'Age', 'Age label' );
ok( $p->required == 0, "Age required" );
is( $p->default, undef, "Age default" );

# Test the attribute accessors.
ok( ! defined $p->call_get($t), 'Age call_get' );
ok( $p->call_set($t, 10), 'Age call_set' );
is( $p->call_get($t), 10, 'New Age call_get' );
ok( $t->age == 10, 'Object age');
ok( $t->age(22), 'Object age' );
is( $p->call_get($t), 22, 'Final Age call_get' );

# Test methods().
ok( my @methods = $class->methods, "Get method objects" );
is( scalar @methods, 2, 'Number of methods from methods()' );
isa_ok($methods[0], 'Class::Meta::Method',
       "First object is a method object" );
isa_ok($methods[1], 'Class::Meta::Method',
       "Second object is a method object" );

# Check the order in which they're returned.
is( $methods[0]->name, 'chk_pass', 'First method' );
is( $methods[1]->name, 'shame', 'Second method' );

# Get a few specific methods.
ok( @methods = $class->methods(qw(shame chk_pass)),
    'Grab specific methods.');
is( scalar @methods, 2, 'Two methods from methods()' );
is( $methods[0]->name, 'shame', 'First specific method' );
is( $methods[1]->name, 'chk_pass', 'Second specific method' );

# Check out the chk_pass method.
ok( my $m = $class->methods('chk_pass'), "Get chk_pass method object" );
is( $m->name, 'chk_pass', 'chk_pass name' );
ok( $m->call($t, 'larry', 'yrral') == 1, 'Call chk_pass returns true' );
ok( $m->call($t, 'larry', 'foo') == 0, 'Call chk_pass returns false' );

__END__
