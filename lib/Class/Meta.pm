package Class::Meta;

=head1 NAME

Class::Meta - Class Automation and Introspection

=head1 SYNOPSIS

  use Class::Meta;


=head1 DESCRIPTION



=cut

use strict;
use Carp;
use Class::Meta::Class;
use Class::Meta::Property;
use Class::Meta::Method;

our $VERSION = '0.01';

##############################################################################
# Constants                                                                  #
##############################################################################
# Visibility.
use constant PRIVATE   => 0x00;
use constant PROTECTED => 0x01;
use constant PUBLIC    => 0x02;

# Authorization
use constant NONE      => 0x00;
use constant READ      => 0x01;
use constant WRITE     => 0x02;
use constant RDWR      => READ | WRITE;

# Method generation.
use constant GET       => 0x01;
use constant SET       => 0x02;
use constant GETSET    => GET | SET;

{
    my %classes;

    sub new {
	my ($pkg, $key, $class) = @_;
	$class ||= caller;
	$key ||= $class;
	croak "Class '$class' already created" if exists $classes{$class};
	$classes{$class} = { key => $key,
			     class => $class,
			     obj => Class::Meta::Class->new,
			   };
	return bless \$class, ref $pkg || $pkg;
    }

    sub add_prop {
	my ($self, $spec) = @_;
    }

    sub add_meth {
	my ($self, $spec) = @_;
    }
}

1;
__END__

=head1 AUTHOR

David Wheeler <david@wheeler.net>

=head1 SEE ALSO

L<Class::Contract|Class::Contract>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002, David Wheeler. All Rights Reserved.

This module is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

=cut
