package Class::Meta::Class;

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Property;
use Class::Meta::Method;

sub new {
    my ($pkg, $spec) = @_;
    # Check to make sure that only Class::Meta or a subclass is
    # constructing a Class::Meta::Class object.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless grep { $_ eq 'Class::Meta' }
                  $caller, eval '@' . $caller . "::ISA";

    # Okay, create the object.
    return bless $spec, ref $pkg || $pkg;
}

# Basic accessors.
sub my_key  { $_[0]->{def}{key}  }
sub my_pkg  { $_[0]->{def}{pkg}  }
sub my_name { $_[0]->{def}{name} }
sub my_desc { $_[0]->{def}{desc} }

# Check inheritance.
sub isa { exists $_[0]->{def}{isa}{$_[1]} }

# Constructor objects.
sub my_ctors {
    my $self = shift;
    my $ctors = $self->{def}{ctors};
    if ($_[0]) {
	# Return the requested constructors.
	return @{$ctors}{@_};
    } elsif ($self->{def}{isa}{caller()}) {
	# Return the protected list of constructors.
	return @{$ctors}{@{ $self->{def}{prot_ctor_ord} } };
    } else {
	# Return the private list of constructors.
	return @{$ctors}{@{ $self->{def}{ctor_ord} } };
    }
}

# Property objects.
sub my_props {
    my $self = shift;
    my $props = $self->{def}{props};
    if ($_[0]) {
	# Return the requested properties.
	return @{$props}{@_};
    } elsif ($self->{def}{isa}{caller()}) {
	# Return the protected list of properties.
	return @{$props}{@{ $self->{def}{prot_prop_ord} } };
    } else {
	# Return the private list of properties.
	return @{$props}{@{ $self->{def}{prop_ord} } };
    }
}

# Method objects.
sub my_meths {
    my $self = shift;
    my $meths = $self->{def}{meths};
    if ($_[0]) {
	# Return the requested methods.
	return @{$meths}{@_};
    } elsif ($self->{def}{isa}{caller()}) {
	# Return the protected list of methods.
	return @{$meths}{@{ $self->{def}{prot_meth_ord} } };
    } else {
	# Return the private list of methods.
	return @{$meths}{@{ $self->{def}{meth_ord} } };
    }
}

1;
__END__
