package Class::Meta::Type;

# $Id: Type.pm,v 1.15 2004/01/08 03:16:15 david Exp $

=head1 NAME

Class::Meta::Type - Data type validation and accessor building.

=head1 SYNOPSIS

  package MyApp::TypeDef;

  use strict;
  use Class::Meta::Type;
  use Socket;

  my $type = Class::Meta::Type->add( key  => 'io_socket',
                                     desc => 'IO::Socket object',
                                     name => 'IO::Socket Object' );

=head1 DESCRIPTION

This class stores the various data types used by C<Class::Meta>. It manages
all aspects of data type validation and method creation. New data types can be
added to Class::Meta::Type by means of the C<add()> constructor. This is
useful for creating custom types for your Class::Meta-built classes.

B<Note:>This class manages the most advanced features of C<Class::Meta>.
Before deciding to create your own accessor closures as described in L<add()>,
you should have a thorough working knowledge of how Class::Meta works, and
have studied the L<add()> method carefully. Simple data type definitions such
as that shown in the L<SYNOPSIS>, on the other hand, are encouraged.

=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;

##############################################################################
# Package Globals                                                            #
##############################################################################
our $VERSION = "0.01";

##############################################################################
# Private Package Globals                                                    #
##############################################################################
my %def_builders = (
    default => 'Class::Meta::AccessorBuilder',
    affordance => 'Class::Meta::AccessorBuilder::Affordance',
);

##############################################################################
# Closure definition                                                         #
##############################################################################
my $croak = sub {
    require Carp;
    our @CARP_NOT = qw(Class::Meta Class::Meta::Attribute);
    Carp::croak(@_);
};

# This code ref builds object/reference value checkers.
my $mk_isachk = sub {
    my ($pkg, $type) = @_;
    return [
        sub {
            return unless defined $_[0];
            UNIVERSAL::isa($_[0], $pkg)
              or $croak->("Value '$_[0]' is not a valid $type")
            }
    ];
};

