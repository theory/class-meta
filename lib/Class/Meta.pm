package Class::Meta;

# $Id: Meta.pm,v 1.35 2004/01/08 03:27:36 david Exp $

=head1 NAME

Class::Meta - Class automation, introspection, and data validation

=head1 SYNOPSIS

  package MyApp::Thingy;
  use strict;
  use warnings;
  use Class::Meta;
  use Class::Meta::Types::String;
  use Class::Meta::Types::Numeric;

  BEGIN {
      # Create a Class::Meta object for this class.
      my $cm = Class::Meta->new( key => 'thingy' );

      # Add a constructor.
      $cm->add_ctor( name   => 'new',
                     create => 1 );

      # Add a couple of attributes with generated methods.
      $cm->add_attr( name     => 'id',
                     authz    => Class::Meta::READ,
                     type     => 'integer',
                     required => 1,
                     default  => sub { ... }
                  );
      $cm->add_attr( name     => 'name',
                     type     => 'string',
                     required => 1,
                     default  => undef,
                  );
      $cm->add_attr( name     => 'age',
                     type     => 'inteter',
                     required => 0,
                     default  => undef,
                  );

      # Add a custom method.
      $cm->add_meth( name  => 'chk_pass',
                     view   => Class::Meta::PUBLIC,
                  );
      $cm->build;
  }


=head1 DESCRIPTION

Class::Meta provides an interface for automating the creation of Perl classes
with attribute data type validation. It differes from other such modules in
that it includes an introspection API that can be used as a unified interface
for all Class::Meta-generated classes. In this sense, it is an impelementation
of the "Facade" design pattern.

=head1 JUSTIFICATION

One might argue that there are already too many class automation and parameter
validation modules on CPAN. And one would be right. They range from simple
accessor generators, such as L<Class::Accessor|Class::Accessor>, to simple
parameter validators, such as L<Params::Validate|Params::Validate>, to more
comprehensive systems, such as L<Class::Contract|Class::Contract> and
L<Class::Tangram|Class::Tangram>. But, naturally, none of them could do
exactly what I needed.

What I needed was an implementation of the "Facade" design pattern. Okay, this
insn't a facade like the GOF meant it, but it is in the respect that it
creates classes with a common API so that objects of these classes can all be
used identically, calling the same methods on each. This is done via the
implementation of an introspection API. So the process of creating classes
with Class::Meta not only creates attributes and accessors, but also creates
objects that describe those classes. Using these descriptive objects, client
applications can determine what to do with objects of Class::Meta-generated
classes. This is particularly useful for user interface code.

=head1 USAGE

Before we get to the instrospection API, let's take a look at how to create
classes with Class::Meta. Unlike many class automation modules for Perl, the
classes that Class::Meta builds do not inherit from Class::Meta. This frees
you from any dependencies on the interfaces that such a base class might
compel. For example, you can create whatever constructors you like, and name
them whatever you like.

I recommend that you create your Class::Meta classes in a C<BEGIN>
block. Although this is not strictly necessary, it helps to ensure that the
classes you're building are completely constructed and ready to go by the time
compilation has completed. Creating classes with Class::Meta is easy, using
the Class::Meta object oriented interface. Here is an example of a very simple
class:

  package MyApp::Dog;
  use strict;
  use warnings;
  use Class::Meta;
  use Class::Meta::Types::Perl;

  BEGIN {
      # Create a Class::Meta object for this class.
      my $c = Class::Meta->new( key => 'dog' );

      # Add a constructor.
      $cm->add_ctor( name   => 'new',
                     create => 1 );

      # Add an attribute.
      $cm->add_attr( name   => 'tail',
                     type   => 'scalar',
                  );

      # Add a custom method.
      $cm->add_meth( name   => 'wag' );
      $cm->build;
  }

  sub wag {
      my $self = shift;
      print "Wagging ", $self->tail;
  }

This simple example shows of the construction of all three types of objects
supported by Class::Meta: constructors, attributes, and methods. Here's how
it does it:

=over 4

=item *

