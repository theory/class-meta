package Class::Meta::Types::String;

# $Id: String.pm,v 1.22 2004/08/27 01:53:22 david Exp $

=head1 NAME

Class::Meta::Types::String - String data types

=head1 SYNOPSIS

  package MyApp::Thingy;
  use strict;
  use Class::Meta;
  use Class::Meta::Types::String;
  # OR...
  # use Class::Meta::Types::String 'affordance';
  # OR...
  # use Class::Meta::Types::String 'semi-affordance';

  BEGIN {
      # Create a Class::Meta object for this class.
      my $cm = Class::Meta->new( key => 'thingy' );

      # Add a string attribute.
      $cm->add_attribute( name => 'name',
                          type => 'string' );
      $cm->build;
  }

=head1 DESCRIPTION

This module provides a string data type for use with Class::Meta attributes.
Simply load it, then pass "string" to the C<add_attribute()> method of a
Class::Meta object to create an attribute of the string data type. See
L<Class::Meta::Type|Class::Meta::Type> for more information on using and
creating data types.

=cut

use strict;
use Class::Meta::Type;
our $VERSION = "0.40";

sub import {
    my ($pkg, $builder) = @_;
    $builder ||= 'default';
    return if eval "Class::Meta::Type->new('string')";

    Class::Meta::Type->add(
        key     => "string",
        name    => "String",
        desc    => "String",
        builder => $builder,
        check   => sub {
            return unless defined $_[0] && ref $_[0];
            $_[2]->class->handle_error("Value '$_[0]' is not a valid string");
        }
    );
}

1;
__END__

=head1 BUGS

Please report all bugs via the CPAN Request Tracker at
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Class-Meta>.

=head1 AUTHOR

David Wheeler <david@kineticode.com>

=head1 SEE ALSO

Other classes of interest within the Class::Meta distribution include:

=over 4

=item L<Class::Meta|Class::Meta>

This class contains most of the documentation you need to get started with
Class::Meta.

=item L<Class::Meta::Type|Class::Meta::Type>

This class manages the creation of data types.

=item L<Class::Meta::Attribute|Class::Meta::Attribute>

This class manages Class::Meta class attributes, all of which are based on
data types.

=back

Other data type modules:

=over 4

=item L<Class::Meta::Types::Perl|Class::Meta::Types::Perl>

=item L<Class::Meta::Types::Boolean|Class::Meta::Types::Boolean>

=item L<Class::Meta::Types::Numeric|Class::Meta::Types::Numeric>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2004, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
