package Class::Meta::Constructor;

# $Id: Constructor.pm,v 1.17 2003/12/10 07:34:12 david Exp $

use strict;

=head1 NAME

Class::Meta::Construtor - Constructor introspection objects

=head1 SYNOPSIS

  my $ctor = $c->my_ctors('new');
  print "Constructor Name: ", $ctor->my_name, "()\n";
  print "Description: ", $ctor->my_desc, "\n";
  print "Label:       ", $ctor->my_label, "\n";
  print "Visibility:  ", $ctor->my_vis == Class::Meta::PUBLIC
    ? "Public\n"  :      $ctor->my_vis == Class::Meta::PRIVATE
    ? "Private\n" : "Protected\n";

=head1 DESCRIPTION

This class provides an interface to the C<Class::Meta> objects that describe
class constructors. It supports a simple description of the constructor, a
label, and the constructor visibility (private, protected, or public).
Construction is performed internally by C<Class::Meta>, and objects of this
class may be retreived by calling the C<my_ctors()> method on a
C<Class::Meta::Class> object.

=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;
use warnings;

##############################################################################
# Package Globals                                                            #
##############################################################################
our $VERSION = "0.01";
our @CARP_NOT = qw(Class::Meta);

##############################################################################
# Private Package Globals
##############################################################################
my $croak = sub { require Carp; Carp::croak(@_) };

##############################################################################
# Constructors                                                               #
##############################################################################

=head1 CONSTRUCTORS

=head2 new

  my $ctor = Class::Meta::Constructor->new($def, @params);

Creates a new C<Class::Meta::Constructor> object. This is a protected
constructor, callable only from C<Class::Meta> or its subclasses. Use the
C<Class::Meta> C<add_ctor()> object constructor to add a new constructor to a
class. Supported keys are:

=over 4

=item name

The constructor name as it is defined in the class.

=item desc

A description of the constructor.

=item label

A label for the constructor.

=item vis

The visibility of the constructor. Can be one of the three C<Class::Meta>
constants C<PUBLIC>, C<PROTECTED>, or C<PRIVATE>.

=item caller

A code reference that executes a the constructor on an object or class where the
object or class is the first argument to the code reference.

=back

=cut

sub new {
    my $pkg = shift;
    my $spec = shift;

    # Check to make sure that only Class::Meta or a subclass is constructing a
    # Class::Meta::Constructor object.
    my $caller = caller;
    $croak->("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless UNIVERSAL::isa($caller, 'Class::Meta');

    # Make sure we can get all the arguments.
    $croak->("Odd number of parameters in call to new() when named "
             . "parameters were expected" ) if @_ % 2;
    my %p = @_;

    # Validate the name.
    $croak->("Parameter 'name' is required in call to new()")
      unless $p{name};
    $croak->("Method '$p{name}' is not a valid method name "
             . "-- only alphanumeric and '_' characters allowed")
      if $p{name} =~ /\W/;

    # Make sure the name hasn't already been used for another constructor or
    # method.
    $croak->("Method '$p{name}' already exists in class '$spec->{package}'")
      if exists $spec->{ctors}{$p{name}}
      or exists $spec->{meths}{$p{name}};

    # Check the visibility.
    if (exists $p{view}) {
        $croak->("Not a valid view parameter: '$p{view}'")
          unless $p{view} == Class::Meta::PUBLIC
          ||     $p{view} == Class::Meta::PROTECTED
          ||     $p{view} == Class::Meta::PRIVATE;
    } else {
        # Make it public by default.
        $p{view} = Class::Meta::PUBLIC;
    }

    # Validate or create the method caller if necessary.
    if ($p{caller}) {
        my $ref = ref $p{caller};
        $croak->("Parameter caller must be a code reference")
          unless $ref && $ref eq 'CODE'
      } else {
          $p{caller} = eval "sub { shift->$p{name}(\@_) }";
      }

    # Create and cache the constructor object.
    $p{package} = $spec->{package};
    $spec->{ctors}{$p{name}} = bless \%p, ref $pkg || $pkg;

    # Index its view.
    if ($p{view} > Class::Meta::PRIVATE) {
        push @{$spec->{prot_ctor_ord}}, $p{name};
        push @{$spec->{ctor_ord}}, $p{name}
          if $p{view} == Class::Meta::PUBLIC;
    }

    # Let 'em have it.
    return $spec->{ctors}{$p{name}};
}


##############################################################################
# Instance Methods                                                           #
##############################################################################

=head1 INSTANCE METHODS

=head2 my_name

  my $name = $ctor->my_name;

Returns the constructor name.

=cut

sub my_name { $_[0]->{name} }

=head2 my_desc

  my $desc = $ctor->my_desc;

Returns the description of the constructor.

=cut

sub my_desc { $_[0]->{desc} }

=head2 my_label

  my $desc = $ctor->my_label;

Returns label for the constructor.

=cut

sub my_label { $_[0]->{label} }

=head2 my_view

  my $view = $ctor->my_view;

Returns the visibility level of this constructor. Possible values are defined
by the constants C<PRIVATE>, C<PROTECTED>, and C<PUBLIC>, as defined in
C<Class::Meta>.

=cut

sub my_view { $_[0]->{view} }

sub my_package { $_[0]->{package} }

=head2 call

  my $ret = $ctor->call($obj);

Executes the constructor on the $obj object.

=cut

sub call {
    my $code = shift->{caller};
    $code->(@_);
}

sub build {
    my ($self, $specs) = @_;

    # Check to make sure that only Class::Meta or a subclass is building
    # constructors.
    my $caller = caller;
    $croak->("Package '$caller' cannot call " . __PACKAGE__ . "->build")
      unless UNIVERSAL::isa($caller, 'Class::Meta');

    # Build a construtor that takes a parameter list and assigns the
    # the values to the appropriate attributes.
    no strict 'refs';
    *{"$self->{package}::" . $self->my_name } = sub {
        my $class = ref $_[0] ? ref shift : shift;
        my $spec = $specs->{$class};

        # Just grab the parameters and let an error be thrown by Perl
        # if there aren't the right number of them.
        my %p = @_;
        my $new = bless {}, ref $class || $class;

        # Assign all of the attribute values.
        if ($spec->{attrs}) {
            foreach my $attr (values %{ $spec->{attrs} }) {
                my $key = $attr->my_name;
                if ($attr->my_authz >= Class::Meta::SET) {
                    # Let them set the value.
                    $attr->call_set($new, exists $p{$key}
                                      ? delete $p{$key}
                                        : $attr->my_default);
                } else {
                    # Use the default value.
                    $new->{$key} = $attr->my_default;
                }
            }
        }

        # Check for parameters for which attributes that don't exist.
        if (my @attrs = keys %p) {
            # Attempts to assign to non-existent attributes fail.
            my $c = $#attrs > 0 ? 'attributes' : 'attribute';
            local $" = "', '";
            $croak->("No such $c '@attrs' in $self->{package} objects");
        }
        return $new;
    };
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Method|Class::Meta::Method>,
L<Class::Meta::Attribute|Class::Meta::Attribute>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
