package Class::Meta::Attribute;

# $Id: Attribute.pm,v 1.9 2003/11/19 03:57:46 david Exp $

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
    my $spec = shift;

    # Check to make sure that only Class::Meta or a subclass is constructing a
    # Class::Meta::Attribute object.
    my $caller = caller;
    Carp::croak("Package '$caller' cannot create " . __PACKAGE__ . " objects")
      unless grep { $_ eq 'Class::Meta' }
                  $caller, eval '@' . $caller . "::ISA";

    # Make sure we can get all the arguments.
    Carp::croak("Odd number of parameters in call to new() when named "
                . "parameters were expected" ) if @_ % 2;
    my %p = @_;

    # Validate the name.
    Carp::croak("Parameter 'name' is required in call to new()")
      unless $p{name};
    # Is this too paranoid?
    Carp::croak("Attribute '$p{name}' is not a valid attribute name "
                . "-- only alphanumeric and '_' characters allowed")
      if $p{name} =~ /\W/;

    # Make sure the name hasn't already been used for another attribute
    Carp::croak("Attribute '$p{name}' already exists in class "
                . "'$spec->{class}'")
      if exists $spec->{attrs}{$p{name}};

    # Check the view.
    if (exists $p{view}) {
        Carp::croak("Not a valid view parameter: '$p{view}'")
          unless $p{view} == Class::Meta::PUBLIC
          or     $p{view} == Class::Meta::PROTECTED
          or     $p{view} == Class::Meta::PRIVATE;
    } else {
        # Make it public by default.
        $p{view} = Class::Meta::PUBLIC;
    }

    # Check the authorization level.
    if (exists $p{authz}) {
        Carp::croak("Not a valid authz parameter: '$p{authz}'")
          unless $p{authz} == Class::Meta::NONE
          or     $p{authz} == Class::Meta::READ
          or     $p{authz} == Class::Meta::WRITE
          or     $p{authz} == Class::Meta::RDWR;
    } else {
        # Make it read/write by default.
        $p{authz} = Class::Meta::RDWR;
    }

    # Check the context.
    if (exists $p{context}) {
        Carp::croak("Not a valid context parameter: '$p{context}'")
          unless $p{context} == Class::Meta::OBJECT
          or     $p{context} == Class::Meta::CLASS;
    } else {
        # Put it in object context by default.
        $p{context} = Class::Meta::OBJECT;
    }

    # Check the default.
    if (exists $p{default}) {
        # A code ref should be executed when the default is called.
        $p{_def_code} = delete $p{default}
          if ref $p{default} eq 'CODE';
    }

    # Create and cache the object and return it.
    $spec->{attrs}{$p{name}} = bless \%p, ref $pkg || $pkg;
    return $spec->{attrs}{$p{name}};
}

##############################################################################
# Instance Methods                                                           #
##############################################################################

sub my_name     { $_[0]->{name}     }
sub my_view     { $_[0]->{view}     }
sub my_context  { $_[0]->{context}  }
sub my_authz    { $_[0]->{authz}    }
sub my_type     { $_[0]->{type}     }
sub my_length   { $_[0]->{length}   }
sub my_label    { $_[0]->{label}    }
sub my_field    { $_[0]->{field}    }
sub my_desc     { $_[0]->{desc}     }
sub is_required { $_[0]->{required} }

sub my_default {
    if (my $code = $_[0]->{_def_code}) {
        return $code->();
    }
    return $_[0]->{default};
}

sub my_options   {
    my $options = $_[0]->{options};
    ref $options eq 'CODE' ? $options->() : $options;
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

Copyright (c) 2002-2003, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut


1;
__END__