First we load Class::Meta and Class::Meta::Types::Perl. The latter module
creates data types that can be used for attributes, including a "scalar"
data type.

=item *

Second, we create a Class::Meta object. It's okay to create it within the
C<BEGIN> block, as it won't be needed beyond that. All Class::Meta classes
have a C<key> that uniquely identifies them across an application. If none is
provided, the class name will be used, instead.

=item *

Next, we create a Class::Meta::Constructor object to describe a constructor
method for the class. The C<create> parameter to the C<add_ctor()> method
tells Class::Meta to create the constructor named "C<new()>".

=item *

Then we call C<add_attr()> to create a single attribute, "tail". This is a
simple scalar attribute, meaning that any scalar value can be stored in
it. Class::Meta will create a Class::Meta::Attribute object that describes
this attribute, and will also shortly create accessor methods for the
attribute.

=item *

The C<add_meth()> method constructs a Class::Meta::Method object to descibe
any methods written for the class. In this case, we've told Class::Meta that
there will be a C<wag()> method.

=item *

And finally, we tell Class::Meta to build the class. This is the point at
which all constructors and accessor methods will be created in the class. In
this case, these include the C<new()> constructor and a C<tail()> accessor for
the "tail" attribute. And finally, Class::Meta will install another method,
C<my_class()>. This method will return a Class::Meta::Class object that
describes the class, and provides the complete introspection API.

=back

Thus, the class the above code creates has this interface:

  sub my_class;
  sub new;
  sub tail;
  sub wag;

=head2 Data Types

By default, Class::Meta loads no data types. If you attempt to create an
attribute without creating or loading the appropriate data type, you will
get an error.

But I didn't want to leave you out in the cold, so I created a whole bunch of
data types to get you started. They can be loaded simply by creating the
approrpriate module. The modules are:

=over 4

=item L<Class::Meta::Type::Perl|Class::Meta::Type::Perl>

Typical Perl data types.

=over 4

=item scalar

Any scalar value.

=item scalarref

A scalar reference.

=item array

=item arrayref

An array reference.

=item hash

=item hashref

A hash reference.

=item code

=item coderef

=item closure

A code reference.

=back

=item L<Class::Meta::Type::String|Class::Meta::Type::String>

=over 4

=item string

Attributes of this type must contain a string value. Essentially, this means
anything other than a reference.

=back

=item L<Class::Meta::Type::Boolean|Class::Meta::Type::Boolean>

=over 4

=item boolean

Attributes of this type store a boolean value. Implementation-wise, this means
either a 1 or a 0.

=back

=item L<Class::Meta::Type::Numeric|Class::Meta::Type::Numeric>

These data types are validated by the functions provided by
L<Data::Types|Data::Types>.

=over 4

=item whole

A whole number.

=item integer

An integer.

=item decimal

A decimal number.

=item real

A real number.

=item float

a floating point number.

=back

=back

Other data types may be added in the future. See the individual data type
modules for more information.

=head2 Accessors

Class::Meta supports the creation of two different types of attribute
accessors: typical Perl single-method accessors, and "affordance" acccessors.
The single accessors are named for their attributes, and typically tend
to look like this:

  sub tail {
      my $self = shift;
      return $self->{tail} unless @_;
      return $self->{tail} = shift;
  }

Although this can be an oversimplification if the data type has associated
validation checks.

Affordance accessors provide at least two accessors for every attribute: One
to set the value and one to retreive the value. They tend to look like this:

  sub get_tail { shift->{tail} }

  sub set_tail { shift->{tail} = shift }

These accessors offer a bit less overhead than the traditional Perl accessors,
in that they don't have to check whether they're called to get or set a
value. They also have the benefit of creating a psychological barrier to
misuse. Since traditional Perl accessors I<can> be created as read-only or
write-only accessors, one can't tell just by looking at them which is the
case. The affordance accessors make this point moot, as they make clear what
their purpose is.

To get Class::Meta's data types to create affordance accessors, simply pass
the string "affordance" to them when you load them:

  use Class::Meta::Types::Perl 'affordances';

