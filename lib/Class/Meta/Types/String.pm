package Class::Meta::Types::String;

# $Id: String.pm,v 1.2 2004/01/08 05:14:42 david Exp $

use strict;
use Class::Meta::Type;

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
            require Carp;
            our @CARP_NOT = qw(Class::Meta::Attribute);
            Carp::croak("Value '$_[0]' is not a valid string");
        }
    );
}

1;
__END__
