package Class::Meta::Method;

# $Id: Method.pm,v 1.12 2003/12/10 07:34:12 david Exp $

=head1 NAME

Class::Meta::Method - Method introspection objects

=head1 SYNOPSIS

  my $meth = $c->my_meths('chk_passwd');
  print "Method Name: ", $meth->my_name, "()\n";
  print "Description: ", $meth->my_desc, "\n";
  print "Label:       ", $meth->my_label, "\n";
  print "Context:     ", $meth->my_context == Class::Meta::CLASS ?
    "Class\n" : "Object\n";
  print "Viewibility:  ", $meth->my_view == Class::Meta::PUBLIC
    ? "Public\n"  :      $meth->my_view == Class::Meta::PRIVATE
    ? "Private\n" : "Protected\n";

=head1 DESCRIPTION

This class provides an interface to the C<Class::Meta> objects that describe
class methods. It supports a simple description of the method, a label, the
method context (class or object), and the method visibility (private,
protected, or public). Construction is performed internally by
C<Class::Meta>, and objects of this class may be retreived by calling the
C<my_meths()> method on a C<Class::Meta::Class> object.

=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;

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

  my $meth = Class::Meta::Method->new($def, @params);
xc
Creates a new C<Class::Meta::Method> object. This is a protected method,
callable only from C<Class::Meta> or its subclasses. Use the C<Class::Meta>
C<add_meth()> object method to add a new method to a class. Supported keys
are:

=over 4

=item name

The method name as it is defined in the class.

=item desc

A description of the method.

=item label

A label for the method.

=item context

The context of the method. Can be one of the two C<Class::Meta> constants
C<OBJECT> or C<CLASS>.

=item view

The visibility, or view, of the method. Can be one of the three C<Class::Meta>
constants C<PUBLIC>, C<PROTECTED>, or C<PRIVATE>.

=item caller

A code reference that executes a the method on an object or class where the
object or class is the first argument to the code reference.

=back

=cut

sub new {
    my $pkg = shift;
    my $spec = shift;

    # Check to make sure that only Class::Meta or a subclass is constructing a
    # Class::Meta::Method object.
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

    # Make sure the name hasn't already been used for another method
    # or constructor.
    $croak->("Method '$p{name}' already exists in class "
             . "'$spec->{package}'")
      if exists $spec->{meths}{$p{name}}
      || exists $spec->{ctors}{$p{name}};

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

    # Check the context.
    if (exists $p{context}) {
        $croak->("Not a valid context parameter: '$p{context}'")
          unless $p{context} == Class::Meta::OBJECT
          ||     $p{context} == Class::Meta::CLASS;
    } else {
        # Make it public by default.
        $p{context} = Class::Meta::OBJECT;
    }

    # Validate or create the method caller if necessary.
    if ($p{caller}) {
        my $ref = ref $p{caller};
        $croak->("Parameter caller must be a code reference")
          unless $ref && $ref eq 'CODE'
      } else {
          $p{caller} = eval "sub { shift->$p{name}(\@_) }";
      }

    # Create and cache the method object.
    $p{package} = $spec->{package};
    $spec->{meths}{$p{name}} = bless \%p, ref $pkg || $pkg;

    # Index its view.
    if ($p{view} > Class::Meta::PRIVATE) {
        push @{$spec->{prot_meth_ord}}, $p{name};
        push @{$spec->{meth_ord}}, $p{name}
          if $p{view} == Class::Meta::PUBLIC;
    }

    # Let 'em have it.
    return $spec->{meths}{$p{name}};
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

=head2 my_package

  my $package = $meth->my_package;

Returns the method package.

=cut

sub my_package { $_[0]->{package} }

=head2 my_desc

  my $desc = $meth->my_desc;

Returns the description of the method.

=cut

sub my_desc { $_[0]->{desc} }

=head2 my_label

  my $desc = $meth->my_label;

Returns label for the method.

=cut

sub my_label { $_[0]->{label} }

=head2 my_view

  my $view = $meth->my_view;

Returns the visibility level of this method. Possible values are defined by
the constants C<PRIVATE>, C<PROTECTED>, and C<PUBLIC>, as defined in
C<Class::Meta>.

=cut

sub my_view { $_[0]->{view} }

=head2 my_context

  my $context = $meth->my_context;

Returns the context of this method. Possible values are defined by the
constants C<CLASS> and C<OBJECT>, as defined in C<Class::Meta>.

=cut

sub my_context { $_[0]->{context} }

=head2 call

  my $ret = $meth->call($obj);

Executes the method on the $obj object.

=cut

sub call {
    my $code = shift->{caller};
    $code->(@_);
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Meta|Class::Meta>, L<Class::Meta::Attribute|Class::Meta::Attribute>,
L<Class::Meta::Constructor|Class::Meta::Constructor>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
