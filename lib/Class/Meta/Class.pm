package Class::Meta::Class;

# $Id: Class.pm,v 1.7 2002/05/17 23:32:56 david Exp $

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Attribute;
use Class::Meta::Method;

{
    # We'll keep the class definitions in here.
    my %defs;

    sub new {
        my ($pkg, $def) = @_;
        # Check to make sure that only Class::Meta or a subclass is
        # constructing a Class::Meta::Class object.
        my $caller = caller;
        Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
          unless grep { $_ eq 'Class::Meta' }
          $caller, eval '@' . $caller . "::ISA";

        # Check to make sure we haven't created this class already.
        Carp::croak("Class object for class '$def->{pkg}' already exists")
          if $defs{$def->{pkg}};

        # Save a reference to the def hash ref.
        $defs{$def->{pkg}} = $def;

        # Okay, create the object.
        return bless { pkg => $def->{pkg} }, ref $pkg || $pkg;
    }

    # Basic accessors.
    sub my_key  { $defs{$_[0]->{pkg}}->{key}  }
    sub my_pkg  { $_[0]->{pkg}  }
    sub my_name { $defs{$_[0]->{pkg}}->{name} }
    sub my_desc { $defs{$_[0]->{pkg}}->{desc} }

    # Check inheritance.
    sub isa { exists $defs{$_[0]->{pkg}}->{isa}{$_[1]} }

    # Constructor objects.
    sub my_ctors {
        my $self = shift;
        my $ctors = $defs{$_[0]->{pkg}}->{ctors};
        if ($_[0]) {
            # Return the requested constructors.
            return @{$ctors}{@_};
        } elsif ($defs{$_[0]->{pkg}}->{isa}{caller()}) {
            # Return the protected list of constructors.
            return @{$ctors}{@{ $defs{$_[0]->{pkg}}->{prot_ctor_ord} } };
        } else {
            # Return the private list of constructors.
            return @{$ctors}{@{ $defs{$_[0]->{pkg}}->{ctor_ord} } };
        }
    }

    # Attribute objects.
    sub my_attrs {
        my $self = shift;
        my $attrs = $defs{$_[0]->{pkg}}->{attrs};
        if ($_[0]) {
            # Return the requested attributes.
            return @{$attrs}{@_};
        } elsif ($defs{$_[0]->{pkg}}->{isa}{caller()}) {
            # Return the protected list of attributes.
            return @{$attrs}{@{ $defs{$_[0]->{pkg}}->{prot_attr_ord} } };
        } else {
            # Return the private list of attributes.
            return @{$attrs}{@{ $defs{$_[0]->{pkg}}->{attr_ord} } };
        }
    }

    # Method objects.
    sub my_meths {
        my $self = shift;
        my $meths = $defs{$_[0]->{pkg}}->{meths};
        if ($_[0]) {
            # Return the requested methods.
            return @{$meths}{@_};
        } elsif ($defs{$_[0]->{pkg}}->{isa}{caller()}) {
            # Return the protected list of methods.
            return @{$meths}{@{ $defs{$_[0]->{pkg}}->{prot_meth_ord} } };
        } else {
            # Return the private list of methods.
            return @{$meths}{@{ $defs{$_[0]->{pkg}}->{meth_ord} } };
        }
    }
}

1;
__END__