The boolean data type is the only one that uses a slightly different approach
to the creation of affordance accessors: It creates three of them. Assuming
you're creating a boolean attribute named "alive", it will create the
accessors C<is_alive>, C<set_alive_on>, and C<set_alive_off>.

Incidentally, I stole the term "affordance" from Damian Conway's "Object
Oriented Perl," pp 83-84, where he borrows it from Donald Norman.

See L<Class::Meta::Type|Class::Meta::Type> for details on creating new data
types.

=head2 Introspection API

Class::Meta provides four classes the make up the introspection API for
Class::Meta-generated classes. Those classes are:

=head3 L<Class::Meta::Class|Class::Meta::Class>

Describes the class. Each Class::Meta-generated class has a single constructor
object that can be retrieved by calling a class' C<my_class()> class
method. Using the Class::Meta::Class object, you can get access to all of the
other objects that describe the class. The relevant methods are:

=over 4

=item my_ctors

Provides access to all of the Class::Meta::Constructor objects that describe
the class' constructors, and provide indirect access to those constructors.

=item my_attrs

Provides access to all of the Class::Meta::Attribute objects that describe the
class' attributes, and provide methods for indirectly getting and setting
their values.

=item my_meths

Provides access to all of the Class::Meta::Method objects that describe the
class' methods, and provide indirect execution of those constructors.

=back

=head3 L<Class::Meta::Constructor|Class::Meta::Constructor>

Describes a class constructor. Typically a class will have only a single
constructor, but there could be more, and client code doesn't necessarily know
its name. Class::Meta::Constructor objects resolve these issues by describing
all of the constructors in a class. The most useful methods are:

=over 4

=item my_name

Returns the name of the constructor, such as "new".

=item call

Calls the constructor on an object, passing in the arguments passed to
C<call()> itself.

=back

=head3 L<Class::Meta::Attribute|Class::Meta::Attribute>

Describes a class attribute, including its name and data type. Attribute
objects are perhaps the most useful Class::Meta objects, in that they can
provide a great deal of information about the structure of a class. The most
interesting methods are:

=over 4

=item my_name

Returns the name of the attribute.

=item my_type

Returns the name of the attribute's data type.

=item is_required

Returns true if the attribute is required to have a value.

=item call_set

Sets the value of an attribute on an object.

=item call_get

Returns the value of an attribute on an object.

=back

=head3 L<Class::Meta::Method|Class::Meta::Method>

Describes a method of a class, including its name and context (class
vs. instance). The relevant methods are:

=over 4

=item my_name

The method name.

=item my_context

The context of the method indicated by a value corresponding to either
Class::Meta::OBJECT or Class::Meta::CLASS.

=item call

Calls the method, passing in the argumens passed to C<call()> itself.

=back

Consult the documentation of the individual classes for a complete description
of their interfaces.

=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use 5.008;
use strict;
use warnings;

##############################################################################
# Constants                                                                  #
##############################################################################

# View. These determine who can get metadata objects back from method calls.
use constant PRIVATE   => 0x01;
use constant PROTECTED => 0x02;
use constant PUBLIC    => 0x03;

# Authorization. These determine what kind of accessors (get, set, both, or
# none) are available for a given attribute or method.
use constant NONE      => 0x01;
use constant READ      => 0x02;
use constant WRITE     => 0x03;
use constant RDWR      => 0x04;

# Method generation. These tell Class::Meta which accessors to create. Use
# NONE above for NONE. These will use the values in the authz argument by
# default. They're separate because sometimes an accessor needs to be built
# by hand, rather than custom-generated by Class::Meta, and the
# authorization needs to reflect that.
use constant GET       => READ;
use constant SET       => WRITE;
use constant GETSET    => RDWR;

# Method and attribute context.
use constant CLASS     => 0x01;
use constant OBJECT    => 0x02;

##############################################################################
# Dependencies that rely on the above constants                              #
##############################################################################
use Class::Meta::Type;
use Class::Meta::Class;
use Class::Meta::Constructor;
use Class::Meta::Attribute;
use Class::Meta::Method;

