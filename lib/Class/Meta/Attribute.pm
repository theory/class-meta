package Class::Meta::Property;

# $Id: Attribute.pm,v 1.3 2002/05/10 22:49:10 david Exp $

=head1 NAME

Kinet::Meta::Prop - Objects describing Kinet object properties.

=head1 SYNOPSIS

  use Kinet::Meta::Prop;
  my $prop = Kinet::Meta::Prop->new($spec);

=head1 DESCRIPTION



=cut

##############################################################################
# Dependencies                                                               #
##############################################################################
use strict;
use Carp ();
use Class::Meta;

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

sub new {}

##############################################################################
# Instance Methods                                                           #
##############################################################################

sub my_name   { $_[0]->{name} }
sub my_vis    { $_[0]->{vis} }
sub my_auth   { $_[0]->{auth} }
sub my_type   { $_[0]->{type} }
sub my_length { $_[0]->{length} }
sub my_label  { $_[0]->{label} }
sub my_field  { $_[0]->{field} }
sub my_desc   { $_[0]->{desc} }
sub is_req    { $_[0]->{req} }
sub my_def    { $_[0]->{def} }
sub my_vals   { ref $_[0]->{vals} eq 'CODE' ? $_[0]->{vals}->() : $_[0]->{vals} }
sub get_val   { shift->{_get}->(@_) }
sub set_val   { shift->{_set}->(@_) }

1;
__END__

=head1 AUTHOR

David Wheeler <david@kineticode.com>

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
