#!/usr/bin/perl -w

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 322;
BEGIN { use_ok( 'Class::Meta::Type' ) }

my $prop = 'foo';
my $i = 0;

##############################################################################
# Check string data type.
ok( my $type = Class::Meta::Type->new('string'), 'Get string' );
is( $type, Class::Meta::Type->new('STRING'), 'Check lc conversion on key' );
is( $type->get_key, 'string', "Check string key" );
is( $type->get_name, 'String', "Check string name" );
is( $type->get_desc, 'String', "Check string desc" );
is( ref $type->get_chk, 'ARRAY', "Check string check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check string code');
}
is( ref $type->get_conv, 'CODE', "Check string conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( my $set = $type->mk_set($prop . ++$i), "Make simple string set" );
is( ref $set, 'HASH', 'Simple string set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "String set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking string set" );
is( ref $set, 'HASH', 'String set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "String chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting string set" );
is( ref $set, 'HASH', 'String set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "String conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full string set" );
is( ref $set, 'HASH', 'Full string set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full string set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( my $get = $type->mk_get($prop . $i), "Make string get" );
is( ref $get, 'HASH', 'String get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "String get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check string prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check string prop_get" );
##############################################################################
# Check boolean data type.
ok( $type = Class::Meta::Type->new('boolean'), 'Get boolean' );
is( $type, Class::Meta::Type->new('bool'), 'Check bool alias' );
is( $type->get_key, 'boolean', "Check boolean key" );
is( $type->get_name, 'Boolean', "Check boolean name" );
is( $type->get_desc, 'Boolean', "Check boolean desc" );
# Boolean is special -- it has no converter or checkers.
ok( ! defined $type->get_chk, "Check boolean check" );
ok( ! defined $type->get_conv, "Check boolean conversion" );

# Check to make sure that the set_ method codrefs area created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple boolean set" );
is( ref $set, 'HASH', 'Simple boolean set is hashref' );
is( ref $set->{'set_' . $prop . $i . '_on'}, 'CODE',
    "Boolean set_on coderef" );
is( ref $set->{'set_' . $prop . $i . '_off'}, 'CODE',
    "Boolean set_off coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking boolean set" );
is( ref $set, 'HASH', 'Boolean set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i . '_on'}, 'CODE',
    "Boolean chk set on coderef" );
is( ref $set->{'set_' . $prop . $i . '_off'}, 'CODE',
    "Boolean chk set off coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting boolean set" );
is( ref $set, 'HASH', 'Boolean set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i . '_on'}, 'CODE',
    "Boolean conv set on coderef" );
is( ref $set->{'set_' . $prop . $i . '_off'}, 'CODE',
    "Boolean conv set off coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full boolean set" );
is( ref $set, 'HASH', 'Full boolean set is hashref' );
is( ref $set->{'set_' . $prop . $i . '_on'}, 'CODE',
    "Full boolean set on coderef" );
is( ref $set->{'set_' . $prop . $i . '_off'}, 'CODE',
    "Full boolean set off coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make boolean get" );
is( ref $get, 'HASH', 'Boolean get is hashref' );
is( ref $get->{'is_' . $prop . $i}, 'CODE', "Boolean get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check boolean prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check boolean prop_get" );

##############################################################################
# Check whole data type.
ok( $type = Class::Meta::Type->new('whole'), 'Get whole' );
is( $type->get_key, 'whole', "Check whole key" );
is( $type->get_name, 'Whole Number', "Check whole name" );
is( $type->get_desc, 'Whole number', "Check whole desc" );
is( ref $type->get_chk, 'ARRAY', "Check whole check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check whole code');
}
is( ref $type->get_conv, 'CODE', "Check whole conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple whole set" );
is( ref $set, 'HASH', 'Simple whole set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Whole set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking whole set" );
is( ref $set, 'HASH', 'Whole set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Whole chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting whole set" );
is( ref $set, 'HASH', 'Whole set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Whole conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full whole set" );
is( ref $set, 'HASH', 'Full whole set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full whole set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make whole get" );
is( ref $get, 'HASH', 'Whole get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Whole get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check whole prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check whole prop_get" );

##############################################################################
# Check integer data type.
ok( $type = Class::Meta::Type->new('integer'), 'Get integer' );
is( $type, Class::Meta::Type->new('int'), 'Check int alias' );
is( $type->get_key, 'integer', "Check integer key" );
is( $type->get_name, 'Integer', "Check integer name" );
is( $type->get_desc, 'Integer', "Check integer desc" );
is( ref $type->get_chk, 'ARRAY', "Check integer check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check integer code');
}
is( ref $type->get_conv, 'CODE', "Check integer conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple integer set" );
is( ref $set, 'HASH', 'Simple integer set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Integer set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking integer set" );
is( ref $set, 'HASH', 'Integer set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Integer chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting integer set" );
is( ref $set, 'HASH', 'Integer set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Integer conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full integer set" );
is( ref $set, 'HASH', 'Full integer set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full integer set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make integer get" );
is( ref $get, 'HASH', 'Integer get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Integer get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check integer prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check integer prop_get" );

##############################################################################
# Check decimal data type.
ok( $type = Class::Meta::Type->new('decimal'), 'Get decimal' );
is( $type, Class::Meta::Type->new('dec'), 'Check dec alias' );
is( $type->get_key, 'decimal', "Check decimal key" );
is( $type->get_name, 'Decimal Number', "Check decimal name" );
is( $type->get_desc, 'Decimal number', "Check decimal desc" );
is( ref $type->get_chk, 'ARRAY', "Check decimal check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check decimal code');
}
is( ref $type->get_conv, 'CODE', "Check decimal conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple decimal set" );
is( ref $set, 'HASH', 'Simple decimal set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Decimal set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking decimal set" );
is( ref $set, 'HASH', 'Decimal set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Decimal chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting decimal set" );
is( ref $set, 'HASH', 'Decimal set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Decimal conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full decimal set" );
is( ref $set, 'HASH', 'Full decimal set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full decimal set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make decimal get" );
is( ref $get, 'HASH', 'Decimal get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Decimal get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check decimal prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check decimal prop_get" );

##############################################################################
# Check real data type.
ok( $type = Class::Meta::Type->new('real'), 'Get real' );
is( $type->get_key, 'real', "Check real key" );
is( $type->get_name, 'Real Number', "Check real name" );
is( $type->get_desc, 'Real number', "Check real desc" );
is( ref $type->get_chk, 'ARRAY', "Check real check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check real code');
}
is( ref $type->get_conv, 'CODE', "Check real conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple real set" );
is( ref $set, 'HASH', 'Simple real set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Real set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking real set" );
is( ref $set, 'HASH', 'Real set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Real chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting real set" );
is( ref $set, 'HASH', 'Real set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Real conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full real set" );
is( ref $set, 'HASH', 'Full real set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full real set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make real get" );
is( ref $get, 'HASH', 'Real get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Real get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check real prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check real prop_get" );

##############################################################################
# Check float data type.
ok( $type = Class::Meta::Type->new('float'), 'Get float' );
is( $type->get_key, 'float', "Check float key" );
is( $type->get_name, 'Floating Point Number', "Check float name" );
is( $type->get_desc, 'Floating point number', "Check float desc" );
is( ref $type->get_chk, 'ARRAY', "Check float check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check float code');
}
is( ref $type->get_conv, 'CODE', "Check float conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple float set" );
is( ref $set, 'HASH', 'Simple float set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Float set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking float set" );
is( ref $set, 'HASH', 'Float set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Float chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting float set" );
is( ref $set, 'HASH', 'Float set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Float conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full float set" );
is( ref $set, 'HASH', 'Full float set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full float set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make float get" );
is( ref $get, 'HASH', 'Float get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Float get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check float prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check float prop_get" );

##############################################################################
# Check scalar data type.
ok( $type = Class::Meta::Type->new('scalar'), 'Get scalar' );
is( $type->get_key, 'scalar', "Check scalar key" );
is( $type->get_name, 'Scalar', "Check scalar name" );
is( $type->get_desc, 'Scalar', "Check scalar desc" );
# Scalars aren't validated or convted.
ok( ! defined $type->get_chk, "Check scalar check" );
ok( ! defined $type->get_conv, "Check scalar conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple scalar set" );
is( ref $set, 'HASH', 'Simple scalar set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking scalar set" );
is( ref $set, 'HASH', 'Scalar set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting scalar set" );
is( ref $set, 'HASH', 'Scalar set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full scalar set" );
is( ref $set, 'HASH', 'Full scalar set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full scalar set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make scalar get" );
is( ref $get, 'HASH', 'Scalar get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Scalar get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check scalar prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check scalar prop_get" );

##############################################################################
# Check scalar reference data type.
ok( $type = Class::Meta::Type->new('scalarref'), 'Get scalar ref' );
is( $type->get_key, 'scalarref', "Check scalar ref key" );
is( $type->get_name, 'Scalar Reference', "Check scalar ref name" );
is( $type->get_desc, 'Scalar reference', "Check scalar ref desc" );
is( ref $type->get_chk, 'ARRAY', "Check scalar ref check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check scalar ref code');
}
is( ref $type->get_conv, 'CODE', "Check scalar ref conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple scalar ref set" );
is( ref $set, 'HASH', 'Simple scalar ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar Ref set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking scalar ref set" );
is( ref $set, 'HASH', 'Scalar Ref set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting scalar ref set" );
is( ref $set, 'HASH', 'Scalar Ref set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Scalar Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full scalar ref set" );
is( ref $set, 'HASH', 'Full scalar ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full scalar ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make scalar ref get" );
is( ref $get, 'HASH', 'Scalar Ref get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Scalar Ref get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check scalar ref prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check scalar ref prop_get" );

##############################################################################
# Check array data type.
ok( $type = Class::Meta::Type->new('array'), 'Get array' );
is( $type, Class::Meta::Type->new('arrayref'), 'Check arrayref alias' );
is( $type->get_key, 'array', "Check array key" );
is( $type->get_name, 'Array Reference', "Check array name" );
is( $type->get_desc, 'Array reference', "Check array desc" );
is( ref $type->get_chk, 'ARRAY', "Check array check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check array code');
}
is( ref $type->get_conv, 'CODE', "Check array conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple array ref set" );
is( ref $set, 'HASH', 'Simple array ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Array Ref set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking array ref set" );
is( ref $set, 'HASH', 'Array Ref set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Array Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting array ref set" );
is( ref $set, 'HASH', 'Array Ref set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Array Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full array ref set" );
is( ref $set, 'HASH', 'Full array ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full array ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make array ref get" );
is( ref $get, 'HASH', 'Array Ref get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Array Ref get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check array prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check array prop_get" );

##############################################################################
# Check hash data type.
ok( $type = Class::Meta::Type->new('hash'), 'Get hash' );
is( $type, Class::Meta::Type->new('hashref'), 'Check hashref alias' );
is( $type->get_key, 'hash', "Check hash key" );
is( $type->get_name, 'Hash Reference', "Check hash name" );
is( $type->get_desc, 'Hash reference', "Check hash desc" );
is( ref $type->get_chk, 'ARRAY', "Check hash check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check hash code');
}
is( ref $type->get_conv, 'CODE', "Check hash conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple hash ref set" );
is( ref $set, 'HASH', 'Simple hash ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Hash Ref set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking hash ref set" );
is( ref $set, 'HASH', 'Hash Ref set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Hash Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting hash ref set" );
is( ref $set, 'HASH', 'Hash Ref set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Hash Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full hash ref set" );
is( ref $set, 'HASH', 'Full hash ref set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full hash ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make hash ref get" );
is( ref $get, 'HASH', 'Hash Ref get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Hash Ref get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check hash prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check hash prop_get" );

##############################################################################
# Check code data type.
ok( $type = Class::Meta::Type->new('code'), 'Get code' );
is( $type, Class::Meta::Type->new('coderef'), 'Check coderef alias' );
is( $type->get_key, 'code', "Check code key" );
is( $type->get_name, 'Code Reference', "Check code name" );
is( $type->get_desc, 'Code reference', "Check code desc" );
is( ref $type->get_chk, 'ARRAY', "Check code check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check code code');
}
is( ref $type->get_conv, 'CODE', "Check code conversion" );
# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple code set" );
is( ref $set, 'HASH', 'Simple code set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Code set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking code set" );
is( ref $set, 'HASH', 'Code set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Code chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting code set" );
is( ref $set, 'HASH', 'Code set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Code conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full code set" );
is( ref $set, 'HASH', 'Full code set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full code set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make code get" );
is( ref $get, 'HASH', 'Code get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Code get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check code prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check code prop_get" );

##############################################################################
# Check datetime data type.
ok( $type = Class::Meta::Type->new('datetime'), 'Get datetime' );
is( $type->get_key, 'datetime', "Check datetime key" );
is( $type->get_name, 'Date/Time', "Check datetime name" );
is( $type->get_desc, 'Date/Time', "Check datetime desc" );
is( ref $type->get_chk, 'ARRAY', "Check datetime check" );
foreach my $chk (@{ $type->get_chk }) {
    is( ref $chk, 'CODE', 'Check datetime code');
}
is( ref $type->get_conv, 'CODE', "Check datetime conversion" );
# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->mk_set($prop . ++$i), "Make simple datetime set" );
is( ref $set, 'HASH', 'Simple datetime set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Datetime set coderef" );

# Now check with checks added.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk),
    "Make checking datetime set" );
is( ref $set, 'HASH', 'Datetime set with checks is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Datetime chk set coderef" );

# Now check with a conversion.
ok( $set = $type->mk_set($prop . ++$i, undef, $type->get_conv),
    "Make converting datetime set" );
is( ref $set, 'HASH', 'Datetime set with conv is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Datetime conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->mk_set($prop . ++$i, $type->get_chk, $type->get_conv),
    "Make full datetime set" );
is( ref $set, 'HASH', 'Full datetime set is hashref' );
is( ref $set->{'set_' . $prop . $i}, 'CODE', "Full datetime set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->mk_get($prop . $i), "Make datetime get" );
is( ref $get, 'HASH', 'Datetime get is hashref' );
is( ref $get->{'get_' . $prop . $i}, 'CODE', "Datetime get coderef" );

# And finally, check to make sure that the Property class accessor coderefs
# are getting created.
is( ref $type->mk_prop_set($prop . $i), 'CODE', "Check datetime prop_set" );
is( ref $type->mk_prop_get($prop . $i), 'CODE', "Check datetime prop_get" );
