#!/usr/bin/perl -w

# $Id: types.t,v 1.3 2002/05/11 22:18:17 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 4;
#BEGIN { use_ok( 'Class::Meta' ) }

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestTypes;
use strict;
use IO::Socket;
*ok = *main::ok;

BEGIN {
    main::use_ok( 'Class::Meta');
    my $c = Class::Meta->new(types => __PACKAGE__);
    $c->set_name('Class::Meta::TestTypes Class');
    $c->set_desc('Special class just for testing Class::Meta.');

    $c->add_attr({ name  => 'name',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'string',
		   len   => 256,
		   label => 'Name',
		   field => Class::Meta::TEXT,
		   desc  => "The person's name.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ name  => 'age',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'inteter',
		   label => 'Age',
		   field => Class::Meta::TEXT,
		   desc  => "The person's age.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'alive',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'bool',
		   label => 'Living',
		   field => Class::Meta::CHECKBOX,
		   desc  => "Is the person alive?",
		   req   => 0,
		   def   => 1,
		 });
    $c->add_attr({ attr  => 'whole',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'whole',
		   label => 'A whole number.',
		   field => Class::Meta::TEXT,
		   desc  => "A whole number.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'dec',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'decimal',
		   label => 'A decimal number.',
		   field => Class::Meta::TEXT,
		   desc  => "A decimal number.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'real',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'real',
		   label => 'A real number.',
		   field => Class::Meta::TEXT,
		   desc  => "A real number.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'float',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'float',
		   label => 'A float.',
		   field => Class::Meta::TEXT,
		   desc  => "A floating point number.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'scalar',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'scalar',
		   label => 'A scalar.',
		   field => Class::Meta::TEXT,
		   desc  => "A scalar reference.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'array',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'array',
		   label => 'A array.',
		   field => Class::Meta::TEXT,
		   desc  => "A array reference.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'hash',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'hash',
		   label => 'A hash.',
		   field => Class::Meta::TEXT,
		   desc  => "A hash reference.",
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'datetime',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'datetime',
		   label => 'date/time',
		   field => Class::Meta::TEXT,
		   desc  => 'A date/time attribute.',
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'io_socket',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'object',
		   label => 'An IO::Socket Object',
		   field => Class::Meta::TEXT,
		   desc  => 'An IO::Socket object.',
		   req   => 0,
		   def   => 'IO::Socket',
		   gen   => Class::Meta::GETSET
		 });
    $c->add_attr({ attr  => 'obj',
		   vis   => Class::Meta::PUBLIC,
		   type  => 'object',
		   label => 'An Object',
		   field => Class::Meta::TEXT,
		   desc  => 'An object.',
		   req   => 0,
		   def   => undef,
		   gen   => Class::Meta::GETSET
		 });
    $c->build;
}


##############################################################################
# Do the tests.
##############################################################################

package main;
# Instantiate a base class object and test its accessors.
ok( my $t = Class::Meta::TestTypes->new, 'Class::Meta::TestTypes->new');

# Grab its metadata object.
ok( my $class = $t->my_class );

# Test the isa() method.
is( $class->isa('Class::Meta::TestTypes'), 'Class isa TestTypes');

# Test the key methods.
is( $class->get_key, 'types', 'Key is correct');

# Test the name method.
is( $class->get_name, 'Class::Meta TestTypes Class', "Name is correct");

# Test the description methods.
is( $class->get_desc, 'Special class just for testing Class::Meta.',
    "Description is correct");

# Test string.
ok( $t->set_name('David'), 'set_name to "David"' );
is( $t->get_name, 'David', 'get_name is "David"' );
eval { $t->set_name([]) };
ok( my $err = $@, 'set_name to array ref croaks' );
like( $err, qr/^Value .* is not a string/, 'correct string exception' );

# Test boolean.
ok( $k->is_alive, 'is_alive true');
is( $k->set_alive_off, 0, 'set_alive_off');
ok( !$k->is_alive, 'is_alive false');
ok( $k->set_alive_on, 'set_alive_on' );
ok( $k->is_alive, 'is_alive true again');

