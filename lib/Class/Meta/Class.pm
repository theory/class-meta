package Class::Meta::Class;

# $Id: Class.pm,v 1.6 2002/05/16 18:12:47 david Exp $

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Attribute;
use Class::Meta::Method;

sub new {
    my ($pkg, $def) = @_;
    # Check to make sure that only Class::Meta or a subclass is
    # constructing a Class::Meta::Class object.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless grep { $_ eq 'Class::Meta' }
                  $caller, eval '@' . $caller . "::ISA";

    # Okay, create the object.
    return bless { def => $def }, ref $pkg || $pkg;
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

# Attribute objects.
sub my_attrs {
    my $self = shift;
    my $attrs = $self->{def}{attrs};
    if ($_[0]) {
        # Return the requested attributes.
        return @{$attrs}{@_};
    } elsif ($self->{def}{isa}{caller()}) {
        # Return the protected list of attributes.
        return @{$attrs}{@{ $self->{def}{prot_attr_ord} } };
    } else {
        # Return the private list of attributes.
        return @{$attrs}{@{ $self->{def}{attr_ord} } };
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
