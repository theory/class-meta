package Class::Meta::Types::Perl;

# $Id: Perl.pm,v 1.3 2004/01/08 05:14:42 david Exp $

use strict;
use Class::Meta::Type;

sub import {
    my ($pkg, $builder) = @_;
    $builder ||= 'default';
    return if eval "Class::Meta::Type->new('array')";

    Class::Meta::Type->add(
        key     => "scalar",
        name    => "Scalar",
        desc    => "Scalar",
        builder => $builder,
    );

    Class::Meta::Type->add(
        key     => "scalarref",
        name    => "Scalar Reference",
        desc    => "Scalar reference",
        builder => $builder,
        check   => 'SCALAR',
    );

    Class::Meta::Type->add(
        key     => "array",
        name    => "Array Reference",
        desc    => "Array reference",
        alias   => 'arrayref',
        builder => $builder,
        check   => 'ARRAY',
    );

    Class::Meta::Type->add(
        key     => "hash",
        name    => "Hash Reference",
        desc    => "Hash reference",
        alias   => 'hashref',
        builder => $builder,
        check   => 'HASH',
    );

    Class::Meta::Type->add(
        key     => "code",
        name    => "Code Reference",
        desc    => "Code reference",
        alias   => [qw(coderef closure)],
        builder => $builder,
        check   => 'CODE',
    );
}

1;
__END__
