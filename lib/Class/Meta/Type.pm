package Class::Meta::Type;

use strict;
use Data::Types;
use Params::Validate ();
use Carp ();

{

    my %types = ( string   => { key  => "string",
				name => "String",
				desc => "String",
				chk  => [ sub { Data::Types::is_string($_) } ],
				conv => sub { Data::Types::to_string(@_) }
			      },

		  boolean  => { key  => "boolean",
				name => "Boolean",
				desc => "Boolean",
				chk  => [ sub { $_ = $_ ? 1 : 0 } ],
				conv => sub { $_ ? 1 : 0 }
			      },

		  whole    => { key  => "whole",
				name => "Whole Number",
				desc => "Whole number",
				chk  => [ sub { Data::Types::is_whole($_) } ],
				conv => sub { Data::Types::to_whole(@_) }
			      },

		  integer  => { key  => "integer",
				name => "Integer",
				desc => "Integer",
				chk => [ sub { Data::Types::is_int($_) } ],
				conv => sub { Data::Types::to_int(@_) }
			      },

		  decimal  => { key  => "decimal",
				name => "Decimal Number",
				desc => "Decimal number",
				chk  => [ sub { Data::Types::is_decimal($_) } ],
				conv => sub { Data::Types::to_decimal(@_) }
			     },

		  real     => { key  => "real",
				name => "Real Number",
				desc => "Real number",
				chk  => [ sub { Data::Types::is_real($_) } ],
				conv => sub { Data::Types::to_real(@_) }
			      },

		  float    => { key  => "float",
				name => "Floating Point Number",
				desc => "Floating point number",
				chk  => [ sub { Data::Types::is_float($_) } ],
				conv => sub { Data::Types::to_float(@_) }
			      },

		  scalar   => { key  => "scalar",
				name => "Scalar Reference",
				desc => "Scalar reference",
				chk  => [ sub { ref $_ eq 'SCALAR' } ],
				conv => sub { \$_[0] }
			      },

		  array    => { key  => "array",
				name => "Array Reference",
				desc => "Array reference",
				chk  => [ sub { ref $_ eq 'ARRAY' } ],
				conv => sub { \@_ }
			      },

		  hash     => { key  => "hash",
				name => "Hash Reference",
				desc => "Hash reference",
				chk  => [ sub { ref $_ eq 'HASH' } ],
				conv => sub { { @_ } }
			      },

		  code     => { key  => "code",
				name => "Code Reference",
				desc => "Code reference",
				chk  => [ sub { ref $_ eq 'CODE' } ],
				conv => sub { { @_ } }
			      },

		  datetime => { key  => "datetime",
			        name => "Date/Time",
				desc => "Date/Time",
				chk => [ sub { ref $_ eq 'Time::Piece::ISO' } ],
				conv => sub { Time::Piece::ISO->strptime
				                ($_[0], $_[1] || '%Y-%m-%dT%T')
					    }
			      },
		);

    # Set up aliases.
    $types{int} = $types{integer};
    $types{bool} = $types{boolean};
    $types{dec} = $types{decimal};
    $types{scalarref} = $types{scalar};
    $types{arrayref} = $types{array};
    $types{hashref} = $types{hash};
    $types{coderef} = $types{code};

    # We'll use this to validate the chk argument..
    my $chk_chk = { 'valid check' => sub {
	my $ref = ref $_[0];
	if ($ref eq 'CODE') {
	    $_[0] = [ $_[0] ];
	    return 1;
	} elsif ($ref eq 'ARRAY') {
	    my @chks;
	    foreach my $chk (@{ $_[0] }) {
		ref $chk eq 'CODE' || return 0;
		push @chks, $chk;
	    }
	    $_[0] = \@chks;
	}
	# Fail if we get here.
	return 0;
    }};

    # Set up validation hash.
    my $spec = { key  => { type => Params::Validate::SCALAR },
		 name => { type => Params::Validate::SCALAR,
			   required => 0
			 },
		 desc => { type => Params::Validate::SCALAR,
			   required => 0 },
		 chk  => { type => Params::Validate::CODEREF
			           | Params::Validate::ARRAYREF,
			   callbacks => $chk_chk
			 },
		 conv => { type => Params::Validate::CODEREF }
	       };

    sub new {
	my $key = lc $_[1];
	Carp::croak("Type '$_[1]' does not exist")
	  unless $types{$key};
	return bless $types{$key}, ref $_[0] || $_[0];
    }

    sub add {
	my $pkg = shift;
	my %params = Params::Validate::validate(@_, $spec);
	$params{key} = lc $params{key};
	Carp::croak("Type '$params{key}' already defined")
	  if exists $types{$params{key}};
	$types{$params{key}} = \%params;
	return $pkg->new($params{key});
    }

}

sub get_key { $_[0]->{key} }
sub get_name { $_[0]->{name} }
sub get_desc { $_[0]->{desc} }
sub get_chk { $_[0]->{chk} }
sub get_conv { $_[0]->{conv} }

1;
__END__
