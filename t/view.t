#!perl -w

# $Id: view.t,v 1.9 2004/08/26 23:50:15 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 214;
use File::Spec;
my $fn = File::Spec->catfile('t', 'view.t');

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::Test;
use strict;

BEGIN {
    Test::More->import;
    use_ok('Class::Meta');
    use_ok('Class::Meta::Types::Numeric');
    use_ok('Class::Meta::Types::String');
}

BEGIN {
    ok( my $c = Class::Meta->new(
        key     => 'person',
        package => __PACKAGE__,
        name    => 'Class::Meta::TestPerson Class',
        desc    => 'Special person class just for testing Class::Meta.',
    ), "Create Class::Meta object" );

    # Add a constructor.
    ok( $c->add_constructor( name => 'new',
                             create  => 1 ),
        "Add new constructor" );

    # Add a protected constructor.
    ok( $c->add_constructor( name    => 'prot_new',
                             view    => Class::Meta::PROTECTED,
                             create  => 1 ),
        "Add protected constructor" );

    # Add a private constructor.
    ok( $c->add_constructor( name    => 'priv_new',
                             view    => Class::Meta::PRIVATE,
                             create  => 1 ),
        "Add private constructor" );

    # Add a couple of attributes with created methods.
    ok( $c->add_attribute( name     => 'id',
                           view     => Class::Meta::PUBLIC,
                           type     => 'integer',
                           label    => 'ID',
                           required => 1,
                           default  => 22,
                         ),
        "Add id attribute" );
    ok( $c->add_attribute( name     => 'name',
                           view     => Class::Meta::PROTECTED,
                           type     => 'string',
                           label    => 'Name',
                           required => 1,
                           default  => '',
                         ),
        "Add protected name attribute" );
    ok( $c->add_attribute( name     => 'age',
                           view     => Class::Meta::PRIVATE,
                           type     => 'integer',
                           label    => 'Age',
                           desc     => "The person's age.",
                           required => 0,
                           default  => 0,
                         ),
        "Add private age attribute" );
    $c->build;
}

##############################################################################
# From within the package, the private and public attributes should just work.
##############################################################################

ok( my $obj = __PACKAGE__->new, "Create new object" );
ok( my $class = __PACKAGE__->my_class, "Get class object" );

# Check id public attribute.
is( $obj->id, 22, 'Check default ID' );
ok( $obj->id(12), "Set ID" );
is( $obj->id, 12, 'Check 12 ID' );
ok( my $attr = $class->attributes('id'), 'Get "id" attribute object' );
is( $attr->get($obj), 12, "Check indirect 12 ID" );
ok( $attr->set($obj, 15), "Indirectly set ID" );
is( $attr->get($obj), 15, "Check indirect 15 ID" );

# Check name protected attribute succeeds.
is( $obj->name, '', 'Check empty name' );
ok( $obj->name('Larry'), "Set name" );
is( $obj->name, 'Larry', 'Check "Larry" name' );
ok( $attr = $class->attributes('name'), 'Get "name" attribute object' );
is( $attr->get($obj), 'Larry', 'Check indirect "Larry" name' );
ok( $attr->set($obj, 'Chip'), "Indirectly set name" );
is( $attr->get($obj), 'Chip', 'Check indirect "chip" name' );

# Check age private attribute succeeds.
is( $obj->age, 0, 'Check default age' );
ok( $obj->age(42), "Set age" );
is( $obj->age, 42, 'Check 42 age' );
ok( $attr = $class->attributes('age'), 'Get "age" attribute object' );
is( $attr->get($obj), 42, "Check indirect 12 age" );
ok( $attr->set($obj, 15), "Indirectly set age" );
is( $attr->get($obj), 15, "Check indirect 15 age" );