# Test whole number.
eval { $k->set_whole(0) };
ok( $err = $@, 'set_whole to 0 croaks' );
like( $err, qr/^Value '0' is not a whole number/,
     'correct whole number exception' );
ok( $k->set_whole(1), 'set_whole to 1.');

# Test integer.
eval { $k->set_age(0.5) };
ok( $err = $@, 'set_age to 0.5 croaks');
like( $err, qr/^Value '0\.5' is not an integer/,
     'correct integer exception' );
ok( $k->set_age(10), 'set_age to 10.');

# Test decimal.
eval { $k->set_dec('+') };
ok( $err = $@, 'set_dec to "+" croaks');
like( $err, qr/^Value '\+' is not a decimal number/,
     'correct decimal exception' );
ok( $k->set_dec(3.14), 'set_dec to 3.14.');

# Test real.
eval { $k->set_real('+') };
ok( $err = $@, 'set_real to "+" croaks');
like( $err, qr/^Value '\+' is not a real number/,
     'correct real exception' );
ok( $k->set_real(123.4567), 'set_real to 123.4567.');
pok( $k->set_real(-123.4567), 'set_real to -123.4567.');

# Test float.
eval { $k->set_float('+') };
ok( $err = $@, 'set_float to "+" croaks');
like( $err, qr/^Value '\+' is not a floating point number/,
     'correct float exception' );
ok( $k->set_float(1.23e99), 'set_float to 1.23e99.');

# Test Date/Time.
eval { $k->set_datetime('foo') };
ok( $err = $@, 'set_datetime to "foo" croaks' );
like( $err, qr/^Error parsing date\/time/,
     'correct date/time exception' );

ok( $k->set_datetime('2001-12-14T17:57:37'),
    'set_datetime to "2001-12-14T17:57:37".');
ok( $k->set_datetime("Sun 3rd Nov, 1943", "%A %drd %b, %Y"),
    'set_datetime to "Sun 3rd Nov, 1943"' );
isa_ok( $k->get_datetime, 'Time::Piece');
is($k->get_datetime("%a, %d %b %Y"), 'Wed, 03 Nov 1943',
  'date_time is correct');

# Test OBJECT with default specifying object type.
ok( my $io = $k->get_io_socket, 'get_io_socket' );
isa_ok($io, 'IO::Socket');
eval { $k->set_io_socket('foo') };
ok( $err = $@, 'set_io_socket to "foo" croaks' );
like( $err, qr/^Value 'foo' is not an object/,
     'correct object exception' );
my $fh = FileHandle->new;
eval { $k->set_io_socket($fh) };
ok( $err = $@, 'set_io_socket to \$fh croaks' );
like( $err, qr/^Value '.*' is not an object of type 'IO::Socket'/,
     'correct object exception' );
ok( $k->set_io_socket($io), 'set_io_socket to \$io.');

# Test OBJECT with no default -- any object type is okay.
eval { $k->set_obj('foo') };
ok( $err = $@, 'set_obj to "foo" croaks' );
like( $err, qr/^Value 'foo' is not an object/,
     'correct generic object exception' );
eval { $k->set_obj([]) };
ok( $err = $@, 'set_obj to [] croaks' );
like( $err, qr/^Value '.*' is not an object/,
     'correct second generic object exception' );
ok( $k->set_obj($fh), 'set_obj to \$fh.');

# Test SCALAR.
eval { $k->set_scalar('foo') };
ok( $err = $@, 'set_scalar to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a scalar/,
     'correct scalar exception' );
ok( $k->set_scalar(\"foo"), 'set_scalar to \\"foo".');

# Test ARRAY.
eval { $k->set_array('foo') };
ok( $err = $@, 'set_array to "foo" croaks' );
like( $err, qr/^Value 'foo' is not an array/,
     'correct array exception' );
ok( $k->set_array(["foo"]), 'set_array to ["foo"].');

# Test HASH.
eval { $k->set_hash('foo') };
ok( $err = $@, 'set_hash to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a hash/,
     'correct hash exception' );
ok( $k->set_hash({ foo => 1 }), 'set_hash to { foo => 1 }.');


