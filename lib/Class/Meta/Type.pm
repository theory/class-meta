package Class::Meta::Type;

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
use Carp ();

##############################################################################
# Closure definition.
##############################################################################
{
    # This code ref will be used to create most get_* methods.
    my $mk_getter = sub {
	my ($prop) = @_;
	return { "get_$prop" => sub { $_[0]->{$prop} } };
    };

    # This code ref will create Class::Meta::Property get code refs.
    my $mk_pgetter = sub { eval "sub { shift->get$_[0](\@_) }" };

    # This code ref will be used to create most set_* methods.
    my $mk_setter = sub {
	my ($prop, $conv, $chk) = @_;
	if ($conv && $chk) {
	    return { "set_$prop" => sub {
		my $self = shift;
		# Convert the value.
		my $val = $conv->(shift());
		# Check the value passed in.
		for (@$chk) { $_->($val, @_) }
		# Assign the value.
		$self->{$prop} = $val;
	    }};
	} elsif ($conv) {
	    return { "set_$prop" => sub {
		my $self = shift;
		# Convert and assign the value.
		$self->{$prop} = $conv->(shift());
	    }};
	} elsif ($chk) {
	     return { "set_$prop" => sub {
		my $self = shift;
		# Check the value passed in.
		for (@$chk) { $_->(@_) }
		# Assign the value.
		$self->{$prop} = $_[1];
	    }};
	 } else {
	     return { "set_$prop" => sub {
		# Assign the value.
		$_[0]->{$prop} = $_[1];
	    }};
	 }
    };

    # This code ref will create Class::Meta::Property set code refs.
    my $mk_psetter = sub { eval "sub { shift->set$_[0](\@_) }" };

    # This code ref creates the boolean set methods. They never need
    # to do checks or conversions.
    my $bool_setter = sub {
	my ($prop) = @_;
	return { "set_${prop}_on" =>  sub { $_[0]->{$prop} = 1 },
		 "set_${prop}_off" => sub { $_[0]->{$prop} = 0 } };
    };

    # This code ref creates the Class::Meta::Property set method for boolean
    # data types.
    my $bool_psetter = sub {
	eval "sub { \$_[1] ? \$_[0]->set_$_[0]_on : \$_[0]->set_$_[0]_off }";
    };

    # This code ref creats the boolean get method.
    my $bool_getter = sub {
	my ($prop) = @_;
	return { "is_$prop" => sub { $_[0]->{$prop} ? 1 : 0 } };
    };

    # This code ref creates the Class::Meta::Property get method for boolean
    # data types.
    my $bool_pgetter = sub { eval "sub { shift->is$_[0](\@_) }" };

    # This code ref builds value checkers.
    my $mk_chk = sub {
	my ($code, $type) = @_;
	return [ sub {
	    $code->($_[0]) ||
	      Carp::croak("Value '$_[0]' is not a valid $type")
	} ];
    };

    # This code ref builds reference value checkers.
    my $mk_refchk = sub {
	my ($ref, $type) = @_;
	return [ sub {
	    ref $_[0] eq $ref ||
	      Carp::croak("Value '$_[0]' is not a valid $type")
	} ];
    };

    # This will be the defult check for all custom types. It validates
    # object types.
    my $mk_isachk = sub {
	my ($ref, $type);
	return [ sub {
	    UNIVERSAL::isa($_[0], $ref) ||
		Carp::croak("Value '$_[0]' is not a $type object")
	} ];
    };

##############################################################################
# Data type definition storage.
##############################################################################
    my %types =
      ( string   => { key      => "string",
		      name     => "String",
		      desc     => "String",
		      chk      => $mk_chk->(\&Data::Types::is_string,
					    'string'),
		      conv     => sub { Data::Types::to_string(@_) },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	boolean  => { key      => "boolean",
		      name     => "Boolean",
		      desc     => "Boolean",
		      chk      => undef,
		      conv     => undef,
		      get      => $bool_getter,
		      set      => $bool_setter,
		      prop_set => $bool_psetter,
		      prop_get => $bool_pgetter
		    },

	whole    => { key      => "whole",
		      name     => "Whole Number",
		      desc     => "Whole number",
		      chk      => $mk_chk->(\&Data::Types::is_whole,
					'whole number'),
		      conv     => sub { Data::Types::to_whole($_[0]) },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	integer  => { key      => "integer",
		      name     => "Integer",
		      desc     => "Integer",
		      chk      => $mk_chk->(\&Data::Types::is_int, 'integer'),
		      conv     => sub { Data::Types::to_int($_[0]) },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	decimal  => { key      => "decimal",
		      name     => "Decimal Number",
		      desc     => "Decimal number",
		      chk      => $mk_chk->(\&Data::Types::is_decimal,
					'decimal number'),
		      conv     => sub {Data::Types::to_decimal($_[0])},
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	real     => { key      => "real",
		      name     => "Real Number",
		      desc     => "Real number",
		      chk      => $mk_chk->(\&Data::Types::is_real,
					'real number'),
		      conv     => sub { Data::Types::to_real($_[0]) },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	float    => { key      => "float",
		      name     => "Floating Point Number",
		      desc     => "Floating point number",
		      chk      => $mk_chk->(\&Data::Types::is_float,
					'floating point number'),
		      conv     => sub { Data::Types::to_float($_[0]) },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	scalar   => { key      => "scalar",
		      name     => "Scalar",
		      desc     => "Scalar",
		      chk      => undef,
		      conv     => undef,
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	scalarref => { key      => "scalarref",
		      name     => "Scalar Reference",
		      desc     => "Scalar reference",
		      chk      => $mk_refchk->('SCALAR', 'scalar reference'),
		      conv     => sub { \$_[0] },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	array    => { key      => "array",
		      name     => "Array Reference",
		      desc     => "Array reference",
		      chk      => $mk_refchk->('ARRAY', 'array reference'),
		      conv     => sub { \@_ },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	hash     => { key      => "hash",
		      name     => "Hash Reference",
		      desc     => "Hash reference",
		      chk      => $mk_refchk->('HASH', 'hash reference'),
		      conv     => sub { { @_ } },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	code     => { key      => "code",
		      name     => "Code Reference",
		      desc     => "Code reference",
		      chk      => $mk_refchk->('CODE', 'code reference'),
		      conv     => sub { sub { @_ } },
		      set      => $mk_setter,
		      get      => $mk_getter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
		    },

	datetime => { key      => "datetime",
		      name     => "Date/Time",
		      desc     => "Date/Time",
		      chk      => $mk_refchk->('Time::Piece::ISO',
					   'Time::Piece::ISO object'),
		      conv     => sub { Time::Piece::ISO->strptime
				      ($_[0], $_[1] || '%Y-%m-%dT%T'),
				  },
		      get     => $mk_getter,
		      set     => $mk_setter,
		      prop_set => $mk_psetter,
		      prop_get => $mk_pgetter
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
will be looked up by the $key. Existing keys are:

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

=item chk

Optional. Specifies how to validate the value of a property of this type.
The chk parameter can be specified in any of the following ways:

=over 4

=item *

As a code reference. When Class::Meta executes this code reference, it will
pass in the value to check and the maximum length of the value [as specified
returned from Class::Meta::Property::my_length()]. The code reference should
check the value of the first argument, and if it's not the proper value for
your custom data type, it should throw an exception. Here's an example; it's
the code reference used by the datetime data type:

  my $datetime_chk = sub {
      ref $_[0] eq 'Time::Piece::ISO'
        || Carp::croak("Value '$_[0]' is not a Time::Piece::ISO object")
  };

=item *

As an array reference. All items in this array reference must be code
references that perform checks on a value, as specified above.

=item *

As a string. In this case, Class::Meta::Type assumes that you want to
specify that your data type identifies a particular object type. Thus it
will use the string to construct a validation code ref for you. For example,
if you wanted to create a data type for IO::Socket objects, pass the string
'IO::Socket' to the chk parameter and Class::Meta::Type will create this
validation code reference:

  sub {
      UNIVERSAL::isa($_[0], 'IO::Socket')
        || Carp::croak("Value '$_[0]' is not a valid IO::Socket object")
  };

=back

Note that if the chk parameter is not specified, there will never be any
validation of your custom data type, even if validation has been enabled in
your Class::Meta object. And yes, there may be times when you want this --
The default "scalar" and "boolean" data types, for example, have no checks.

=item conv

Optional. A code reference that converts an arbitrary value into a valid
value for your custom data type. The converted value must must be returned
as a single scalar value. Fo exmple, say that you want a data type of
IO::File, but to allow users to pass in the name of a file as well as an
IO::File object. In that case, pass in the following code reference to the
conv parameter:

  sub { return ref $_[0] ? $_[0] : IO::File->new($_[0]) }

Note that if the conv paremeter is not specified, then no values will be
converted for your data type, even if conversion has been enabled in your
Class::Meta object. And yes, there may be times when you want this -- The
default "scalar" and "boolean" data types, for example, perform no
conversion.

=item set

Optional. A code reference that creates set methods code references. You can
create as many setters as you like, and return them as a hash reference
where the keys are the method names, and the values are code referernces
that constitute the methods. The arguments to the set code reference are the
name of the property for which the method is to be created, an optional
array reference of validation code references, and an optional conversion
code reference. Your closure must create the proper "set" accessor for the
property, and execute each of the validation check and/or conversion code
references, if any exist.

Note that, if no validation or conversion code references are present (and
none will be, if validation and conversion have been disabled in your
Class::Meta object), then, to conserve resources, create the method without
any reference to the missing validation and conversion code references. If,
on the other hand, both validation and conversion code references are
present, you I<must> execute the conversion reference, first, so that the
validation references will validate the new value.

The reason you are allowed to create multiple set methods is that sometimes
your property may require it. For example, the default "boolean" property
creates two accessors, set_prop_on() and set_prop_off(), both to ensure that
the interface accurately describes what the methods do, and to ensure the
integrity of the boolean data.

The following example is the code reference used by Class::Meta::Type if the
set paremter is not specified. It will likely suffice for most uses, but if
you need different functionality, then use it as a template for what you
need:

  my $mk_setter = sub {
      my ($prop, $conv, $chk) = @_;
      if ($conv && $chk) {
          return { "set_$prop" => sub {
              my $self = shift;
              # Convert the value.
              my $val = $conv->(shift());
              # Check the value passed in.
              for (@$chk) { $_->($val, @_) }
              # Assign the value.
              $self->{$prop} = $val;
          }};
      } elsif ($conv) {
          return { "set_$prop" => sub {
              my $self = shift;
              # Convert and assign the value.
              $self->{$prop} = $conv->(shift());
          }};
      } elsif ($chk) {
          return { "set_$prop" => sub {
              my $self = shift;
              # Check the value passed in.
              for (@$chk) { $_->(@_) }
              # Assign the value.
              $self->{$prop} = $_[1];
          }};
      } else {
          return { "set_$prop" => sub {
              # Assign the value.
              $_[0]->{$prop} = $_[1];
          }};
      }
  };

=item get

Optional. A code reference that creates get methods. The sole argument to
the code reference is the name of the property for which the method is to be
created. As with the set parameter, the code reference should return a hash
reference where the keys are the method names and the values are the
closures that constitute the methods themselves.

The following example is the code reference used by Class::Meta::Type if the
get paremter is not specified. It will likely suffice for most uses, but if
you need different functionality, then use it as a template for what you
need:

  my $mk_getter = sub {
      my ($prop) = @_;
      return { "get_$prop" => sub { $_[0]->{$prop} } };
  };

=item prop_set

Optional. A code reference that generates code references. This code
reference will be used to create the set accessor for the
Class::Meta::Property object. The C<prop_set> code reference should expect
the name of the property as its sole argument, and return a code reference
with that property name hard-coded (by C<eval>ing a string) in a method call
on the first argument to the code reference. If you left the set property
above to its default value, then you are urged to leave this property to its
default, as well. Here's what the defalt C<prop_set> closure looks like, and
you can use it as a template for your custom set properties:

  my $mk_pgetter = sub { eval "sub { shift->get$_[0](\@_) }" };

=item prop_get

Optional. A code reference that generates code references. This code
reference will be used to create the get accessor for the
Class::Meta::Property object. The C<prop_get> code reference should expect the
name of the property as its sole argument, and return a code reference with
that property name hard-coded (by C<eval>ing a string) in a method call on
the first argument to the code reference. If you left the get property above
to its default value, then you are urged to leave this property to its
default, as well. Here's what the defalt C<prop_get> closure looks like, and
you can use it as a template for your custom get properties:

  my $mk_psetter = sub { eval "sub { shift->set$_[0](\@_) }" };

=back

=cut

    sub add {
	my $pkg = shift;
	# Make sure we can process the parameters.
	Carp::croak("Odd number of parameters in call to add() when named "
		    . "parameters were expected" ) if @_ % 2;
	my %params = @_;

	# Check required paremeters.
	foreach (qw(key name)) {
	    Carp::croak("Parameter '$_' is required") unless $params{$_};
	}

	# Check the key parameter.
	$params{key} = lc $params{key};
	Carp::croak("Type '$params{key}' already defined")
	  if exists $types{$params{key}};

	# Set up the chk croak.
	my $chk_die = sub {
	    Carp::croak("Paremter 'chk' in call to add() must be a code "
			. "reference, an array of code references, or a "
			. "scalar naming an object type");
	};

	# Check the chk parameter.
	if ($params{chk}) {
	    my $ref = ref $params{chk};
	    if (!$ref) {
		# It names the object to be checked.
		$params{chk} = $mk_isachk->(@params{qw(chk name)});
	    } elsif ($ref eq 'CODE') {
		$params{chk} = [$params{chk}]
	    } elsif ($ref eq 'ARRAY') {
		# Make sure that they're all code references.
		foreach my $chk (@{$params{chk}}) {
		    $chk_die->() unless ref $chk eq 'CODE';
		}
	    } else {
		# It's bogus.
		$chk_die->();
	    }
	}

	# Check the conv parameter.
	if ($params{conv}) {
	    Carp::croak("Paremter 'conv' in call to add() must be a code "
			. "reference")
	      unless ref $params{conv} eq 'CODE';
	}

	# Check the remaining parameters
	my %acc_map = ( set => $mk_setter,
			get => $mk_getter,
			prop_set => $mk_psetter,
			prop_get => $mk_pgetter );
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

=head2 get_key

  my $key = $type->get_key;

Returns the key name for the type.

=cut

sub get_key  { $_[0]->{key}  }

##############################################################################

=head2 get_name

  my $name = $type->get_name;

Returns the type name.

=cut

sub get_name { $_[0]->{name} }

##############################################################################

=head2 get_desc

  my $desc = $type->get_desc;

Returns the type description.

=cut

sub get_desc { $_[0]->{desc} }

##############################################################################

=head2 get_chk

  my $chks = $type->get_chk;
  my @chks = $type->get_chk;

Returns an array reference or list of the data type validation code checks
for the data type.

=cut

sub get_chk  {
    return unless $_[0]->{chk};
    wantarray ? @{$_[0]->{chk}} : $_[0]->{chk}
}

##############################################################################

=head2 get_conv

  my $conv = $type->get_conv;

Returns a the data type conversion code reference.

=cut

sub get_conv { $_[0]->{conv} }

##############################################################################

=head2 mk_set

  my $prop_name = 'foo';
  my $setters = $type->mk_set($prop_name);
  $setters = $type->mk_set($prop_name, $type->get_chk);
  $setters = $type->mk_set($prop_name, undef, $type->get_conv);
  $setters = $type->mk_set($prop_name, $type->get_chk, $type->get_conv);

Returns a hash reference of set method code references. The hash keys are
the names of the methods (e.g., "set_foo"), and the values are code
references that will be made into actual methods under their names. See the
description of the C<set> parameter to the add() constructor above for more
information.

=cut

sub mk_set {
    my $code = shift->{set};
    $code->(@_);
}

##############################################################################

=head2 mk_get

  my $prop_name = 'foo';
  my $getters = $type->mk_get($prop_name);

Returns a hash reference of get method code references. The hash keys are
the names of the methods (e.g., "get_foo"), and the values are code
references that will be made into actual methods under their names. See the
description of the C<get> parameter to the add() constructor above for more
information.

=cut

sub mk_get {
    my $code = shift->{get};
    $code->(@_)
}

##############################################################################

=head2 mk_prop_set

  my $prop_name = 'foo';
  my $code = $type->mk_prop_set($prop_name);

Returns a code reference that will be used by the
Class::Meta::Property::set() method to retreive the value of an object. See
the description of the C<prop_set> parameter to the add() constructor above
for more information.

=cut

sub mk_prop_set {
    my $code = shift->{prop_set};
    $code->(@_);
}

##############################################################################

=head2 mk_prop_get

  my $prop_name = 'foo';
  my $code = $type->mk_prop_get($prop_name);

Returns a code reference that will be used by the
Class::Meta::Property::get() method to retreive the value of an object. See
the description of the C<prop_get> parameter to the add() constructor above
for more information.

=cut

sub mk_prop_get {
    my $code = shift->{prop_get};
    $code->(@_);
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Property|Class::Meta::Property>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