##############################################################################
# Data type definition storage.
##############################################################################
{
    my %types = ();

##############################################################################
# Constructors                                                               #
##############################################################################

=head1 CONSTRUCTORS

=head2 new

  my $type = Class::Meta::Type->new($key);

Returns the data type definition for an existing data type. The definition
will be looked up by the C<$key> argument. By default, Class::Meta::Type
offers only a single data type: "scalar". Other data types can be added by
means of the C<add()> constructor, or by simply C<use>ing one or more of the
following modules:

=over 4

=item L<Class::Meta::Type::Perl|Class::Meta::Type::Perl>

=over 4

=item scalar

=item scalarref

=item array

=item hash

=item code

=back

=item L<Class::Meta::Type::String|Class::Meta::Type::String>

=over 4

=item string

=back

=item L<Class::Meta::Type::Boolean|Class::Meta::Type::Boolean>

=over 4

=item boolean

=back

=item L<Class::Meta::Type::Numeric|Class::Meta::Type::Numeric>

=over 4

=item whole

=item integer

=item decimal

=item real

=item float

=back

=back

Read the docs for the individual modules for details on their data types.

=cut

    sub new {
        my $key = lc $_[1] || $croak->("Type argument required");
        $croak->("Type '$_[1]' does not exist") unless $types{$key};
        return bless $types{$key}, ref $_[0] || $_[0];
    }

##############################################################################

=head2 add

  my $type = Class::Meta::Type->add( key  => 'io_socket',
                                     name => 'IO::Socket Object',
                                     desc => 'IO::Socket object' );

Creates a new data type definition and stores it for future use. Use this
constructor to add new data types to meet the needs of your class. The named
parameter arguments are:

=over 4

=item key

Required. The key with which the datatype can be looked up in the future via a
call to C<new()>. Note that the key will be used case-insensitively, so "foo",
"Foo", and "FOO" are equivalent, and the key must be unique.

=item name

Required. The name of the data type. This should be formatted for display
purposes, and indeed, Class::Meta will often use it in its own exceptions.

=item check

Optional. Specifies how to validate the value of an attribute of this type.
The check parameter can be specified in any of the following ways:

=over 4

=item *

As a code reference. When Class::Meta executes this code reference, it will
pass in the value to check. If it's not the proper value for your custom data
type, the code reference should throw an exception. Here's an example; it's
the code reference used by "string" data type, which you can add to
Class::Meta::Type simply by using Class::Meta::Types::String:

  check => sub {
      my $value = shift;
      return unless defined $value && ref $value;
      require Carp;
      our @CARP_NOT = qw(Class::Meta::Attribute);
      Carp::croak("Value '$value' is not a valid string");
  }

=item *

As an array reference. All items in this array reference must be code
references that perform checks on a value, as specified above.

=item *

As a string. In this case, Class::Meta::Type assumes that your data type
identifies a particular object type. Thus it will use the string to construct
a validation code reference for you. For example, if you wanted to create a
data type for IO::Socket objects, pass the string 'IO::Socket' to the check
parameter and Class::Meta::Type will create this validation code reference:

  sub {
      my $value = shift;
      return if UNIVERSAL::isa($value, 'IO::Socket')
      require Carp;
      our @CARP_NOT = qw(Class::Meta::Attribute);
      Carp::croak("Value '$value' is not a IO::Socket object");
  };

=back

Note that if the C<check> parameter is not specified, there will never be any
validation of your custom data type. And yes, there may be times when you want
this -- The default "scalar" and "boolean" data types, for example, have no
checks.

=item builder

Optional. This parameter specifies the accessor builder for attributes of this
type. The C<builder> parameter can be any of the following values:

=over 4

=item "default"

The string 'default' uses Class::Meta::Type's default accessor building code,
provided by Class::Meta::AccessorBuilder. This is the default value, of
course.

=item "affordance"

The string 'default' uses Class::Meta::Type's affordance accessor building
code, provided by Class::Meta::AccessorBuilder::Affordance. Affordance accessors
provide two accessors for an attribute, a C<get_*> accessor and a C<set_*>
mutator. See
L<Class::Meta::AccessorBuilder::Affordance|Class::Meta::AccessorBuilder::Affordance>
for more information.

=item A Package Name

Pass in the name of a package that contains the functions C<build()>,
C<build_attr_get()>, and C<build_attr_set()>. These functions will be used to
create the necessary accessors for an attribute.

The C<build()> function creates and installs the actual accessor methods in a
class. It should expect the following arguments:

  sub build {
      my ($class, $attribute, $create, @checks) = @_;
      # ...
  }

These are:

=over 4

=item C<$class>

The name of the class into which the accessors are to be installed.

=item C<$attribute>

The name of the attribute for which accessors are to be created.

=item C<$create>

The value of the Class::Meta::Attribute object's C<create> attribute. Use this
argument to determine what type of accessor(s) to create. See
L<Class::Meta::Attribute|Class::Meta::Attribute> for the possible values for
this argument.

=item <@checks>

A list of one or more data type validation code references. Use these in any
accessors that set attribute values to check that the new value has a valid
value.

=back

See L<Class::Meta::AccessorBuilder|Class::Meta::AccessorBuilder> for example
attribute creation functions.

=back

The C<build_attr_get()> and C<build_attr_set()> functions take a single
argument, the name of an attribute, and return code references that call the
appropriate accessor methods to get and set an attribute, respectively. The
code references will be used by Class::Meta::Attribute's C<call_get()> and
C<call_set()> methods to get and set attribute values. Again, see
L<Class::Meta::AccessorBuilder|Class::Meta::AccessorBuilder> for examples
before creating your own.

=back

=cut

    sub add {
        my $pkg = shift;
        # Make sure we can process the parameters.
        $croak->("Odd number of parameters in call to add() when named ",
                 "parameters were expected" ) if @_ % 2;
        my %params = @_;

        # Check required paremeters.
        foreach (qw(key name)) {
            $croak->("Parameter '$_' is required") unless $params{$_};
        }

        # Check the key parameter.
        $params{key} = lc $params{key};
        $croak->("Type '$params{key}' already defined")
          if exists $types{$params{key}};

        # Set up the check croak.
        my $chk_die = sub {
            $croak->("Paremter 'check' in call to add() must be a code ",
                     "reference, an array of code references, or a ",
                     "scalar naming an object type");
        };

        # Check the check parameter.
        if ($params{check}) {
            my $ref = ref $params{check};
            if (not $ref) {
                # It names the object to be checked.
                $params{check} = $mk_isachk->(@params{qw(check name)});
            } elsif ($ref eq 'CODE') {
                $params{check} = [$params{check}]
            } elsif ($ref eq 'ARRAY') {
                # Make sure that they're all code references.
                foreach my $chk (@{$params{check}}) {
                    $chk_die->() unless ref $chk eq 'CODE';
                }
            } else {
                # It's bogus.
                $chk_die->();
            }
        }

        # Check the builder parameter.
        $params{builder} ||= 'default';
        my $builder = $def_builders{$params{builder}} || $params{builder};
        # Make sure it's loaded.
        eval "require $builder";

        $params{builder} = UNIVERSAL::can($builder, 'build')
          || $croak->("No such function '${builder}::build()'");

        $params{attr_get} = UNIVERSAL::can($builder, 'build_attr_get')
          || $croak->("No such function '${builder}::build_attr_get()'");

        $params{attr_set} = UNIVERSAL::can($builder, 'build_attr_set')
          || $croak->("No such function '${builder}::build_attr_set()'");

        # Okay, add the new type to the cache and construct it.
        $types{$params{key}} = \%params;

        # Grab any aliases.
        if (my $alias = delete $params{alias}) {
            if (ref $alias) {
                $types{$_} = \%params for @$alias;
            } else {
                $types{$alias} = \%params;
            }
        }
        return $pkg->new($params{key});
    }
}

