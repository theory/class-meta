#!/usr/bin/perl -w

# $Id: base.t,v 1.8 2003/11/21 21:21:07 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 4;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestPerson;
use strict;
use IO::Socket;

BEGIN {
    main::use_ok( 'Class::Meta');
    main::ok( my $c = Class::Meta->new(
        key   => 'person',
        class => __PACKAGE__,
        name  => 'Class::Meta::TestPerson Class',
        desc  => 'Special person class just for testing Class::Meta.'
    ), "Create new Class::Meta object" );

    # Add a constructor.
    $c->add_ctor( name => 'new',
                   gen  => 1 );

    # Add a couple of attributes with generated methods.
    $c->add_attr( name => 'id',
                  vis   => &Class::Meta::PUBLIC,
                  auth  => &Class::Meta::READ,
                  gen   => &Class::Meta::GET,
                  type  => 'integer',
                  label => 'ID',
                  desc  => "The person object's ID.",
                  req   => 1,
                  def   => undef,
                );
    $c->add_attr( name  => 'name',
                  vis   => &Class::Meta::PUBLIC,
                  auth  => &Class::Meta::RDWR,
                  gen   => &Class::Meta::GETSET,
                  type  => 'string',
                  len   => 256,
                  label => 'Name',
                  field => 'text',
                  desc  => "The person's name.",
                  req   => 1,
                  def   => undef,
                );
    $c->add_attr( name  => 'age',
                  vis   => &Class::Meta::PUBLIC,
                  auth  => &Class::Meta::RDWR,
                  gen   => &Class::Meta::GETSET,
                  type  => 'integer',
                  label => 'Age',
                  field => 'text',
                  desc  => "The person's age.",
                  req   => 0,
                  def   => undef,
                );

    # Add a custom method.
    $c->add_meth( name  => 'chk_pass',
                  vis   => &Class::Meta::PUBLIC,
                );
    $c->build;
}

sub chk_pass {
    my ($un, $pw) = @_;
    return $un eq 'larry' && $pw eq 'yrral' ? 1 : 0;
}

##############################################################################
# Do the tests.
##############################################################################

package main;
# Instantiate a base class object and test its accessors.
ok( my $t = Class::Meta::TestPerson->new, 'Class::Meta::TestPerson->new');
is( $t->get_id, undef, 'get_id is undef');
eval { $t->set_id(1) };
ok( my $err = $@, 'set_id croaks' );
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for set_id()");

# Test string.
ok( $t->set_name('David'), 'set_name to "David"' );
is( $t->get_name, 'David', 'get_name is "David"' );
eval { $t->set_name([]) };
ok( $err = $@, 'set_name to array ref croaks' );
like( $err, qr/^Value .* is not a string/, 'correct string exception' );

# Grab its metadata object.
ok( my $class = $t->my_class );

# Test the isa() method.
ok( $class->isa('Class::Meta::PersonTest'), 'Class isa PersonTest');