##############################################################################
# Package Globals                                                            #
##############################################################################
our $VERSION = "0.01";

##############################################################################
# Private Package Globals
##############################################################################
my $croak = sub { require Carp; Carp::croak(@_) };

##############################################################################
# Constructors                                                               #
##############################################################################

=head1 INTERFACE

=head2 Constructors

=head3 new

  my $cm = Class::Meta->new( key => $key );

Constructs and returns a new Class::Meta object that can then be used to
define and build the complete interface of a class. The supported parameters
are:

=over 4

=item package

The package that defines the class. Defaults to the package of the code
that calls C<new()>.

=item key

A key name that uniquely identifies a class within an application. Defaults to
the value of the C<package> parameter if not specified.

=item class_class

The name of a class that inherits from Class::Meta::Class to be used to create
all of the class objects for the class. Defaults to Class::Meta::Class.

=item ctor_class

The name of a class that inherits from Class::Meta::Constructor to be used to
create all of the constructor objects for the class. Defaults to
Class::Meta::Constructor.

=item attr_class

The name of a class that inherits from Class::Meta::Attribute to be used to
create all of the attribute objects for the class. Defaults to
Class::Meta::Attribute.

=item meth_class

The name of a class that inherits from Class::Meta::Method to be used to
create all of the method objects for the class. Defaults to
Class::Meta::Method.

=back

=cut

