#!/usr/bin/perl -w

# $Id: types.t,v 1.5 2003/11/22 01:45:47 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 56;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestTypes;
use strict;
use IO::Socket;

BEGIN {
    $SIG{__DIE__} = \&Carp::confess;
    main::use_ok( 'Class::Meta');
    main::use_ok( 'Class::Meta::Type');
}

BEGIN {
    # Add the new data type.
    Class::Meta::Type->add( key       => 'io_handle',
                            name      => 'IO Handle',
                            desc      => 'An IO::Handle object.',
                            check     => 'IO::Handle',
                            converter => sub { IO::Handle->new }
                        );

    my $c = Class::Meta->new(class => __PACKAGE__,
                             key   => 'types',
                             name  => 'Class::Meta::TestTypes Class',
                             desc  => 'Just for testing Class::Meta.'
                         );
    $c->add_ctor(name => 'new');

    $c->add_attr( name  => 'name',
                  view   => Class::Meta::PUBLIC,
                  type  => 'string',
                  length   => 256,
                  label => 'Name',
                  field => 'text',
                  desc  => "The person's name.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'age',
                  view   => Class::Meta::PUBLIC,
                  type  => 'integer',
                  label => 'Age',
                  field => 'text',
                  desc  => "The person's age.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'alive',
                  view   => Class::Meta::PUBLIC,
                  type  => 'bool',
                  label => 'Living',
                  field => 'checkbox',
                  desc  => "Is the person alive?",
                  required   => 0,
                  default   => 1,
              );
    $c->add_attr( name  => 'whole',
                  view   => Class::Meta::PUBLIC,
                  type  => 'whole',
                  label => 'A whole number.',
                  field => 'text',
                  desc  => "A whole number.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'dec',
                  view   => Class::Meta::PUBLIC,
                  type  => 'decimal',
                  label => 'A decimal number.',
                  field => 'text',
                  desc  => "A decimal number.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'real',
                  view   => Class::Meta::PUBLIC,
                  type  => 'real',
                  label => 'A real number.',
                  field => 'text',
                  desc  => "A real number.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'float',
                  view   => Class::Meta::PUBLIC,
                  type  => 'float',
                  label => 'A float.',
                  field => 'text',
                  desc  => "A floating point number.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'scalar',
                  view   => Class::Meta::PUBLIC,
                  type  => 'scalarref',
                  label => 'A scalar.',
                  field => 'text',
                  desc  => "A scalar reference.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'array',
                  view   => Class::Meta::PUBLIC,
                  type  => 'array',
                  label => 'A array.',
                  field => 'text',
                  desc  => "A array reference.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'hash',
                  view   => Class::Meta::PUBLIC,
                  type  => 'hash',
                  label => 'A hash.',
                  field => 'text',
                  desc  => "A hash reference.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'datetime',
                  view   => Class::Meta::PUBLIC,
                  type  => 'datetime',
                  label => 'date/time',
                  field => 'text',
                  desc  => 'A date/time attribute.',
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'io_handle',
                  view   => Class::Meta::PUBLIC,
                  type  => 'io_handle',
                  label => 'An IO::Handle Object',
                  field => 'text',
                  desc  => 'An IO::Handle object.',
                  required   => 0,
                  default => sub { IO::Handle->new },
                  create   => Class::Meta::GETSET
              );
    $c->build;
}


##############################################################################
# Do the tests.
##############################################################################

package main;
# Instantiate a base class object and test its accessors.
ok( my $t = Class::Meta::TestTypes->new, 'Class::Meta::TestTypes->new');

# Grab its metadata object.
ok( my $class = $t->my_class, "Get the Class::Meta::Class object" );

# Test the is_a() method.
ok( $class->is_a('Class::Meta::TestTypes'), 'Class isa TestTypes');

# Test the key methods.
is( $class->my_key, 'types', 'Key is correct');

# Test the name method.
is( $class->my_name, 'Class::Meta::TestTypes Class', "Name is correct");

# Test the description methods.
is( $class->my_desc, 'Just for testing Class::Meta.',
    "Description is correct");

