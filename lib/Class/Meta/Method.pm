package Class::Meta::Method;

# $Id: Method.pm,v 1.3 2002/05/11 22:18:17 david Exp $

=head1 NAME

Class::Meta::Method - Method introspection objects

=head1 SYNOPSIS

  $c->add_meth( name  => 'chk_pass',
                vis   => Class::Meta::PUBLIC );

=head1 DESCRIPTION



=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;
use Carp ();

##############################################################################
# Package Globals                                                            #
##############################################################################
use vars qw($VERSION);
$VERSION = "0.01";

##############################################################################
# Constructors                                                               #
##############################################################################

=head1 CONSTRUCTORS

=head2 new

  my $type = Class::Meta::Method->new($cm, @params);

=cut

sub new {
    my $pkg = shift;
    my $def = shift;
    my $class = shift;

    # Check to make sure that only Class::Meta or a subclass is
    # constructing a Class::Meta::Class object.
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
    Carp::croak("Method '$p->{name}' is not a valid method name "
		. "-- only alphanumeric and '_' characters allowed")
	  if $params{name} =~ /\W/;

    # Make sure the name hasn't already been used for another method
    # or constructor.
    Carp::croak("Method '$params{name}' already exists in class "
		. "'$def->{class}'")
      if exists $def->{meths}{$params{name}}
      || exists $def->{ctors}{$params{name}};

    # Set defaults.
    $param{vis} ||= Class::Meta::PUBLIC;

    # Validate or create the caller if necessary.
    if ($param{caller}) {
	my $ref = ref $param{caller};
	Carp::croak("Parameter caller must be a code reference")
	  unless $ref && $ref eq 'CODE'
      } else {
	  $param{caller} = eval "sub { shift->$param{name}(\@_) }";
      }

    # Grab a reference to the class to which it belongs.

    # Return the object!
    return bless \%params, ref $pkg || $pkg;
}

##############################################################################
# Instance Methods                                                           #
##############################################################################

=head1 INSTANCE METHODS

=head2 my_name

  my $name = $meth->my_name;

Returns the method name.

=cut

sub my_name { $_[0]->{name} }

=head2 my_vis

  my $vis = $meth->vis;

Returns the visibility level of this method. Possible values are defined by
the constants C<PRIVATE>, C<PROTECTED>, and C<PUBLIC>, as defined in
C<Class::Meta>.

=cut

sub my_vis { $_[0]->{vis} }

=head2 call

  my $ret = $meth->call($obj);

Executes the method on the $obj object.

=cut

sub call { &{ shift->{caller}(@_) }
#    my $self = shift;
#    my $meth = $self->{caller};
#    $meth->(@_);
#}


1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Attribute|Class::Meta::Attribute>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
