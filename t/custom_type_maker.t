#!/usr/bin/perl -w

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 85;
BEGIN { use_ok( 'Class::Meta::Type' ) }

my $prop = 'foo';
my $i = 0;
my ($set, $get);

##############################################################################
# Try creating a type with the bare minimum number of arguments.
ok( my $type = Class::Meta::Type->add
  ( name     => 'IO::Socket Object',
    desc     => 'IO::Socket object',
    key      => 'io_socket'
  ), "Create IO::Socket data type" );

is( $type, Class::Meta::Type->new('IO_Socket'), 'Check lc conversion on key' );
is( $type->get_key, 'io_socket', "Check io_socket key" );
is( $type->get_name, 'IO::Socket Object', "Check io_socket name" );
is( $type->get_desc, 'IO::Socket object', "Check io_socket desc" );
ok( ! defined $type->get_chk, "Check io_socket checker" );
ok( ! defined $type->get_conv, "Check io_socket conversion" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking io_socket set" );
is( ref $set, 'HASH', 'Io_socket set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Io_socket chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting io_socket set" );
is( ref $set, 'HASH', 'Io_socket set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Io_socket conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full io_socket set" );
is( ref $set, 'HASH', 'Full io_socket set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full io_socket set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make io_socket get" );
is( ref $get, 'HASH', 'Io_socket get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Io_socket get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check io_socket prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check io_socket prop_get" );

##############################################################################
# Try the same thing with undefs.
ok( $type = Class::Meta::Type->add
  ( name     => 'Bart Object',
    desc     => undef,
    key      => 'bart',
    chk      => undef,
    conv     => undef,
    set      => undef,
    get      => undef,
    prop_set => undef,
    prop_get => undef,
  ), "Create Bart data type" );

is( $type, Class::Meta::Type->new('Bart'), 'Check lc conversion on key' );
is( $type->get_key, 'bart', "Check bart key" );
is( $type->get_name, 'Bart Object', "Check bart name" );
ok( ! defined $type->get_desc, "Check bart desc" );
ok( ! defined $type->get_chk, "Check bart checker" );
ok( ! defined $type->get_conv, "Check bart conversion" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking bart set" );
is( ref $set, 'HASH', 'Bart set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Bart chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting bart set" );
is( ref $set, 'HASH', 'Bart set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Bart conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full bart set" );
is( ref $set, 'HASH', 'Full bart set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full bart set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make bart get" );
is( ref $get, 'HASH', 'Bart get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Bart get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check bart prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check bart prop_get" );

##############################################################################
# Now try one with the checker doing an isa() call.
ok( $type = Class::Meta::Type->add
  ( name     => 'FooBar Object',
    desc     => 'FooBar object',
    key      => 'foobar',
    chk      => 'FooBar'
  ), "Create FooBar data type" );

is( ref $type->get_chk, 'ARRAY', "Check foobar check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check foobar code');
}

##############################################################################
# Now create our own checker.
ok( $type = Class::Meta::Type->add
  ( name     => 'BarGoo Object',
    desc     => 'BarGoo object',
    key      => 'bargoo',
    chk      => sub { 'bargoo' }
  ), "Create BarGoo data type" );

is( ref $type->get_chk, 'ARRAY', "Check bargoo check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check bargoo code');
}

##############################################################################
# And then try an array of checkers.
ok( $type = Class::Meta::Type->add
  ( name     => 'Doh Object',
    desc     => 'Doh object',
    key      => 'doh',
    chk      => [sub { 'doh' }, sub { 'doh!' } ]
  ), "Create Doh data type" );

is( ref $type->get_chk, 'ARRAY', "Check doh check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check doh code');
}

##############################################################################
# And finally, pass in a bogus value for the chk parameter.
eval {
    $type = Class::Meta::Type->add
      ( name => 'Bogus',
	desc => 'Bogus',
	key  => 'bogus',
	chk  => { so => 'bogus' }
      )
};
ok(my $err = $@, "Error for bogus check");
like( $err, qr/Paremter 'chk' in call to add\(\) must be a code/,
      "Proper error for bogus check");


##############################################################################
# Okay, now try to trigger errors by not passing in required paramters.
eval { $type = Class::Meta::Type->add(name => 'foo') };
ok($err = $@, "Error for missing key");
like( $err, qr/Parameter 'key' is required/, "Proper error for missing key");

eval { $type = Class::Meta::Type->add(key => 'foo') };
ok($err = $@, "Error for missing name");
like( $err, qr/Parameter 'name' is required/, "Proper error for missing name");

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
    conv     => sub {'homey'}
  ), "Create Homer data type" );

is( ref $type->get_conv, 'CODE', "Check homer conv" );

##############################################################################
# And then a bogus conversion coderef.
eval {
    $type = Class::Meta::Type->add
      ( name => 'Bogus',
	desc => 'Bogus',
	key  => 'bogus',
	conv  => ['heh']
      )
};
ok($err = $@, "Error for bogus conv");
like( $err, qr/Paremter 'conv' in call to add\(\) must be a code/,
      "Proper error for bogus conv");

##############################################################################
# And finally, let's try some custom accessor code refs.
my $mk_set = sub {
    my ($prop, $chk) = @_;
    return { "foo_$prop" => sub {
	# Assign the value.
	$_[0]->{$prop} = $_[1];
    }};
};

my $mk_get = sub {
    my ($prop) = @_;
     return { "bar_$prop" => sub { $_[0]->{$prop} } };
};

ok( $type = Class::Meta::Type->add
  ( name     => 'Marge Object',
    desc     => 'Marge object',
    key      => 'marge',
    set      => $mk_set,
    get      => $mk_get,
    prop_set => sub { sub {} },
    prop_get => sub { sub {} }
  ), "Create Marge data type" );

is( $type->get_key, 'marge', "Check marge key" );
is( $type->get_name, 'Marge Object', "Check marge name" );
is( $type->get_desc, 'Marge object', "Check marge desc" );
ok( ! defined $type->get_chk, "Check marge checker" );
ok( ! defined $type->get_conv, "Check marge conversion" );
# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking Marge set" );
is( ref $set, 'HASH', 'Marge set with checks is hashref' );
is( ref $set->{'foo_' . $prop . $i}, 'CODE', "Marge chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting Marge set" );
is( ref $set, 'HASH', 'Marge set with conv is hashref' );
is( ref $set->{'foo_' . $prop . $i}, 'CODE', "Marge conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full Marge set" );
is( ref $set, 'HASH', 'Full Marge set is hashref' );
is( ref $set->{'foo_' . $prop . $i}, 'CODE', "Full Marge set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make Marge get" );
is( ref $get, 'HASH', 'Marge get is hashref' );
is( ref $get->{'bar_' . $prop . $i}, 'CODE', "Marge get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check marge prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check marge prop_get" );

