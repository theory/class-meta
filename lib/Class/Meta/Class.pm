package Class::Meta::Class;

# $Id: Class.pm,v 1.14 2003/11/24 01:38:28 david Exp $

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
        Carp::croak("Class object for class '$spec->{class}' already exists")
          if $specs{$spec->{class}};

        # Save a reference to the spec hash ref.
        $specs{$spec->{class}} = $spec;

        # Okay, create the class object.
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

    sub build {
        my $self = shift;

        # Check to make sure that only Class::Meta or a subclass is building
        # attribute accessors.
        my $caller = caller;
        Carp::croak("Package '$caller' cannot call " . __PACKAGE__ . "->build")
          unless UNIVERSAL::isa($caller, 'Class::Meta');

        my $spec = $specs{$self->{package}};
        # XXX Is there a way to make this any better, so it's not storing
        # XXX copies of what's in ever parent class?
        # Copy any attributes, constructors, or methods from its parents.
        my @classes = reverse Class::ISA::self_and_super_path($spec->{package});
        for my $key (qw(attr ctor meth)) {
            my (@things, @ord, @prot, %sord, %sprot);
            for my $super (@classes) {
                push @things, %{ $specs{$super}{$key . 's'} }
                  if $specs{$super}{$key . 's'};
                push @ord, grep { not $sord{$_}++ }
                  @{ $specs{$super}{"$key\_ord"} }
                  if $specs{$super}{"$key\_ord"};
                push @prot, grep { not $sprot{$_}++ }
                  @{ $specs{$super}{"prot_$key\_ord"} }
                  if $specs{$super}{"prot_$key\_ord"};
            }

            $spec->{$key} = { @things };
            $spec->{"$key\_ord"} = \@ord;
            $spec->{"prot_$key\_ord"} = \@prot;
        }
    }
}

1;
__END__
