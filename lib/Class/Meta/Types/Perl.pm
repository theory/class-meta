package Class::Meta::Types::Perl;

use strict;
use Class::Meta::Type;

sub import {
    my ($pkg, $builder) = @_;
    $builder ||= 'default';
    return if eval "Class::Meta::Type->new('array')";

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
        builder => $builder,
        check   => 'ARRAY',
    );

    Class::Meta::Type->add(
        key     => "hash",
        name    => "Hash Reference",
        desc    => "Hash reference",
        builder => $builder,
        check   => 'HASH',
    );

    Class::Meta::Type->add(
        key     => "code",
        name    => "Code Reference",
        desc    => "Code reference",
        builder => $builder,
        check   => 'CODE',
    );
}

1;
__END__
