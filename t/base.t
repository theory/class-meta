#!/usr/bin/perl -w

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 4;
#BEGIN { use_ok( 'Class::Meta' ) }

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestPerson;
use strict;
use IO::Socket;
*ok = *main::ok;

BEGIN {
    main::use_ok( 'Class::Meta');
    my $c = Class::Meta->new(person => __PACKAGE__);
    $c->set_name('Class::Meta TestPerson Class');
    $c->set_desc('Special person class just for testing Class::Meta.');

    $c->add_prop({ name => 'id',
		   vis   => Class::Meta::READ,
		   type  => Class::Meta::INT,
		   label => 'ID',
		   desc  => "The person object's ID.",
		   req   => 1,
		   def   => undef,
		   gen   => Class::Meta::GET
    });
    $c->add_prop({ name  => 'name',
		   vis   => Class::Meta::RDWR,
		   type  => Class::Meta::STRING,
		   len   => 256,
		   label => 'Name',
		   field => Class::Meta::TEXT,
		   desc  => "The person's name.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
    });
    $c->add_prop({ name  => 'age',
		   vis   => Class::Meta::RDWR,
		   type  => Class::Meta::INT,
		   label => 'Age',
		   field => Class::Meta::TEXT,
		   desc  => "The person's age.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 },
    $c->build;
}


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
ok( my $err = $@, 'set_name to array ref croaks' );
like( $err, qr/^Value .* is not a string/, 'correct string exception' );

# Grab its metadata object.
ok( my $class = $t->my_class );

# Test the isa() method.
ok( $class->isa('Class::Meta::PersonTest'), 'Class isa PersonTest');

# Test the key methods.
is( $class->get_key, 'person', 'Key is correct');
eval { $class->set_key('foo') };
ok (my $err = $@, "Got an error trying to change key");
like( $err, qr/Can't locate object method/, "Shouln't be able to change key");

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
like( $er, qr/^Can't locate object method/,
      "Correct method not found exception for class description");