{
    my %classes;

    sub new {
        my $pkg = shift;

        # Make sure we can get all the arguments.
        $croak->("Odd number of parameters in call to new() when named "
                 . "parameters were expected" ) if @_ % 2;
        my %p = @_;

        # Class defaults to caller. Key defaults to class.
        $p{key} ||= $p{package} ||= caller;

        # Make sure we haven't been here before.
        $croak->("Class '$p{package}' already created")
          if exists $classes{$p{package}};

        $p{class_class} ||= 'Class::Meta::Class';
        $p{ctor_class} ||= 'Class::Meta::Constructor';
        $p{attr_class} ||= 'Class::Meta::Attribute';
        $p{meth_class} ||= 'Class::Meta::Method';

        # Instantiate a Class object.
        $p{class} = $p{class_class}->new(\%p);

        # Cache the definition.
        $classes{$p{package}} = \%p;

        # Return!
        return bless { package => $p{package} }, ref $pkg || $pkg;
    }


##############################################################################
# add_ctor()

=head3 add_ctor

  $cm->add_ctor( name   => 'new',
                 create => 1 );

Creates and returns a Class::Meta::Constructor object that describes a
constructor for the class. The supported parameters are:

=over 4

=item name

The name of the constructor. The name must consist of only alphanumeric
characters or "_".

=item view

The visibility of the constructor. The possible values are defined by the
following constants:

=over 4

=item Class::Meta::PUBLIC

=item Class::Meta::PRIVATE

=item Class::Meta::PROTECTED

=back

Defaults to Class::Meta::PUBLIC if not defined.

=item caller

A code reference that calls the constructor. Defaults to a code reference that
calls a method with the name provided by the C<name> attribute on the class
being defined.

=back

=cut

    sub add_ctor {
        my $spec = $classes{ shift->{package} };
        push @{$spec->{build_ctor_ord}}, $spec->{ctor_class}->new($spec, @_);
        return $spec->{build_ctor_ord}[-1];
    }

##############################################################################
# add_attr()

=head3 add_attr

  $cm->add_attr( name   => 'tail',
                 type   => 'scalar',
               );

Creates and returns a Class::Meta::Attribute object that describes an
attribute of the class. The supported parameters are:

=over 4

=item name

The name of the attribute. The name must consist of only alphanumeric
characters or "_".

=item view

The visibility of the attribute. See the description of the C<view> parameter
to C<add_ctor> for a description of its value.

=item authz

The authorization of the attribute. This value indicates wheither it is
read-only, write-only, read/write, or inaccessable. The possible values are
defined by the following constants:

=over 4

=item Class::Meta::READ

=item Class::Meta::WRITE

=item Class::Meta::RDWR

=item Class::Meta::NONE

=back

Defaults to Class::Meta::RDWR if not defined.

=item create

Indicates what type of accessor or accessors are to be created for the
attribute.

=over 4

=item Class::Meta::GET

Create read-only accessor(s).

=item Class::Meta::SET

Create write-only accessor(s).

=item Class::Meta::GETSET

Create read/write accessor(s).

=item Class::Meta::NONE

Creat no accessors.

=back

If not unspecified, the value of the C<create> parameter will correspond to
the value of the C<authz> parameter like so:

  authz       create
  ------------------
  READ   =>   GET
  WRITE  =>   SET
  RDWR   =>   GETSET
  NONE   =>   NONE

The C<create> parameter differes from the C<authz> parameter in case you've
taken it upon yourself to create some accessors, and therefore don't need
Class::Meta to do so. For example, if you were using standard Perl-style
accessors, and needed to do something a little different by coding your own
accessor, you'd specify it like this:

  $cm->add_attr( name   => $name,
                 type   => $type,
                 authz  => Class::Meta::RDWR,
                 create => Class::Meta::NONE,
  );

=item context

The context of the attribute. This indicates whether it's a class attribute
or an object attribute. The possible values are
defined by the following constants:

=over 4

=item Class::Meta::CLASS

=item Class::Meta::OBJECT

=back

=item default

The default value for the attribute, if any. This may be either a literal
value or a code reference that will be executed to generate a default value.

=back

=cut

    sub add_attr {
        my $spec = $classes{ shift->{package} };
        push @{$spec->{build_attr_ord}}, $spec->{attr_class}->new($spec, @_);
        return $spec->{build_attr_ord}[-1];
    }

##############################################################################
# add_meth()

=head3 add_meth

  $cm->add_meth( name => 'wag' );

Creates and returns a Class::Meta::Method object that describes a method of
the class. The supported parameters are:

=over 4

=item name

The name of the method. The name must consist of only alphanumeric
characters or "_".

=item view

The visibility of the method. See the description of the C<view> parameter to
C<add_ctor> for a description of its value.

=item context

The context of the method. This indicates whether it's a class method or an
object method. See the description of the C<context> parameter to C<add_attr>
for a description of its value.

=item caller

A code reference that calls the method. Defaults to a code reference that
calls a method with the name provided by the C<name> attribute on the class
being defined.

=back

=cut

    sub add_meth {
        my $spec = $classes{ shift->{package} };
        $spec->{meth_class}->new($spec, @_);
    }

##############################################################################
# Instance Methods                                                           #
##############################################################################

=head2 Instance Methods

=head3 my_class

  my $class = $cm->my_class;

Returns the instance of the Class::Meta::Class object that will be used to
provide the introspection API for the class being generated.

=cut

# Simple accessors.
    sub my_class { $classes{ $_[0]->{package} }->{class} }

##############################################################################
# build()

=head3 build

  $cm->build;

Builds the class defined by the Class::Meta object, including the
C<my_class()> class method, and all requisite constructors and accessors.

=cut

    sub build {
        my $self = shift;
        my $spec = $classes{ $self->{package} };

        # Build the attribute accessors and constructors.
        if (my $objs = $spec->{build_attr_ord}) {
            $_->build($spec) for @$objs;
        }

        if (my $objs = $spec->{build_ctor_ord}) {
            $_->build(\%classes) for @$objs;
        }

        # Build the Class::Meta::Class accessor and my_key shortcut.
        no strict 'refs';
        *{"$spec->{package}::my_class"} = sub { $spec->{class} };

        $spec->{class}->build;
        return $self;
    }
}

1;
__END__

=head1 TO DO

=over 4

=item *

Add ability to create object attribute accessors.

=item *

Add tests for all errors.

=item *

Add tests for subclasses of the C::M classes.

=back

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 SEE ALSO

L<Class::Contract|Class::Contract>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2003, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