##############################################################################
# Instance methods.
##############################################################################

=head1 INSTANCE METHODS

=head2 key

  my $key = $type->key;

Returns the key name for the type.

=cut

sub key  { $_[0]->{key}  }

##############################################################################

=head2 name

  my $name = $type->name;

Returns the type name.

=cut

sub name { $_[0]->{name} }

##############################################################################

=head2 check

  my $checks = $type->check;
  my @checks = $type->check;

Returns an array reference or list of the data type validation code references
for the data type.

=cut

sub check  {
    return unless $_[0]->{check};
    wantarray ? @{$_[0]->{check}} : $_[0]->{check}
}

##############################################################################

=head2 build

Builds the accessors for an attribute of the data type. This method can only
be called by Class::Meta::Attribute or a subclass of Class::Meta::Attribute.

=cut

sub build {
    # Check to make sure that only Class::Meta or a subclass is building
    # attribute accessors.
    my $caller = caller;
    $croak->("Package '$caller' cannot call " . __PACKAGE__ . "->build")
      unless UNIVERSAL::isa($caller, 'Class::Meta::Attribute');

    my $self = shift;
    my $code = $self->{builder};
    $code->(@_, $self->check);
    return $self;
}

##############################################################################

=head2 make_attr_set

  my $attr_name = 'foo';
  my $code = $type->make_attr_set($attr_name);

Returns a code reference that will be used by the
C<Class::Meta::Attribute::call_set()> method to set the value of an object.
Called by Class::Meta::Attribute, and otherwise should not be used.

=cut

sub make_attr_set {
    my $self = shift;
    my $code = $self->{attr_set};
    $code->(@_);
}

##############################################################################

=head2 make_attr_get

  my $attr_name = 'foo';
  my $code = $type->make_attr_get_builder($attr_name);

Returns a code reference that will be used by the
C<Class::Meta::Attribute::call_get()> method to retrieve the value of an
object. Called by Class::Meta::Attribute, and otherwise should not be used.

=cut

sub make_attr_get {
    my $self = shift;
    my $code = $self->{attr_get};
    $code->(@_);
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Attribute|Class::Meta::Attribute>,
L<Class::Meta::AccessorBuilder|Class::Meta::AccessorBuilder>.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2003, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
