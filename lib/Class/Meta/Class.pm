package Class::Meta::Class;

# $Id: Class.pm,v 1.10 2003/11/21 23:03:16 david Exp $

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Attribute;
use Class::Meta::Method;

{
    # We'll keep the class specifications in here.
    my %specs;

    ##########################################################################
    sub new {
        my ($pkg, $spec) = @_;
        # Check to make sure that only Class::Meta or a subclass is
        # constructing a Class::Meta::Class object.
        my $caller = caller;
        Carp::croak("Package '$caller' cannot create ", __PACKAGE__,
                    " objects")
          unless UNIVERSAL::isa($caller, 'Class::Meta');

        # Check to make sure we haven't created this class already.
        Carp::croak("Class object for class '$spec->{class}' already exists")
          if $specs{$spec->{class}};

        # Save a reference to the spec hash ref.
        $specs{$spec->{class}} = $spec;

        # Okay, create the object.
        return bless { package => $spec->{class} }, ref $pkg || $pkg;
    }

    ##########################################################################
    # Basic accessors.
    sub my_package { $_[0]->{package}                 }
    sub my_key     { $specs{$_[0]->{package}}->{key}  }
    sub my_name    { $specs{$_[0]->{package}}->{name} }
    sub my_desc    { $specs{$_[0]->{package}}->{desc} }

    ##########################################################################
    # Check inheritance.
    sub is_a { UNIVERSAL::isa($_[0]->{package}, $_[1]) }

    ##########################################################################
    # Create accessors to get at the constructor, attribute, and method
    # objects.
#    for my $t (qw(ctor attr meth)) {

    sub my_ctors {
        my $self = shift;
        my $spec = $specs{$self->{package}};
        my $objs = $spec->{ctors};
        # Explicit list requested.
        my $list = @_ ? \@_
          # List of protected interface objects.
          : UNIVERSAL::isa(scalar caller, $self->{package}) ? $spec->{prot_ctor_ord}
          # List of public interface objects.
          : $spec->{ctor_ord};
        return unless $list;
        return @$list == 1 ? $objs->{$list->[0]} : @{$objs}{@$list};
    }

    sub my_attrs {
        my $self = shift;
        my $spec = $specs{$self->{package}};
        my $objs = $spec->{attrs};
        # Explicit list requested.
        my $list = @_ ? \@_
          # List of protected interface objects.
          : UNIVERSAL::isa(scalar caller, $self->{package}) ? $spec->{prot_attr_ord}
          # List of public interface objects.
          : $spec->{attr_ord};
        return unless $list;
        return @$list == 1 ? $objs->{$list->[0]} : @{$objs}{@$list};
    }

    sub my_meths {
        my $self = shift;
        my $spec = $specs{$self->{package}};
        my $objs = $spec->{meths};
        # Explicit list requested.
        my $list = @_ ? \@_
          # List of protected interface objects.
          : UNIVERSAL::isa(scalar caller, $self->{package}) ? $spec->{prot_meth_ord}
          # List of public interface objects.
          : $spec->{meth_ord};
        return unless $list;
        return @$list == 1 ? $objs->{$list->[0]} : @{$objs}{@$list};
    }
}

1;
__END__