# Test string.
ok( $t->set_name('David'), 'set_name to "David"' );
is( $t->get_name, 'David', 'get_name is "David"' );
eval { $t->set_name([]) };
ok( my $err = $@, 'set_name to array ref croaks' );
like( $err, qr/^Value .* is not a valid string/, 'correct string exception' );

# Test boolean.
ok( $t->is_alive, 'is_alive true');
is( $t->set_alive_off, 0, 'set_alive_off');
ok( !$t->is_alive, 'is_alive false');
ok( $t->set_alive_on, 'set_alive_on' );
ok( $t->is_alive, 'is_alive true again');

# Test whole number.
eval { $t->set_whole(0) };
ok( $err = $@, 'set_whole to 0 croaks' );
like( $err, qr/^Value '0' is not a valid whole number/,
     'correct whole number exception' );
ok( $t->set_whole(1), 'set_whole to 1.');

# Test integer.
eval { $t->set_age(0.5) };
ok( $err = $@, 'set_age to 0.5 croaks');
like( $err, qr/^Value '0\.5' is not a valid integer/,
     'correct integer exception' );
ok( $t->set_age(10), 'set_age to 10.');

# Test decimal.
eval { $t->set_dec('+') };
ok( $err = $@, 'set_dec to "+" croaks');
like( $err, qr/^Value '\+' is not a valid decimal number/,
     'correct decimal exception' );
ok( $t->set_dec(3.14), 'set_dec to 3.14.');

# Test real.
eval { $t->set_real('+') };
ok( $err = $@, 'set_real to "+" croaks');
like( $err, qr/^Value '\+' is not a valid real number/,
     'correct real exception' );
ok( $t->set_real(123.4567), 'set_real to 123.4567.');
ok( $t->set_real(-123.4567), 'set_real to -123.4567.');

# Test float.
eval { $t->set_float('+') };
ok( $err = $@, 'set_float to "+" croaks');
like( $err, qr/^Value '\+' is not a valid floating point number/,
     'correct float exception' );
ok( $t->set_float(1.23e99), 'set_float to 1.23e99.');

# Test Date/Time.
eval { $t->set_datetime('foo') };
ok( $err = $@, 'set_datetime to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a valid DateTime/,
     'correct DateTime exception' );

ok( $t->set_datetime(DateTime->now), 'set_datetime to now.');
isa_ok( $t->get_datetime, 'DateTime');

# Test OBJECT with default specifying object type.
ok( my $io = $t->get_io_handle, 'get_io_handle' );
isa_ok($io, 'IO::Handle');
eval { $t->set_io_handle('foo') };
ok( $err = $@, 'set_io_handle to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a valid IO Handle/,
     'correct object exception' );

# Try a wrong object.
eval { $t->set_io_handle($t) };
ok( $err = $@, 'set_io_handle to \$fh croaks' );
like( $err, qr/^Value '.*' is not a valid IO Handle/,
     'correct object exception' );
ok( $t->set_io_handle($io), 'set_io_handle to \$io.');

# Try a subclass.
my $sock = IO::Socket->new;
ok( $t->set_io_handle($sock), "Set io_handle to a subclass." );
isa_ok($t->get_io_handle, 'IO::Socket', "Check subclass" );
ok( $t->set_io_handle($io), 'set_io_handle to \$io.');

# Test SCALAR.
eval { $t->set_scalar('foo') };
ok( $err = $@, 'set_scalar to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a valid scalar reference/,
     'correct scalar exception' );
ok( $t->set_scalar(\"foo"), 'set_scalar to \\"foo".');

# Test ARRAY.
eval { $t->set_array('foo') };
ok( $err = $@, 'set_array to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a valid array reference/,
     'correct array exception' );
ok( $t->set_array(["foo"]), 'set_array to ["foo"].');

# Test HASH.
eval { $t->set_hash('foo') };
ok( $err = $@, 'set_hash to "foo" croaks' );
like( $err, qr/^Value 'foo' is not a valid hash reference/,
     'correct hash exception' );
ok( $t->set_hash({ foo => 1 }), 'set_hash to { foo => 1 }.');
