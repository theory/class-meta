#!/usr/bin/perl -w

# $Id: custom_type_maker.t,v 1.5 2003/11/21 21:21:07 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 85;
BEGIN { use_ok( 'Class::Meta::Type' ) }

my $attr = 'foo';
my $i = 0;
my ($set, $get);

##############################################################################
# Try creating a type with the bare minimum number of arguments.
ok( my $type = Class::Meta::Type->add
  ( name     => 'IO::Socket Object',
    desc     => 'IO::Socket object',
    key      => 'io_socket'
  ), "Create IO::Socket data type" );

is( $type, Class::Meta::Type->new('IO_Socket'),
    'Check lc conversion on key' );
is( $type->get_key, 'io_socket', "Check io_socket key" );
is( $type->get_name, 'IO::Socket Object', "Check io_socket name" );
is( $type->get_desc, 'IO::Socket object', "Check io_socket desc" );
ok( ! defined $type->get_check, "Check io_socket checker" );
ok( ! defined $type->get_converter, "Check io_socket conversion" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->get_check),
    "Make checking io_socket set" );
is( ref $set, 'HASH', 'Io_socket set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Io_socket check set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->get_converter),
    "Make converting io_socket set" );
is( ref $set, 'HASH', 'Io_socket set with converter is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE',
    "io_socket converter set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->get_check,
                           $type->get_converter),
    "Make full io_socket set" );
is( ref $set, 'HASH', 'Full io_socket set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full io_socket set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make io_socket get" );
is( ref $get, 'HASH', 'Io_socket get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Io_socket get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE',
    "Check io_socket attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE',
    "Check io_socket attr_get" );

##############################################################################
# Try the same thing with undefs.
ok( $type = Class::Meta::Type->add( name           => 'Bart Object',
                                    desc           => undef,
                                    key            => 'bart',
                                    check          => undef,
                                    converter      => undef,
                                    set_maker      => undef,
                                    get_maker      => undef,
                                    attr_set_maker => undef,
                                    attr_get_maker => undef,
                                ),
    "Create Bart data type" );

is( $type, Class::Meta::Type->new('Bart'), 'Check lc conversion on key' );
is( $type->get_key, 'bart', "Check bart key" );
is( $type->get_name, 'Bart Object', "Check bart name" );
ok( ! defined $type->get_desc, "Check bart desc" );
ok( ! defined $type->get_check, "Check bart checker" );
ok( ! defined $type->get_converter, "Check bart conversion" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->get_check),
    "Make checking bart set" );
is( ref $set, 'HASH', 'Bart set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Bart check set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->get_converter),
    "Make converting bart set" );
is( ref $set, 'HASH', 'Bart set with converter is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Bart converter set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->get_check,
                           $type->get_converter),
    "Make full bart set" );