# Test the key methods.
is( $class->get_key, 'person', 'Key is correct');
eval { $class->set_key('foo') };
ok ( $err = $@, "Got an error trying to change key");
like( $err, qr/Can't locate object method/, "Shouln't be able to change key");

# Test the package methods.
is($class->my_pkg, 'Class::Meta::PersonTest', 'my_pkg()');
eval { $class->set_pkg('foo') };
ok ($err = $@, "Try to change pacakge");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for package name");

# Test the name methods.
is( $class->get_name, 'Class::Meta TestPerson Class', "Name is correct");
eval { $class->set_name('foo') };
ok ($err = $@, "Got an error trying to change name");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for class name");

# Test the description methods.
is( $class->get_desc, 'Special person class just for testing Class::Meta.',
    "Description is correct");
eval { $class->set_desc('foo') };
ok ($err = $@, "Got an error trying to change description");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for class description");

# Test my_attrs().
ok(my @attrs = $class->my_attrs, "Get attrs from my_attrs()" );
ok( $#attrs == 2, "Three attrs from my_attrs()" );
isa_ok($attrs[0], 'Class::Meta::Attribute', "First object is a attribute object" );
isa_ok($attrs[1], 'Class::Meta::Attribute', "Second object is a attribute object" );
isa_ok($attrs[2], 'Class::Meta::Attribute', "Third object is a attribute object" );

# Get specific attrerities.
ok( @attrs = $class->my_attrs(qw(age name)), 'Get specific attrs' );
ok( $#attrs == 1, "Two specific attrs from my_attrs()" );
isa_ok($attrs[0], 'Class::Meta::Attribute', "Attribute object type" );

is( $attrs[0]->get_name, 'age', 'First attr name' );
is( $attrs[1]->get_name, 'name', 'Second attr name' );

# Check the attributes of the "ID" attribute object.
ok( my $p = $class->my_attrs('id') );
is( $p->my_name, 'id', 'ID name' );
is( $p->my_desc, "The person object's ID.", 'ID description' );
ok( $p->my_vis == &Class::Meta::PUBLIC, 'ID visibility' );
ok( $p->my_auth == &Class::Meta::READ, 'ID authorization' );
is( $p->my_type, 'integer', 'ID type' );
ok( $p->my_len == 256, 'ID length' );
is( $p->my_label, 'ID', 'ID label' );
is( $p->my_field, 'text', 'ID field type' );
ok( $p->is_req, "ID required" );
ok( ! defined $p->my_def, "ID default" );
# Test the attribute accessors.
ok( ! defined $p->get_val($t), 'ID not defined' );
# ID is READ, so we shouldn't be able to set it.
eval{ $p->set_val($t, 10) };
ok( $err = $@, "Set val failure" );
like( $err, qr/attribute 'id' is read only/, 'set val exception' );

# Check the attributes of the "Name" attribute object.
ok( $p = $class->my_attrs('name') );
is( $p->my_name, 'name', 'Name name' );
is( $p->my_desc, "The person's name.", 'Name description' );
ok( $p->my_vis == &Class::Meta::PUBLIC, 'Name visibility' );
ok( $p->my_auth == &Class::Meta::RDWR, 'Name authorization' );
is( $p->my_type, 'string', 'Name type' );
ok( $p->my_len == 256, 'Name length' );
is( $p->my_label, 'Name', 'Name label' );
is( $p->my_field, 'text', 'Name field type' );
ok( $p->is_req, "Name required" );
ok( ! defined $p->my_def, "Name default" );
# Test the attribute accessors.
is( $p->get_val($t), 'David', 'Name get_val' );
ok( $p->set_val($t, 'Larry'), 'Name set_val' );
is( $p->get_val($t), 'Larry', 'New Name get_val' );
is( $t->get_name, 'Larry', 'Object get_name');
ok( $t->set_name('Damian'), 'Object set_name' );
is( $p->get_val($t), 'Damian', 'Final Name get_val' );

# Check the attributes of the "Age" attribute object.
ok( $p = $class->my_attrs('age') );
is( $p->my_name, 'age', 'Age name' );
is( $p->my_desc, "The person's age.", 'Age description' );
ok( $p->my_vis == &Class::Meta::PUBLIC, 'Age visibility' );
ok( $p->my_auth == &Class::Meta::RDWR, 'Age authorization' );
is( $p->my_type, 'integer', 'Age type' );
ok( $p->my_len == 256, 'Age length' );
is( $p->my_label, 'Age', 'Age label' );
is( $p->my_field, 'text', 'Age field type' );
ok( $p->is_req == 0, "Age required" );
ok( ! defined $p->my_def, "Age default" );
# Test the attribute accessors.
ok( ! defined $p->get_val($t), 'Age get_val' );
ok( $p->set_val($t, 10), 'Age set_val' );
is( $p->get_val($t), 10, 'New Age get_val' );
is( $t->get_age, 10, 'Object get_age');
ok( $t->set_age(22), 'Object set_age' );
is( $p->get_val($t), 22, 'Final Age get_val' );

# Test my_meths().
ok( my @meths = $class->my_meths );
ok( $#meths == 5, 'Number of methods from my_meths()' );
isa_ok($meths[0], 'Class::Meta::Method', "First object is a method object" );
isa_ok($meths[1], 'Class::Meta::Method', "Second object is a method object" );
isa_ok($meths[2], 'Class::Meta::Method', "Third object is a method object" );

# Check the order in which they're retruned.
is( $meths[0]->my_name, 'get_id', 'First method' );
is( $meths[1]->my_name, 'get_name', 'Second method' );
is( $meths[2]->my_name, 'set_name', 'Third method' );
is( $meths[3]->my_name, 'get_age', 'Fourth method' );
is( $meths[4]->my_name, 'set_age', 'Fifth method' );
is( $meths[5]->my_name, 'chk_pass', 'Sixth method' );

# Get a few specific methods.
ok( @meths = $class->my_meths(qw(set_name chk_pass set_age)),
    'Grab specific methods.');
ok( $#meths == 2, 'Three methods from my_meths()' );
is( $meths[0]->my_name, 'set_name', 'First specific method' );
is( $meths[1]->my_name, 'chk_pass', 'Second specific method' );
is( $meths[2]->my_name, 'set_age', 'Third specific method' );

# Check out the get_age and set_age methods.
ok( my $m = $class->my_meths('get_age'), 'Get get_age() method' );
is( $m->my_name, 'get_age', 'get_age name' );
ok( $m->call($t) == 22, 'Call get_age' );
ok( my $m2  = $class->my_meths('set_age'), 'Get set_age() method' );
is( $m2->my_name, 'set_age', 'set_age name' );
ok( $m2->call($t, 34), 'Call set_age method' );
ok( $m->call($t) == 34, 'get_age execute again' );

# Check out the chk_pass method.
ok( $m = $class->my_meths('chk_pass'));
is( $m->my_name, 'chk_pass', 'chk_pass name' );
ok( $m->call($t, 'larry', 'yrral') == 1, 'Call chk_pass returns true' );
ok( $m->call($t, 'larry', 'foo') == 0, 'Call chk_pass returns false' );
