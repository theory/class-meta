package Class::Meta::Constructor;

# $Id: Constructor.pm,v 1.5 2003/11/21 21:21:07 david Exp $

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
use Carp ();

##############################################################################
# Package Globals                                                            #
##############################################################################
our $VERSION = "0.01";

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
    my $def = shift;

    # Check to make sure that only Class::Meta or a subclass is constructing a
    # Class::Meta::Constructor object.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless UNIVERSAL::isa($caller, 'Class::Meta');

    # Make sure we can get all the arguments.
    Carp::croak("Odd number of parameters in call to new() when named "
                . "parameters were expected" ) if @_ % 2;
    my %params = @_;

    # Validate the name.
    Carp::croak("Parameter 'name' is required in call to new()")
      unless $params{name};
    Carp::croak("Method '$params{name}' is not a valid method name "
                . "-- only alphanumeric and '_' characters allowed")
      if $params{name} =~ /\W/;

    # Make sure the name hasn't already been used for another constructor or
    # method.
    Carp::croak("Method '$params{name}' already exists in class "
                . "'$def->{class}'")
      if exists $def->{ctors}{$params{name}}
      || exists $def->{meths}{$params{name}};

    # Check the visibility.
    if (exists $params{vis}) {
        Carp::croak("Not a valid vis parameter: '$params{vis}'")
          unless $params{vis} == Class::Meta::PUBLIC
          ||     $params{vis} == Class::Meta::PROTECTED
          ||     $params{vis} == Class::Meta::PRIVATE;
    } else {
        # Make it public by default.
        $params{vis} = Class::Meta::PUBLIC;
    }

    # Validate or create the method caller if necessary.
    if ($params{caller}) {
        my $ref = ref $params{caller};
        Carp::croak("Parameter caller must be a code reference")
          unless $ref && $ref eq 'CODE'
      } else {
          $params{caller} = eval "sub { shift->$params{name}(\@_) }";
      }

    # Create and cache the object and return it.
    $def->{ctors}{$params{name}} = bless \%params, ref $pkg || $pkg;
    return $def->{ctors}{$params{name}};
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

=head2 my_vis

  my $vis = $ctor->my_vis;

Returns the visibility level of this constructor. Possible values are defined
by the constants C<PRIVATE>, C<PROTECTED>, and C<PUBLIC>, as defined in
C<Class::Meta>.

=cut

sub my_vis { $_[0]->{vis} }

=head2 call

  my $ret = $ctor->call($obj);

Executes the constructor on the $obj object.

=cut

sub call {
    my $code = shift->{caller};
    $code->(@_);
}

sub build {
    my ($self, $spec) = @_;

    # Check to make sure that only Class::Meta or a subclass is building
    # constructors.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot call " . __PACKAGE__ . "->build")
      unless UNIVERSAL::isa($caller, 'Class::Meta');

    if ($spec->{attrs}) {
        # Build a construtor that takes a parameter list and assigns the
        # the values to the appropriate attributes.
        no strict 'refs';
        *{"$spec->{package}::" . $self->my_name } = sub {
            my $class = shift;
            my $init = {@_};
            my $new = bless {}, ref $class || $class;

            # Assign all of the attribute values.
            foreach my $attr (values %{ $spec->{attrs} }) {
                next unless $attr->my_authz >= Class::Meta::SET;
                $attr->call_set($new, $init->{$attr->my_name}
                                  || $attr->my_default);
            }
            if (my @attrs = keys %$init) {
                # Attempts to assign to non-existent attributes fail.
                my $c = $#attrs > 0 ? 'attributes' : 'attribute';
                local $" = "', '";
                Carp::croak("No such $c '@attrs' in $self->{package} "
                              . "objects");
            }
            return $new;
        };
    } else {
        # Simple construself.
        no strict 'refs';
        *{"$spec->{package}::" . $self->my_name } = sub {
            my $class = shift;
            bless {}, ref $class || $class;
        }
    }
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