is( ref $set, 'HASH', 'Full bart set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full bart set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make bart get" );
is( ref $get, 'HASH', 'Bart get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Bart get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check bart attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check bart attr_get" );

##############################################################################
# Now try one with the checker doing an isa() call.
ok( $type = Class::Meta::Type->add
  ( name     => 'FooBar Object',
    desc     => 'FooBar object',
    key      => 'foobar',
    check      => 'FooBar'
  ), "Create FooBar data type" );

is( ref $type->get_check, 'ARRAY', "Check foobar check" );
foreach my $check (@{ $type->get_check }) {
    is( ref $check, 'CODE', 'Check foobar code');
}

##############################################################################
# Now create our own checker.
ok( $type = Class::Meta::Type->add
  ( name     => 'BarGoo Object',
    desc     => 'BarGoo object',
    key      => 'bargoo',
    check      => sub { 'bargoo' }
  ), "Create BarGoo data type" );

is( ref $type->get_check, 'ARRAY', "Check bargoo check" );
foreach my $check (@{ $type->get_check }) {
    is( ref $check, 'CODE', 'Check bargoo code');
}

##############################################################################
# And then try an array of checkers.
ok( $type = Class::Meta::Type->add
  ( name     => 'Doh Object',
    desc     => 'Doh object',
    key      => 'doh',
    check      => [sub { 'doh' }, sub { 'doh!' } ]
  ), "Create Doh data type" );

is( ref $type->get_check, 'ARRAY', "Check doh check" );
foreach my $check (@{ $type->get_check }) {
    is( ref $check, 'CODE', 'Check doh code');
}

##############################################################################
# And finally, pass in a bogus value for the check parameter.
eval {
    $type = Class::Meta::Type->add
      ( name => 'Bogus',
        desc => 'Bogus',
        key  => 'bogus',
        check  => { so => 'bogus' }
      )
};
ok(my $err = $@, "Error for bogus check");
like( $err, qr/Paremter 'check' in call to add\(\) must be a code/,
      "Proper error for bogus check");


##############################################################################
# Okay, now try to trigger errors by not passing in required paramters.
eval { $type = Class::Meta::Type->add(name => 'foo') };
ok($err = $@, "Error for missing key");
like( $err, qr/Parameter 'key' is required/, "Proper error for missing key");

eval { $type = Class::Meta::Type->add(key => 'foo') };
ok($err = $@, "Error for missing name");
like( $err, qr/Parameter 'name' is required/,
      "Proper error for missing name");

##############################################################################
# Now try to create one that exists already.
eval { $type = Class::Meta::Type->add(name => 'string', key => 'string') };
ok($err = $@, "Error for duplicate key");
like( $err, qr/Type 'string' already defined/,
      "Proper error for duplicate key");

##############################################################################
# Now try a custom conversion coderef.
ok( $type = Class::Meta::Type->add
  ( name     => 'Homer Object',
    desc     => 'Homer object',
    key      => 'homer',
    converter     => sub {'homey'}
  ), "Create Homer data type" );

is( ref $type->get_converter, 'CODE', "Check homer converter" );

##############################################################################
# And then a bogus conversion coderef.
eval {
    $type = Class::Meta::Type->add
      ( name => 'Bogus',
        desc => 'Bogus',
        key  => 'bogus',
        converter  => ['heh']
      )
};
ok($err = $@, "Error for bogus converter");
like( $err, qr/Paremter 'converter' in call to add\(\) must be a code/,
      "Proper error for bogus converter");

##############################################################################
# And finally, let's try some custom accessor code refs.
my $make_set = sub {
    my ($attr, $check) = @_;
    return { "foo_$attr" => sub {
        # Assign the value.
        $_[0]->{$attr} = $_[1];
    }};
};

my $make_get = sub {
    my ($attr) = @_;
     return { "bar_$attr" => sub { $_[0]->{$attr} } };
};

ok( $type = Class::Meta::Type->add( name           => 'Marge Object',
                                    desc           => 'Marge object',
                                    key            => 'marge',
                                    set_maker      => $make_set,
                                    get_maker      => $make_get,
                                    attr_set_maker => sub { sub {} },
                                    attr_get_maker => sub { sub {} }
                                ),
    "Create Marge data type" );

is( $type->get_key, 'marge', "Check marge key" );
is( $type->get_name, 'Marge Object', "Check marge name" );
is( $type->get_desc, 'Marge object', "Check marge desc" );
ok( ! defined $type->get_check, "Check marge checker" );
ok( ! defined $type->get_converter, "Check marge conversion" );
# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->get_check),
    "Make checking Marge set" );
is( ref $set, 'HASH', 'Marge set with checks is hashref' );
is( ref $set->{'foo_' . $attr . $i}, 'CODE', "Marge check set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->get_converter),
    "Make converting Marge set" );
is( ref $set, 'HASH', 'Marge set with converter is hashref' );
is( ref $set->{'foo_' . $attr . $i}, 'CODE', "Marge converter set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->get_check,
                           $type->get_converter),
    "Make full Marge set" );
is( ref $set, 'HASH', 'Full Marge set is hashref' );
is( ref $set->{'foo_' . $attr . $i}, 'CODE', "Full Marge set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make Marge get" );
is( ref $get, 'HASH', 'Marge get is hashref' );
is( ref $get->{'bar_' . $attr . $i}, 'CODE', "Marge get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check marge attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check marge attr_get" );
