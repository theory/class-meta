package Class::Meta::Class;

# $Id: Class.pm,v 1.16 2003/11/25 01:21:31 david Exp $

use strict;
use Carp ();
use Class::ISA ();
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
        Carp::croak("Class object for class '$spec->{package}' already exists")
          if $specs{$spec->{package}};

        # Save a reference to the spec hash ref.
        $specs{$spec->{package}} = $spec;

        # Okay, create the class object.
        my $self = bless { package => $spec->{package} }, ref $pkg || $pkg;

        # Copy its parents' attributes and return.
        return $self->_inherit('attr');
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

    sub build {
        my $self = shift;

        # Check to make sure that only Class::Meta or a subclass is building
        # attribute accessors.
        my $caller = caller;
        Carp::croak("Package '$caller' cannot call " . __PACKAGE__ . "->build")
          unless UNIVERSAL::isa($caller, 'Class::Meta');
        $self->_inherit(qw(ctor meth));
    }

    sub _inherit {
        my $self = shift;
        my $spec = $specs{$self->{package}};

        # Get a list of all of the parent classes.
        my @classes = reverse Class::ISA::self_and_super_path($spec->{package});

        # For each metadata class, copy the parents' objects.
        for my $key (@_) {
            my (@things, @ord, @prot, %sord, %sprot);
            for my $super (@classes) {
                push @things, %{ $specs{$super}{"${key}s"} }
                  if $specs{$super}{$key . 's'};
                push @ord, grep { not $sord{$_}++ }
                  @{ $specs{$super}{"$key\_ord"} }
                  if $specs{$super}{"$key\_ord"};
                push @prot, grep { not $sprot{$_}++ }
                  @{ $specs{$super}{"prot_$key\_ord"} }
                  if $specs{$super}{"prot_$key\_ord"};
            }

            $spec->{"${key}s"}         = { @things } if @things;
            $spec->{"$key\_ord"}      = \@ord       if @ord;
            $spec->{"prot_$key\_ord"} = \@prot      if @prot;
        }
        return $self;
    }
}

1;
__END__