# Make sure that we can set all of the attributes via new().
ok( $obj = __PACKAGE__->new( id   => 10,
                             name => 'Damian',
                             age  => 35),
    "Create another new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

# Do the same with the constructor object.
ok( my $ctor = $class->constructors('new'), 'Get "new" constructor object' );
ok( $obj = $ctor->call(__PACKAGE__,
                       id   => 10,
                       name => 'Damian',
                       age  => 35),
    "Create another new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

# Make sure that we can set all of the attributes via prot_new().
ok( $obj = __PACKAGE__->prot_new( id   => 10,
                                  name => 'Damian',
                                  age  => 35),
    "Create another prot_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

# Do the same with the constructor object.
ok( $ctor = $class->constructors('prot_new'),
    'Get "prot_new" constructor object' );
ok( $obj = $ctor->call(__PACKAGE__,
                       id   => 10,
                       name => 'Damian',
                       age  => 35),
    "Create another prot_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

# Make sure that we can set all of the attributes via priv_new().
ok( $obj = __PACKAGE__->priv_new( id   => 10,
                                  name => 'Damian',
                                  age  => 35),
    "Create another priv_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

# Do the same with the constructor object.
ok( $ctor = $class->constructors('priv_new'),
    'Get "priv_new" constructor object' );
ok( $obj = $ctor->call(__PACKAGE__,
                       id   => 10,
                       name => 'Damian',
                       age  => 35),
    "Create another priv_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );
is( $obj->age, 35, 'Check 35 age' );

##############################################################################
# Set up an inherited package.
##############################################################################
package Class::Meta::Testarama;
use strict;
use base 'Class::Meta::Test';

BEGIN {
    Test::More->import;
    Class::Meta->new(key => 'testarama')->build;
}

ok( $obj = __PACKAGE__->new, "Create new Testarama object" );
ok( $class = __PACKAGE__->my_class, "Get Testarama class object" );

# Check id public attribute.
is( $obj->id, 22, 'Check default ID' );
ok( $obj->id(12), "Set ID" );
is( $obj->id, 12, 'Check 12 ID' );
ok( $attr = $class->attributes('id'), 'Get "id" attribute object' );
is( $attr->get($obj), 12, "Check indirect 12 ID" );
ok( $attr->set($obj, 15), "Indirectly set ID" );
is( $attr->get($obj), 15, "Check indirect 15 ID" );

# Check name protected attribute succeeds.
is( $obj->name, '', 'Check empty name' );
ok( $obj->name('Larry'), "Set name" );
is( $obj->name, 'Larry', 'Check Larry name' );
ok( $attr = $class->attributes('name'), 'Get "name" attribute object' );
is( $attr->get($obj), 'Larry', 'Check indirect "Larry" name' );
ok( $attr->set($obj, 'Chip'), "Indirectly set name" );
is( $attr->get($obj), 'Chip', 'Check indirect "chip" name' );

# Check age private attribute
eval { $obj->age(12) };
main::chk( 'private exception',
           qr/age is a private attribute of Class::Meta::Test/);
eval { $obj->age };
main::chk( 'private exception again',
           qr/age is a private attribute of Class::Meta::Test/);

# Check that age fails when accessed indirectly, too.
ok( $attr = $class->attributes('age'), 'Get "age" attribute object' );
eval { $attr->set($obj, 12) };
main::chk('indirect private exception',
          qr/age is a private attribute of Class::Meta::Test/);
eval { $attr->get($obj) };
main::chk('another indirect private exception',
          qr/age is a private attribute of Class::Meta::Test/);

# Make sure that we can set protected attributes via new().
ok( $obj = __PACKAGE__->new( id   => 10,
                             name => 'Damian'),
    "Create another new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );

# Make sure that the private attribute fails.
$ENV{FOO} = 1;
eval { __PACKAGE__->new( age => 44 ) };
delete $ENV{FOO};
main::chk('constructor private exception',
          qr/age is a private attribute of Class::Meta::Test/);

# Do the same with the new constructor object.
ok( $ctor = $class->constructors('new'), 'Get "new" constructor object' );
ok( $obj = $ctor->call(__PACKAGE__,
                       id   => 10,
                       name => 'Damian'),
    "Create another new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );

# Make sure that the private attribute fails.
eval { $ctor->call(__PACKAGE__, age => 44 ) };
main::chk('indirect constructor private exception',
      qr/age is a private attribute of Class::Meta::Test/);

# Make sure that we can set protected attributes via prot_new().
ok( $obj = __PACKAGE__->prot_new( id   => 10,
                             name => 'Damian'),
    "Create another prot_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );

# Make sure that the private attribute fails.
eval { __PACKAGE__->prot_new( age => 44 ) };
main::chk('constructor private exception',
      qr/age is a private attribute of Class::Meta::Test/);

# Do the same with the prot_new constructor object.
ok( $ctor = $class->constructors('prot_new'),
    'Get "prot_new" constructor object' );
ok( $obj = $ctor->call(__PACKAGE__,
                       id   => 10,
                       name => 'Damian'),
    "Create another prot_new object" );

is( $obj->id, 10, 'Check 10 ID' );
is( $obj->name, 'Damian', 'Check Damian name' );

# Make sure that the private attribute fails.
eval { $ctor->call(__PACKAGE__, age => 44 ) };
main::chk('indirect constructor private exception',
          qr/age is a private attribute of Class::Meta::Test/);

# Make sure that the private constructor fails.
eval { __PACKAGE__->priv_new };
main::chk('priv_new exeption',
          qr/priv_new is a private constructor of Class::Meta::Test/);

# Make sure the same is true of the priv_new constructor object.
ok( $ctor = $class->constructors('priv_new'),
    'Get "priv_new" constructor object' );
eval { $ctor->call(__PACKAGE__) };
main::chk('indirect priv_new exeption',
          qr/priv_new is a private constructor of Class::Meta::Test/);

##############################################################################
# Now do test in a completely independent package.
##############################################################################
package main;

ok( $obj = Class::Meta::Test->new, "Create new object in main" );
ok( $class = Class::Meta::Test->my_class, "Get class object in main" );

# Make sure we can access id.
is( $obj->id, 22, 'Check default ID' );
ok( $obj->id(12), "Set ID" );
is( $obj->id, 12, 'Check 12 ID' );
ok( $attr = $class->attributes('id'), 'Get "id" attribute object' );
is( $attr->get($obj), 12, "Check indirect 12 ID" );
ok( $attr->set($obj, 15), "Indirectly set ID" );
is( $attr->get($obj), 15, "Check indirect 15 ID" );

# Check name protected attribute
eval { $obj->name('foo') };
chk('protected exception',
    qr/name is a protected attribute of Class::Meta::Test/);
eval { $obj->name };
chk('another protected exception',
    qr/name is a protected attribute of Class::Meta::Test/);

# Check that name fails when accessed indirectly, too.
ok( $attr = $class->attributes('name'), 'Get "name" attribute object' );
eval { $attr->set($obj, 'foo') };
chk('indirect protected exception',
    qr/name is a protected attribute of Class::Meta::Test/);
eval { $attr->get($obj) };
chk('another indirect protected exception',
    qr/name is a protected attribute of Class::Meta::Test/);

# Check age private attribute
eval { $obj->age(12) };
chk( 'private exception',
     qr/age is a private attribute of Class::Meta::Test/ );
eval { $obj->age };
chk( 'another private exception',
 qr/age is a private attribute of Class::Meta::Test/);

# Check that age fails when accessed indirectly, too.
ok( $attr = $class->attributes('age'), 'Get "age" attribute object' );
eval { $attr->set($obj, 12) };
chk( 'indirect private exception',
     qr/age is a private attribute of Class::Meta::Test/);
eval { $attr->get($obj) };
chk( 'another indirect private exception',
     qr/age is a private attribute of Class::Meta::Test/);

# Try the constructor with parameters.
ok( $obj = Class::Meta::Test->new( id => 1 ), "Create new object with id" );
is( $obj->id, 1, 'Check 1 ID' );
ok( $ctor = $class->constructors('new'), "Get new constructor" );
ok( $obj = $ctor->call('Class::Meta::Test', id => 52 ),
    "Indirectly create new object with id" );
is( $obj->id, 52, 'Check 52 ID' );

# Make sure that the protected attribute fails.
eval { Class::Meta::Test->new( name => 'foo' ) };
chk( 'constructor protected exception',
     qr/name is a protected attribute of Class::Meta::Test/ );
eval { $ctor->call('Class::Meta::Test', name => 'foo' ) };
chk( 'indirect constructor protected exception',
     qr/name is a protected attribute of Class::Meta::Test/);

# Make sure that the private attribute fails.
eval { Class::Meta::Test->new( age => 44 ) };
chk('constructor private exception',
    qr/age is a private attribute of Class::Meta::Test/);
eval { $ctor->call('Class::Meta::Test', age => 44 ) };
chk( 'indirect constructor private exception',
     qr/age is a private attribute of Class::Meta::Test/);

# Make sure that the protected constructor fails.
eval { Class::Meta::Test->prot_new };
chk( 'prot_new exeption',
     qr/prot_new is a protected constrctor of Class::Meta::Test/ );

# Make sure the same is true of the prot_new constructor object.
ok( $ctor = $class->constructors('prot_new'),
    'Get "prot_new" constructor object' );
eval { $ctor->call(__PACKAGE__) };
chk( 'indirect prot_new exeption',
     qr/prot_new is a protected constrctor of Class::Meta::Test/ );

# Make sure that the private constructor fails.
eval { Class::Meta::Test->priv_new };
chk( 'priv_new exeption',
     qr/priv_new is a private constructor of Class::Meta::Test/ );

# Make sure the same is true of the priv_new constructor object.
ok( $ctor = $class->constructors('priv_new'),
    'Get "priv_new" constructor object' );
eval { $ctor->call(__PACKAGE__) };
chk( 'indirect priv_new exeption',
     qr/priv_new is a private constructor of Class::Meta::Test/ );

sub chk {
    my ($name, $qr) = @_;
    # Catch the exception.
    ok( my $err = $@, "Caught $name error" );
    # Check its message.
    like( $err, $qr, "Correct error" );
    # Make sure it refers to this file.
    like( $err, qr/(?:at\s+\Q$fn\E|\Q$fn\E\s+at)\s+line/, 'Correct context' );
    # Make sure it doesn't refer to other Class::Meta files.
    unlike( $err, qr|lib/Class/Meta|, 'Not incorrect context')
}
