package Class::Meta::Class;

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Property;
use Class::Meta::Method;

{
    my %classes;

    sub new {
	my ($pkg, $class, $spec) = @_;
	# Check to make sure that only Class::Meta or a subclass is instantiating
	# a Class::Meta::Class object.
	my $caller = caller;
	Carp::croak "Package '$caller' cannot create " . __PACKAGE__
	    . " objects" unless grep { $_ eq 'Class::Meta' }
	              $caller, eval '@' . $caller . "::ISA";

	# Make sure that a class object for this class doens't already exist.
	Carp::croak "Class object for class '$class' already exists"
	  if exists $classes{$class};

	# Okay, create the object.
	$classes{$class} = $spec;
	return bless \$class, ref $pkg || $pkg;
    }


    # Basic accessors.
    sub my_key  { $classes{ ${$_[0]} }->{key}  }
    sub my_name { $classes{ ${$_[0]} }->{name} }
    sub my_desc { $classes{ ${$_[0]} }->{desc} }

    # Property objects.
    sub my_props {
	my $self = shift;
	my $props = $classes{ $$self }->{props};
	return $_[0] ?
	  @{$props}{@_} :
	  @{$props}{@{ $classes{ $$self }->{prop_ord} } };
    }

    # Method objects.
    sub my_meths {
	my $self = shift;
	my $meths = $classes{ $$self }->{meths};
	return $_[0] ?
	  @{$meths}{@_} :
	  @{$meths}{@{ $classes{ $$self }->{meth_ord} } };
    }
}

1;
__END__
