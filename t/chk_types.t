#!/usr/bin/perl -w

# $Id: chk_types.t,v 1.4 2003/11/21 23:53:24 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 322;
BEGIN { use_ok( 'Class::Meta::Type' ) }

my $attr = 'foo';
my $i = 0;

##############################################################################
# Check string data type.
ok( my $type = Class::Meta::Type->new('string'), 'Get string' );
is( $type, Class::Meta::Type->new('STRING'), 'Check lc conversion on key' );
is( $type->key, 'string', "Check string key" );
is( $type->name, 'String', "Check string name" );
is( $type->desc, 'String', "Check string desc" );
is( ref $type->check, 'ARRAY', "Check string check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check string code');
}
is( ref $type->converter, 'CODE', "Check string conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( my $set = $type->make_set($attr . ++$i), "Make simple string set" );
is( ref $set, 'HASH', 'Simple string set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "String set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking string set" );
is( ref $set, 'HASH', 'String set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "String chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting string set" );
is( ref $set, 'HASH', 'String set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "String conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full string set" );
is( ref $set, 'HASH', 'Full string set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full string set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( my $get = $type->make_get($attr . $i), "Make string get" );
is( ref $get, 'HASH', 'String get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "String get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check string attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check string attr_get" );
##############################################################################
# Check boolean data type.
ok( $type = Class::Meta::Type->new('boolean'), 'Get boolean' );
is( $type, Class::Meta::Type->new('bool'), 'Check bool alias' );
is( $type->key, 'boolean', "Check boolean key" );
is( $type->name, 'Boolean', "Check boolean name" );
is( $type->desc, 'Boolean', "Check boolean desc" );
# Boolean is special -- it has no converter or checkers.
ok( ! defined $type->check, "Check boolean check" );
ok( ! defined $type->converter, "Check boolean conversion" );

# Check to make sure that the set_ method codrefs area created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple boolean set" );
is( ref $set, 'HASH', 'Simple boolean set is hashref' );
is( ref $set->{'set_' . $attr . $i . '_on'}, 'CODE',
    "Boolean set_on coderef" );
is( ref $set->{'set_' . $attr . $i . '_off'}, 'CODE',
    "Boolean set_off coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking boolean set" );
is( ref $set, 'HASH', 'Boolean set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i . '_on'}, 'CODE',
    "Boolean chk set on coderef" );
is( ref $set->{'set_' . $attr . $i . '_off'}, 'CODE',
    "Boolean chk set off coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting boolean set" );
is( ref $set, 'HASH', 'Boolean set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i . '_on'}, 'CODE',
    "Boolean conv set on coderef" );
is( ref $set->{'set_' . $attr . $i . '_off'}, 'CODE',
    "Boolean conv set off coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full boolean set" );
is( ref $set, 'HASH', 'Full boolean set is hashref' );
is( ref $set->{'set_' . $attr . $i . '_on'}, 'CODE',
    "Full boolean set on coderef" );
is( ref $set->{'set_' . $attr . $i . '_off'}, 'CODE',
    "Full boolean set off coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make boolean get" );
is( ref $get, 'HASH', 'Boolean get is hashref' );
is( ref $get->{'is_' . $attr . $i}, 'CODE', "Boolean get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check boolean attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check boolean attr_get" );

##############################################################################
# Check whole data type.
ok( $type = Class::Meta::Type->new('whole'), 'Get whole' );
is( $type->key, 'whole', "Check whole key" );
is( $type->name, 'Whole Number', "Check whole name" );
is( $type->desc, 'Whole number', "Check whole desc" );
is( ref $type->check, 'ARRAY', "Check whole check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check whole code');
}
is( ref $type->converter, 'CODE', "Check whole conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple whole set" );
is( ref $set, 'HASH', 'Simple whole set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Whole set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking whole set" );
is( ref $set, 'HASH', 'Whole set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Whole chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting whole set" );
is( ref $set, 'HASH', 'Whole set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Whole conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full whole set" );
is( ref $set, 'HASH', 'Full whole set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full whole set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make whole get" );
is( ref $get, 'HASH', 'Whole get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Whole get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check whole attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check whole attr_get" );

##############################################################################
# Check integer data type.
ok( $type = Class::Meta::Type->new('integer'), 'Get integer' );
is( $type, Class::Meta::Type->new('int'), 'Check int alias' );
is( $type->key, 'integer', "Check integer key" );
is( $type->name, 'Integer', "Check integer name" );
is( $type->desc, 'Integer', "Check integer desc" );
is( ref $type->check, 'ARRAY', "Check integer check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check integer code');
}
is( ref $type->converter, 'CODE', "Check integer conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple integer set" );
is( ref $set, 'HASH', 'Simple integer set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Integer set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking integer set" );
is( ref $set, 'HASH', 'Integer set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Integer chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting integer set" );
is( ref $set, 'HASH', 'Integer set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Integer conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full integer set" );
is( ref $set, 'HASH', 'Full integer set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full integer set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make integer get" );
is( ref $get, 'HASH', 'Integer get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Integer get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check integer attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check integer attr_get" );

##############################################################################
# Check decimal data type.
ok( $type = Class::Meta::Type->new('decimal'), 'Get decimal' );
is( $type, Class::Meta::Type->new('dec'), 'Check dec alias' );
is( $type->key, 'decimal', "Check decimal key" );
is( $type->name, 'Decimal Number', "Check decimal name" );
is( $type->desc, 'Decimal number', "Check decimal desc" );
is( ref $type->check, 'ARRAY', "Check decimal check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check decimal code');
}
is( ref $type->converter, 'CODE', "Check decimal conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple decimal set" );
is( ref $set, 'HASH', 'Simple decimal set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Decimal set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking decimal set" );
is( ref $set, 'HASH', 'Decimal set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Decimal chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting decimal set" );
is( ref $set, 'HASH', 'Decimal set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Decimal conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full decimal set" );
is( ref $set, 'HASH', 'Full decimal set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full decimal set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make decimal get" );
is( ref $get, 'HASH', 'Decimal get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Decimal get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check decimal attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check decimal attr_get" );

##############################################################################
# Check real data type.
ok( $type = Class::Meta::Type->new('real'), 'Get real' );
is( $type->key, 'real', "Check real key" );
is( $type->name, 'Real Number', "Check real name" );
is( $type->desc, 'Real number', "Check real desc" );
is( ref $type->check, 'ARRAY', "Check real check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check real code');
}
is( ref $type->converter, 'CODE', "Check real conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple real set" );
is( ref $set, 'HASH', 'Simple real set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Real set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking real set" );
is( ref $set, 'HASH', 'Real set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Real chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting real set" );
is( ref $set, 'HASH', 'Real set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Real conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full real set" );
is( ref $set, 'HASH', 'Full real set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full real set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make real get" );
is( ref $get, 'HASH', 'Real get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Real get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check real attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check real attr_get" );

##############################################################################
# Check float data type.
ok( $type = Class::Meta::Type->new('float'), 'Get float' );
is( $type->key, 'float', "Check float key" );
is( $type->name, 'Floating Point Number', "Check float name" );
is( $type->desc, 'Floating point number', "Check float desc" );
is( ref $type->check, 'ARRAY', "Check float check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check float code');
}
is( ref $type->converter, 'CODE', "Check float conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple float set" );
is( ref $set, 'HASH', 'Simple float set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Float set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking float set" );
is( ref $set, 'HASH', 'Float set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Float chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting float set" );
is( ref $set, 'HASH', 'Float set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Float conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full float set" );
is( ref $set, 'HASH', 'Full float set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full float set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make float get" );
is( ref $get, 'HASH', 'Float get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Float get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check float attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check float attr_get" );

##############################################################################
# Check scalar data type.
ok( $type = Class::Meta::Type->new('scalar'), 'Get scalar' );
is( $type->key, 'scalar', "Check scalar key" );
is( $type->name, 'Scalar', "Check scalar name" );
is( $type->desc, 'Scalar', "Check scalar desc" );
# Scalars aren't validated or convted.
ok( ! defined $type->check, "Check scalar check" );
ok( ! defined $type->converter, "Check scalar conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple scalar set" );
is( ref $set, 'HASH', 'Simple scalar set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking scalar set" );
is( ref $set, 'HASH', 'Scalar set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting scalar set" );
is( ref $set, 'HASH', 'Scalar set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full scalar set" );
is( ref $set, 'HASH', 'Full scalar set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full scalar set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make scalar get" );
is( ref $get, 'HASH', 'Scalar get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Scalar get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check scalar attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check scalar attr_get" );

##############################################################################
# Check scalar reference data type.
ok( $type = Class::Meta::Type->new('scalarref'), 'Get scalar ref' );
is( $type->key, 'scalarref', "Check scalar ref key" );
is( $type->name, 'Scalar Reference', "Check scalar ref name" );
is( $type->desc, 'Scalar reference', "Check scalar ref desc" );
is( ref $type->check, 'ARRAY', "Check scalar ref check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check scalar ref code');
}
is( ref $type->converter, 'CODE', "Check scalar ref conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple scalar ref set" );
is( ref $set, 'HASH', 'Simple scalar ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar Ref set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking scalar ref set" );
is( ref $set, 'HASH', 'Scalar Ref set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting scalar ref set" );
is( ref $set, 'HASH', 'Scalar Ref set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Scalar Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full scalar ref set" );
is( ref $set, 'HASH', 'Full scalar ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full scalar ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make scalar ref get" );
is( ref $get, 'HASH', 'Scalar Ref get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Scalar Ref get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check scalar ref attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check scalar ref attr_get" );

##############################################################################
# Check array data type.
ok( $type = Class::Meta::Type->new('array'), 'Get array' );
is( $type, Class::Meta::Type->new('arrayref'), 'Check arrayref alias' );
is( $type->key, 'array', "Check array key" );
is( $type->name, 'Array Reference', "Check array name" );
is( $type->desc, 'Array reference', "Check array desc" );
is( ref $type->check, 'ARRAY', "Check array check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check array code');
}
is( ref $type->converter, 'CODE', "Check array conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple array ref set" );
is( ref $set, 'HASH', 'Simple array ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Array Ref set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking array ref set" );
is( ref $set, 'HASH', 'Array Ref set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Array Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting array ref set" );
is( ref $set, 'HASH', 'Array Ref set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Array Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full array ref set" );
is( ref $set, 'HASH', 'Full array ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full array ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make array ref get" );
is( ref $get, 'HASH', 'Array Ref get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Array Ref get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check array attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check array attr_get" );

##############################################################################
# Check hash data type.
ok( $type = Class::Meta::Type->new('hash'), 'Get hash' );
is( $type, Class::Meta::Type->new('hashref'), 'Check hashref alias' );
is( $type->key, 'hash', "Check hash key" );
is( $type->name, 'Hash Reference', "Check hash name" );
is( $type->desc, 'Hash reference', "Check hash desc" );
is( ref $type->check, 'ARRAY', "Check hash check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check hash code');
}
is( ref $type->converter, 'CODE', "Check hash conversion" );

# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple hash ref set" );
is( ref $set, 'HASH', 'Simple hash ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Hash Ref set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking hash ref set" );
is( ref $set, 'HASH', 'Hash Ref set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Hash Ref chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting hash ref set" );
is( ref $set, 'HASH', 'Hash Ref set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Hash Ref conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full hash ref set" );
is( ref $set, 'HASH', 'Full hash ref set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full hash ref set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make hash ref get" );
is( ref $get, 'HASH', 'Hash Ref get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Hash Ref get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check hash attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check hash attr_get" );

##############################################################################
# Check code data type.
ok( $type = Class::Meta::Type->new('code'), 'Get code' );
is( $type, Class::Meta::Type->new('coderef'), 'Check coderef alias' );
is( $type->key, 'code', "Check code key" );
is( $type->name, 'Code Reference', "Check code name" );
is( $type->desc, 'Code reference', "Check code desc" );
is( ref $type->check, 'ARRAY', "Check code check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check code code');
}
is( ref $type->converter, 'CODE', "Check code conversion" );
# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple code set" );
is( ref $set, 'HASH', 'Simple code set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Code set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking code set" );
is( ref $set, 'HASH', 'Code set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Code chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting code set" );
is( ref $set, 'HASH', 'Code set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Code conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full code set" );
is( ref $set, 'HASH', 'Full code set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full code set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make code get" );
is( ref $get, 'HASH', 'Code get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Code get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check code attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check code attr_get" );

##############################################################################
# Check datetime data type.
ok( $type = Class::Meta::Type->new('datetime'), 'Get datetime' );
is( $type->key, 'datetime', "Check datetime key" );
is( $type->name, 'Date/Time', "Check datetime name" );
is( $type->desc, 'Date/Time', "Check datetime desc" );
is( ref $type->check, 'ARRAY', "Check datetime check" );
foreach my $chk (@{ $type->check }) {
    is( ref $chk, 'CODE', 'Check datetime code');
}
is( ref $type->converter, 'CODE', "Check datetime conversion" );
# Check to make sure that the set_ method codrefs are created properly, and
# keyed off the proper method name. Start with a simple set_ method.
ok( $set = $type->make_set($attr . ++$i), "Make simple datetime set" );
is( ref $set, 'HASH', 'Simple datetime set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Datetime set coderef" );

# Now check with checks added.
ok( $set = $type->make_set($attr . ++$i, $type->check),
    "Make checking datetime set" );
is( ref $set, 'HASH', 'Datetime set with checks is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Datetime chk set coderef" );

# Now check with a conversion.
ok( $set = $type->make_set($attr . ++$i, undef, $type->converter),
    "Make converting datetime set" );
is( ref $set, 'HASH', 'Datetime set with conv is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Datetime conv set coderef" );

# And finally, with both a check and a conversion.
ok( $set = $type->make_set($attr . ++$i, $type->check, $type->converter),
    "Make full datetime set" );
is( ref $set, 'HASH', 'Full datetime set is hashref' );
is( ref $set->{'set_' . $attr . $i}, 'CODE', "Full datetime set coderef" );

# Now check to make sure that the get_ method coderefs are created properly,
# and keyed off the proper method name.
ok( $get = $type->make_get($attr . $i), "Make datetime get" );
is( ref $get, 'HASH', 'Datetime get is hashref' );
is( ref $get->{'get_' . $attr . $i}, 'CODE', "Datetime get coderef" );

# And finally, check to make sure that the Attribute class accessor coderefs
# are getting created.
is( ref $type->make_attr_set($attr . $i), 'CODE', "Check datetime attr_set" );
is( ref $type->make_attr_get($attr . $i), 'CODE', "Check datetime attr_get" );
