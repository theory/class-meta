package Class::Meta::Attribute;

# $Id: Attribute.pm,v 1.8 2002/06/07 21:53:05 david Exp $

=head1 NAME

Kinet::Meta::Attribute - Objects describing Kinet object attributes.

=head1 SYNOPSIS



=head1 DESCRIPTION



=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;
use Carp ();

##############################################################################
# Constants                                                                  #
##############################################################################
use constant DEBUG => 0;

##############################################################################
# Package Globals                                                            #
##############################################################################
use vars qw($VERSION);
$VERSION = "0.01";

##############################################################################
# Constructors                                                               #
##############################################################################

sub new {
    my $pkg = shift;
    my $def = shift;

    # Check to make sure that only Class::Meta or a subclass is constructing a
    # Class::Meta::Attribute object.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless grep { $_ eq 'Class::Meta' }
                  $caller, eval '@' . $caller . "::ISA";

    # Make sure we can get all the arguments.
    Carp::croak("Odd number of parameters in call to new() when named "
                . "parameters were expected" ) if @_ % 2;
    my %params = @_;

    # Validate the name.
    Carp::croak("Parameter 'name' is required in call to new()")
      unless $params{name};
    Carp::croak("Attribute '$params{name}' is not a valid attribute name "
                . "-- only alphanumeric and '_' characters allowed")
      if $params{name} =~ /\W/;

    # Make sure the name hasn't already been used for another attribute
    Carp::croak("Attribute '$params{name}' already exists in class "
                . "'$def->{class}'")
      if exists $def->{attrs}{$params{name}};

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

    # Check the authorization level.
    if (exists $params{auth}) {
        Carp::croak("Not a valid auth parameter: '$params{auth}'")
          unless $params{auth} == Class::Meta::NONE
          ||     $params{auth} == Class::Meta::READ
          ||     $params{auth} == Class::Meta::WRITE
          ||     $params{auth} == Class::Meta::RDWR;
    } else {
        # Make it read/write by default.
        $paarms{auth} = Class::Meta::RDWR;
    }

    # Check the context.
    if (exists $params{context}) {
        Carp::croak("Not a valid context parameter: '$params{context}'")
          unless $params{context} == Class::Meta::OBJECT
          ||     $params{context} == Class::Meta::CLASS;
    } else {
        # Put it in object context by default.
        $params{context} = Class::Meta::OBJECT;
    }

    # Create and cache the object and return it.
    $def->{attrs}{$params{name}} = bless \%params, ref $pkg || $pkg;
    return $def->{attrs}{$params{name}};
}

##############################################################################
# Instance Methods                                                           #
##############################################################################

sub my_name    { $_[0]->{name} }
sub my_vis     { $_[0]->{vis} }
sub my_context { $_[0]->{context} }
sub my_auth    { $_[0]->{auth} }
sub my_type    { $_[0]->{type} }
sub my_length  { $_[0]->{length} }
sub my_label   { $_[0]->{label} }
sub my_field   { $_[0]->{field} }
sub my_desc    { $_[0]->{desc} }
sub is_req     { $_[0]->{req} }
sub my_def     { $_[0]->{def} }

sub my_vals   {
    my $vals = $_[0]->{vals};
    ref $vals eq 'CODE' ? $vals->() : $vals;
}

sub call_get   {
    my $code = shift->{_get};
    $code->(@_);
}

sub call_set   {
    my $code = shift->{_set};
    $code->(@_);
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>,
L<Class::Meta|Class::Meta::Method>,
L<Class::Meta|Class::Meta::Constructor>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut


1;
__END__
