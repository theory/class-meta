#!perl -w

# $Id: base.t,v 1.9 2003/11/21 23:50:04 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 93;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestPerson;
use strict;
use IO::Socket;
use Carp;

BEGIN {
    $SIG{__DIE__} = \&Carp::confess;
    main::use_ok( 'Class::Meta');
}

BEGIN {
    my $c = Class::Meta->new
      (key   => 'person',
       class => __PACKAGE__,
       name  => 'Class::Meta::TestPerson Class',
       desc  => 'Special person class just for testing Class::Meta.');

    # Add a constructor.
    $c->add_ctor( name => 'new',
                  create  => 1 );

    # Add a couple of attributes with created methods.
    $c->add_attr( name     => 'id',
                  view     => Class::Meta::PUBLIC,
                  authz    => Class::Meta::READ,
                  create   => Class::Meta::GET,
                  type     => 'integer',
                  label    => 'ID',
                  desc     => "The person object's ID.",
                  required => 1,
                  default  => undef,
                );
    $c->add_attr( name     => 'name',
                  view     => Class::Meta::PUBLIC,
                  authz    => Class::Meta::RDWR,
                  create   => Class::Meta::GETSET,
                  type     => 'string',
                  length      => 256,
                  label    => 'Name',
                  field    => 'text',
                  desc     => "The person's name.",
                  required => 1,
                  default  => '',
                );
    $c->add_attr( name     => 'age',
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
    $c->add_meth( name  => 'chk_pass',
                  view   => Class::Meta::PUBLIC,
                );

    $c->add_meth( name  => 'shame',
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
ok( my $class = $t->my_class, "Get Class::Meta::Class object" );

# Test the is_a() method.
ok( $class->is_a('Class::Meta::TestPerson'), 'Class is_a TestPerson');

# Test the key methods.
is( $class->my_key, 'person', 'Key is correct');

# Test the package methods.
is($class->my_package, 'Class::Meta::TestPerson', 'my_package()');
eval { $class->set_package('foo') };
ok ($err = $@, "Try to change pacakge");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for package name");

# Test the name methods.
is( $class->my_name, 'Class::Meta::TestPerson Class', "Name is correct");
eval { $class->set_name('foo') };
ok ($err = $@, "Got an error trying to change name");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for class name");

# Test the description methods.
is( $class->my_desc, 'Special person class just for testing Class::Meta.',
    "Description is correct");
eval { $class->set_desc('foo') };
ok ($err = $@, "Got an error trying to change description");
like( $err, qr/^Can't locate object method/,
      "Correct method not found exception for class description");

# Test my_attrs().
ok(my @attrs = $class->my_attrs, "Get attrs from my_attrs()" );
is( scalar @attrs, 3, "Three attrs from my_attrs()" );
isa_ok($attrs[0], 'Class::Meta::Attribute',
       "First object is a attribute object" );
isa_ok($attrs[1], 'Class::Meta::Attribute',
       "Second object is a attribute object" );
isa_ok($attrs[2], 'Class::Meta::Attribute',
       "Third object is a attribute object" );

# Get specific attributes.
ok( @attrs = $class->my_attrs(qw(age name)), 'Get specific attrs' );
is( scalar @attrs, 2, "Two specific attrs from my_attrs()" );
isa_ok($attrs[0], 'Class::Meta::Attribute', "Attribute object type" );

is( $attrs[0]->my_name, 'age', 'First attr name' );
is( $attrs[1]->my_name, 'name', 'Second attr name' );

# Check the attributes of the "ID" attribute object.
ok( my $p = $class->my_attrs('id'), "Get ID attribute object" );
is( $p->my_name, 'id', 'ID name' );
is( $p->my_desc, "The person object's ID.", 'ID description' );
is( $p->my_view, Class::Meta::PUBLIC, 'ID view' );
is( $p->my_authz, Class::Meta::READ, 'ID authorization' );
is( $p->my_type, 'integer', 'ID type' );
is( $p->my_length, undef, 'ID length' );
is( $p->my_label, 'ID', 'ID label' );
is( $p->my_field, undef, 'ID field type' );
ok( $p->is_required, "ID required" );
is( $p->my_default, undef, "ID default" );

# Test the attribute accessors.
ok( ! defined $p->call_get($t), 'ID not defined' );
# ID is READ, so we shouldn't be able to set it.
eval { $p->call_set($t, 10) };
ok( $err = $@, "Set val failure" );
like( $err, qr/Cannot set attribute 'id/, 'set val exception' );

# Check the attributes of the "Name" attribute object.
ok( $p = $class->my_attrs('name'), "Get name attribute" );
is( $p->my_name, 'name', 'Name name' );
is( $p->my_desc, "The person's name.", 'Name description' );
is( $p->my_view, Class::Meta::PUBLIC, 'Name view' );
is( $p->my_authz, Class::Meta::RDWR, 'Name authorization' );
is( $p->my_type, 'string', 'Name type' );
is( $p->my_length, 256, 'Name length' );
is( $p->my_label, 'Name', 'Name label' );
is( $p->my_field, 'text', 'Name field type' );
ok( $p->is_required, "Name required" );
is( $p->my_default, '', "Name default" );

# Test the attribute accessors.
is( $p->call_get($t), 'David', 'Name call_get' );
ok( $p->call_set($t, 'Larry'), 'Name call_set' );
is( $p->call_get($t), 'Larry', 'New Name call_get' );
is( $t->get_name, 'Larry', 'Object get_name');
ok( $t->set_name('Damian'), 'Object set_name' );
is( $p->call_get($t), 'Damian', 'Final Name call_get' );

# Check the attributes of the "Age" attribute object.
ok( $p = $class->my_attrs('age'), "Get age attribute" );
is( $p->my_name, 'age', 'Age name' );
is( $p->my_desc, "The person's age.", 'Age description' );
is( $p->my_view, Class::Meta::PUBLIC, 'Age view' );
is( $p->my_authz, Class::Meta::RDWR, 'Age authorization' );
is( $p->my_type, 'integer', 'Age type' );
is( $p->my_length, undef, 'Age length' );
is( $p->my_label, 'Age', 'Age label' );
is( $p->my_field, 'text', 'Age field type' );
ok( $p->is_required == 0, "Age required" );
is( $p->my_default, undef, "Age default" );

# Test the attribute accessors.
ok( ! defined $p->call_get($t), 'Age call_get' );
ok( $p->call_set($t, 10), 'Age call_set' );
is( $p->call_get($t), 10, 'New Age call_get' );
ok( $t->get_age == 10, 'Object get_age');
ok( $t->set_age(22), 'Object set_age' );
is( $p->call_get($t), 22, 'Final Age call_get' );

# Test my_meths().
ok( my @meths = $class->my_meths, "Get method objects" );
is( scalar @meths, 2, 'Number of methods from my_meths()' );
isa_ok($meths[0], 'Class::Meta::Method',
       "First object is a method object" );
isa_ok($meths[1], 'Class::Meta::Method',
       "Second object is a method object" );

# Check the order in which they're returned.
is( $meths[0]->my_name, 'chk_pass', 'First method' );
is( $meths[1]->my_name, 'shame', 'Second method' );

# Get a few specific methods.
ok( @meths = $class->my_meths(qw(shame chk_pass)),
    'Grab specific methods.');
is( scalar @meths, 2, 'Two methods from my_meths()' );
is( $meths[0]->my_name, 'shame', 'First specific method' );
is( $meths[1]->my_name, 'chk_pass', 'Second specific method' );

# Check out the chk_pass method.
ok( my $m = $class->my_meths('chk_pass'), "Get chk_pass method object" );
is( $m->my_name, 'chk_pass', 'chk_pass name' );
ok( $m->call($t, 'larry', 'yrral') == 1, 'Call chk_pass returns true' );
ok( $m->call($t, 'larry', 'foo') == 0, 'Call chk_pass returns false' );

__END__
