package Class::Meta::Type;

# $Id: Type.pm,v 1.10 2003/11/22 01:13:11 david Exp $

=head1 NAME

Class::Meta::Type - Data type conversion, validation, and method building.

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
all aspects of data type validation, conversion, and method creation. New
data types can be added to Class::Meta::Type by means of the add()
constructor. This is useful for creating custom types for your
Class::Meta-built classes.

B<Note:>This class manages the most advanced features of C<Class::Meta>.
Before deciding to create your own accessor closures as described in L<add>,
you should have a thorough working knowledge of how Class::Meta works, and
have studied the L<add> method carefully. Simple data type definitions such
as that shown in the <LSYNOPSIS>, on the other hand, are encouraged.

=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;
use Data::Types ();
use DateTime;
use Carp ();

##############################################################################
# Package Globals                                                            #
##############################################################################
use vars qw($VERSION);
$VERSION = "0.01";

##############################################################################
# Closure definition                                                         #
##############################################################################
{
    # This code ref will be used to create most get_* methods.
    my $mk_getter = sub {
        my ($attr) = @_;
        return { "get_$attr" => sub { $_[0]->{$attr} } };
    };

    # This code ref will create Class::Meta::Attribute get code refs.
    my $mk_pgetter = sub { eval "sub { shift->get_$_[0](\@_) }" };

    # This code ref will be used to create most set_* methods.
    my $mk_setter = sub {
        my ($attr, $chk, $conv) = @_;
        if ($conv && $chk) {
            return { "set_$attr" => sub {
                # Convert the value.
                my $val = $conv->(shift);
                # Check the value passed in.
                $_->($val) for @$chk;
                # Assign the value.
                $_[0]->{$attr} = $val;
            }};
        } elsif ($conv) {
            return { "set_$attr" => sub {
                # Convert and assign the value.
                $_[0]->{$attr} = $conv->(shift);
            }};
        } elsif ($chk) {
             return { "set_$attr" => sub {
                # Check the value passed in.
                $_->($_[1]) for @$chk;
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            }};
         } else {
             return { "set_$attr" => sub {
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            }};
         }
    };

    # This code ref will create Class::Meta::Attribute set code refs.
    my $mk_psetter = sub { eval "sub { shift->set_$_[0](\@_) }" };

    # This code ref creates the boolean set methods. They never need
    # to do checks or conversions.
    my $bool_setter = sub {
        my ($attr) = @_;
        return { "set_${attr}_on" =>  sub { $_[0]->{$attr} = 1 },
                 "set_${attr}_off" => sub { $_[0]->{$attr} = 0 } };
    };

    # This code ref creates the Class::Meta::Attribute set method for boolean
    # data types.
    my $bool_psetter = sub {
        eval "sub { \$_[1] ? \$_[0]->set_$_[0]_on : \$_[0]->set_$_[0]_off }";
    };

    # This code ref creates the boolean get method.
    my $bool_getter = sub {
        my ($attr) = @_;
        return { "is_$attr" => sub { $_[0]->{$attr} ? 1 : 0 } };
    };

    # This code ref creates the Class::Meta::Attribute get method for boolean
    # data types.
    my $bool_pgetter = sub { eval "sub { shift->is$_[0](\@_) }" };

    # This code ref builds value checkers.
    my $mk_chk = sub {
        my ($code, $type) = @_;
        return [
            sub {
                return unless defined $_[0];
                $code->($_[0])
                  or Carp::croak("Value '$_[0]' is not a $type");
                }
        ];
    };

    # This code ref builds object/reference value checkers.
    my $mk_isachk = sub {
        my ($pkg, $type);
        return [
            sub {
                return unless defined $_[0];
                UNIVERSAL::isa($_[0], $pkg)
                  or Carp::croak("Value '$_[0]' is not a $type object")
              }
        ];
    };

##############################################################################
# Data type definition storage.
##############################################################################
    my %types =
      ( string   => { key            => "string",
                      name           => "String",
                      desc           => "String",
                      check          => $mk_chk->(\&Data::Types::is_string,
                                            'string'),
                      converter      => sub { Data::Types::to_string(@_) },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        boolean  => { key            => "boolean",
                      name           => "Boolean",
                      desc           => "Boolean",
                      check          => undef,
                      converter      => undef,
                      get_maker      => $bool_getter,
                      set_maker      => $bool_setter,
                      attr_set_maker => $bool_psetter,
                      attr_get_maker => $bool_pgetter
                    },

        whole    => { key            => "whole",
                      name           => "Whole Number",
                      desc           => "Whole number",
                      check          => $mk_chk->(\&Data::Types::is_whole,
                                        'whole number'),
                      converter      => sub { Data::Types::to_whole($_[0]) },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        integer  => { key            => "integer",
                      name           => "Integer",
                      desc           => "Integer",
                      check          => $mk_chk->(\&Data::Types::is_int,
                                                  'integer'),
                      converter      => sub { Data::Types::to_int($_[0]) },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        decimal  => { key            => "decimal",
                      name           => "Decimal Number",
                      desc           => "Decimal number",
                      check          => $mk_chk->(\&Data::Types::is_decimal,
                                        'decimal number'),
                      converter      => sub {Data::Types::to_decimal($_[0])},
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        real     => { key            => "real",
                      name           => "Real Number",
                      desc           => "Real number",
                      check          => $mk_chk->(\&Data::Types::is_real,
                                        'real number'),
                      converter      => sub { Data::Types::to_real($_[0]) },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        float    => { key            => "float",
                      name           => "Floating Point Number",
                      desc           => "Floating point number",
                      check          => $mk_chk->(\&Data::Types::is_float,
                                        'floating point number'),
                      converter      => sub { Data::Types::to_float($_[0]) },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        scalar   => { key            => "scalar",
                      name           => "Scalar",
                      desc           => "Scalar",
                      check          => undef,
                      converter      => undef,
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        scalarref => { key           => "scalarref",
                      name           => "Scalar Reference",
                      desc           => "Scalar reference",
                      check          => $mk_isachk->('SCALAR',
                                                     'scalar reference'),
                      converter      => sub { \$_[0] },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        array    => { key            => "array",
                      name           => "Array Reference",
                      desc           => "Array reference",
                      check          => $mk_isachk->('ARRAY',
                                                     'array reference'),
                      converter      => sub { \@_ },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        hash     => { key            => "hash",
                      name           => "Hash Reference",
                      desc           => "Hash reference",
                      check          => $mk_isachk->('HASH',
                                                     'hash reference'),
                      converter      => sub { { @_ } },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        code     => { key            => "code",
                      name           => "Code Reference",
                      desc           => "Code reference",
                      check          => $mk_isachk->('CODE',
                                                     'code reference'),
                      converter      => sub { sub { @_ } },
                      set_maker      => $mk_setter,
                      get_maker      => $mk_getter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },

        datetime => { key            => "datetime",
                      name           => "Date/Time",
                      desc           => "Date/Time",
                      check          => $mk_isachk->('DateTime',
                                                     'DateTime object'),
                      converter      => sub { DateTime->now },
                      get_maker      => $mk_getter,
                      set_maker      => $mk_setter,
                      attr_set_maker => $mk_psetter,
                      attr_get_maker => $mk_pgetter
                    },
  );

    # Set up aliases.
    $types{int} = $types{integer};
    $types{bool} = $types{boolean};
    $types{dec} = $types{decimal};
    $types{arrayref} = $types{array};
    $types{hashref} = $types{hash};
    $types{coderef} = $types{code};
    $types{closure} = $types{code};

##############################################################################
# Constructors                                                               #
##############################################################################

=head1 CONSTRUCTORS

=head2 new

  my $type = Class::Meta::Type->new($key);

Returns the data type definition for an existing data type. The definition
will be looked up by the $key argument. Existing keys are:

=over 4

=item string

A string.

=item boolean

A boolean data type.

=item bool

An alias for boolean.

=item whole

A whole number.

=item integer

An integer data type.

=item int

An alias for integer.

=item decimal

A decimal number.

=item dec

An alias for decimal.

=item real

A real number.

=item float

A floating point number.

=item scalar

A simple scalar variable.

=item scalarref

A reference to a scalar.

=item arrayref

A reference to an array.

=item array

An alias for arrayref.

=item hashref

A reference to a hash.

=item hash

An alias for hashref.

=item coderef

A code reference, also known as a closure.

=item code

An alias for coderef.

=item closure

An alias for coderef.

=item datetime

A date and time data type in the form of a Time::Piece::ISO object. Note
that the conversion code for this data type will take any time string and a
strptime format as arguments, and create the Time::Piece::ISO object from
those values.

=back

=cut

    sub new {
        my $key = lc $_[1] || Carp::croak("Type argument required");
        Carp::croak("Type '$_[1]' does not exist")
          unless $types{$key};
        return bless $types{$key}, ref $_[0] || $_[0];
    }

##############################################################################

=head2 add

  my $type = Class::Meta::Type->add( key  => 'io_socket',
                                     name => 'IO::Socket Object',
                                     desc => 'IO::Socket object' );

Creates a new data type definition and stores it for future use. Use
this method when the none existing data types won't for a particular
requirement of your class. The named parameter arguments are:

=over 4

=item key

Required. The key with which the datatype can be looked up in the future via
a call to new(). Note that the key will be used case-insensitively, so
"foo", "Foo", and "FOO" are equivalent, and the key must be unique. The keys
listed in the L<new()> method above cannot be used.

=item name

Required. The name of the data type. This should be formatted for display
purposes, and indeed, Class::Meta will often use it in its own exceptions.

=item desc

Optional. A description of the data type.

=item check

Optional. Specifies how to validate the value of a attribute of this type.
The check parameter can be specified in any of the following ways:

=over 4

=item *

As a code reference. When Class::Meta executes this code reference, it will
pass in the value to check and the maximum length of the value (as returned by
C<< Class::Meta::Attribute->my_length >>). The code reference should check the
value of the first argument, and if it's not the proper value for your custom
data type, it should throw an exception. Here's an example; it's the code
reference used by the datetime data type:

  my $datetime_check = sub {
      my $value = shift;
      UNIVERSAL::isa($value, 'DateTime')
        or Carp::croak("Value '$value' is not a DateTime object")
  };

=item *

As an array reference. All items in this array reference must be code
references that perform checks on a value, as specified above.

=item *

As a string. In this case, Class::Meta::Type assumes that you want to
specify that your data type identifies a particular object type. Thus it
will use the string to construct a validation code ref for you. For example,
if you wanted to create a data type for IO::Socket objects, pass the string
'IO::Socket' to the check parameter and Class::Meta::Type will create this
validation code reference:

  my $datetime_check = sub {
      my $value = shift;
      UNIVERSAL::isa($value, 'IO::Socket')
        or Carp::croak("Value '$value' is not a IO::Socket object");
  };

=back

Note that if the C<check> parameter is not specified, there will never be any
validation of your custom data type, even if validation has been enabled in
your Class::Meta object. And yes, there may be times when you want this -- The
default "scalar" and "boolean" data types, for example, have no checks.

=item converter

Optional. A code reference that converts an arbitrary value into a valid
value for your custom data type. The converted value must must be returned
as a single scalar value. Fo exmple, say that you want a data type of
IO::File, but to allow users to pass in the name of a file as well as an
IO::File object. In that case, pass in the following code reference to the
converter parameter:

  sub { return ref $_[0] ? $_[0] : IO::File->new($_[0]) }

Note that if the converter paremeter is not specified, then no values will be
converted for your data type, even if conversion has been enabled in your
Class::Meta object. And yes, there may be times when you want this -- The
default "scalar" and "boolean" data types, for example, perform no
conversion.

=item set_maker

Optional. A code reference that creates set method code references. You can
create as many setters as you like, and return them as a hash reference where
the keys are the method names, and the values are code referernces that
constitute the methods. The arguments to the C<set_maker> code reference are
the name of the attribute for which the method is to be created, an optional
array reference of validation code references, and an optional conversion code
reference. Your closure must create the proper "set" accessor for the
attribute, and execute each of the validation check and/or conversion code
references, if any exist.

Note that if no validation or conversion code references are present (and none
will be if validation and conversion have been disabled in your Class::Meta
object), then, to conserve resources, create the method without any reference
to the missing validation and conversion code references. If, on the other
hand, both validation and conversion code references are present, you I<must>
execute the conversion reference first, so that the validation references
will validate the new value.

The reason you are allowed to create multiple set methods is that sometimes
your attribute may require it. For example, the default "boolean" attribute
creates two accessors, set_attr_on() and set_attr_off(), both to ensure that
the interface accurately describes what the methods do, and to ensure the
integrity of the boolean data.

The following example is the code reference used by Class::Meta::Type if the
set_maker paremter is not specified. It will likely suffice for most uses, but if
you need different functionality, then use it as a template for what you
need:

  my $mk_setter = sub {
      my ($attr, $checkers, $converter) = @_;
      if ($converter && $checkers) {
          return { "set_$attr" => sub {
              my $self = shift;
              # Converterert the value.
              my $val = $converter->(shift());
              # Check the value passed in.
              $_->(@_) for @$checkers;
              # Assign the value.
              $self->{$attr} = $val;
          }};
      } elsif ($converter) {
          return { "set_$attr" => sub {
              my $self = shift;
              # Converterert and assign the value.
              $self->{$attr} = $converter->(shift());
          }};
      } elsif ($checkers) {
          return { "set_$attr" => sub {
              my $self = shift;
              # Check the value passed in.
              $_->(@_) for @$checkers;
              # Assign the value.
              $self->{$attr} = $_[1];
          }};
      } else {
          return { "set_$attr" => sub {
              # Assign the value.
              $_[0]->{$attr} = $_[1];
          }};
      }
  };

=item get_maker

Optional. A code reference that creates get methods. The sole argument to
the code reference is the name of the attribute for which the method is to be
created. As with the set_maker parameter, the code reference should return a hash
reference where the keys are the method names and the values are the
closures that constitute the methods themselves.

The following example is the code reference used by Class::Meta::Type if the
C<get_maker> parameter is not specified. It will likely suffice for most uses,
but if you need different functionality, then use it as a template for what
you need:

  my $mk_getter = sub {
      my ($attr) = @_;
      return { "get_$attr" => sub { $_[0]->{$attr} } };
  };

=item attr_set_maker

Optional. A code reference that generates code references. This code reference
will be used to create the set accessor for the Class::Meta::Attribute
object. The C<attr_set_maker> code reference should expect the name of the attribute
as its sole argument, and return a code reference with that attribute name
hard-coded (by C<eval>ing a string) in a method call on the first argument to
the code reference. If you leave the set attribute above to its default value,
then you are urged to leave this attribute to its default, as well. Here's
what the defalt C<attr_set_maker> closure looks like, and you can use it as a
template for your custom set attributes:

  my $mk_pgetter = sub { eval "sub { shift->get$_[0](\@_) }" };

=item attr_get_maker

Optional. A code reference that generates code references. This code reference
will be used to create the get accessor for the Class::Meta::Attribute
object. The C<attr_get_maker> code reference should expect the name of the attribute
as its sole argument, and return a code reference with that attribute name
hard-coded (by C<eval>ing a string) in a method call on the first argument to
the code reference. If you leave the get attribute above to its default value,
then you are urged to leave this attribute to its default, as well. Here's
what the defalt C<attr_get_maker> closure looks like, and you can use it as a
template for your custom get attributes:

  my $mk_psetter = sub { eval "sub { shift->set$_[0](\@_) }" };

=back

=cut

    sub add {
        my $pkg = shift;
        # Make sure we can process the parameters.
        Carp::croak("Odd number of parameters in call to add() when named ",
                    "parameters were expected" ) if @_ % 2;
        my %params = @_;

        # Check required paremeters.
        foreach (qw(key name)) {
            Carp::croak("Parameter '$_' is required") unless $params{$_};
        }

        # Check the key parameter.
        $params{key} = lc $params{key};
        Carp::croak("Type '$params{key}' already defined")
          if exists $types{$params{key}};

        # Set up the check croak.
        my $chk_die = sub {
            Carp::croak("Paremter 'check' in call to add() must be a code ",
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

        # Check the converter parameter.
        if ($params{converter}) {
            Carp::croak("Paremter 'converter' in call to add() must be a ",
                        "code reference")
              unless ref $params{converter} eq 'CODE';
        }

        # Check the remaining parameters
        my %acc_map = ( set_maker      => $mk_setter,
                        get_maker      => $mk_getter,
                        attr_set_maker => $mk_psetter,
                        attr_get_maker => $mk_pgetter );
        while (my ($p, $c) = each %acc_map) {
            if ($params{$p}) {
                Carp::croak("Parameter '$p' in call to add() must be a code "
                            . "reference") unless ref $params{$p} eq 'CODE';
            } else {
                $params{$p} = $c;
            }
        }

        # Okay, add the new type to the cache and construct it.
        $types{$params{key}} = \%params;
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

=head2 desc

  my $desc = $type->desc;

Returns the type description.

=cut

sub desc { $_[0]->{desc} }

##############################################################################

=head2 check

  my $checks = $type->check;
  my @checks = $type->check;

Returns an array reference or list of the data type validation code checks
for the data type.

=cut

sub check  {
    return unless $_[0]->{check};
    wantarray ? @{$_[0]->{check}} : $_[0]->{check}
}

##############################################################################

=head2 converter

  my $converter = $type->converter;

Returns a the data type conversion code reference.

=cut

sub converter { $_[0]->{converter} }

##############################################################################

=head2 make_set

  my $attr_name = 'foo';
  my $setters = $type->make_set($attr_name);
  $setters = $type->make_set($attr_name, $type->check);
  $setters = $type->make_set($attr_name, undef, $type->converter);
  $setters = $type->make_set($attr_name, $type->check, $type->converter);

Returns a hash reference of set method code references. The hash keys are the
names of the methods (e.g., "set_foo"), and the values are code references
that will be made into actual methods under their names. See the description
of the C<set_maker> parameter to the add() constructor above for more
information.

=cut

sub make_set {
    my $code = shift->{set_maker};
    $code->(@_);
}

##############################################################################

=head2 make_get

  my $attr_name = 'foo';
  my $getters = $type->make_get($attr_name);

Returns a hash reference of get method code references. The hash keys are
the names of the methods (e.g., "get_foo"), and the values are code
references that will be made into actual methods under their names. See the
description of the C<get> parameter to the add() constructor above for more
information.

=cut

sub make_get {
    my $code = shift->{get_maker};
    $code->(@_)
}

##############################################################################

=head2 make_attr_set

  my $attr_name = 'foo';
  my $code = $type->make_attr_set($attr_name);

Returns a code reference that will be used by the
Class::Meta::Attribute::set() method to retreive the value of an object. See
the description of the C<attr_set> parameter to the add() constructor above
for more information.

=cut

sub make_attr_set {
    my $code = shift->{attr_set_maker};
    $code->(@_);
}

##############################################################################

=head2 make_attr_get

  my $attr_name = 'foo';
  my $code = $type->make_attr_get_maker($attr_name);

Returns a code reference that will be used by the
Class::Meta::Attribute::get() method to retreive the value of an object. See
the description of the C<attr_get_maker> parameter to the add() constructor above
for more information.

=cut

sub make_attr_get {
    my $code = shift->{attr_get_maker};
    $code->(@_);
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Attribute|Class::Meta::Attribute>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2003, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
