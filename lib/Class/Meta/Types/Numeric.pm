package Class::Meta::Types::Numeric;

use strict;
use Class::Meta::Type;
use Data::Types ();

my $croak = sub {
    require Carp;
    our @CARP_NOT = qw(Class::Meta::Attribute);
    Carp::croak(@_);
};

# This code ref builds value checkers.
my $mk_chk = sub {
    my ($code, $type) = @_;
    return [
        sub {
            return unless defined $_[0];
            $code->($_[0])
              or $croak->("Value '$_[0]' is not a valid $type");
            }
    ];
};

##############################################################################
sub import {
    my ($pkg, $builder) = @_;
    $builder ||= 'default';
    return if eval "Class::Meta::Type->new('whole')";

    Class::Meta::Type->add(
        key     => "whole",
        name    => "Whole Number",
        desc    => "Whole number",
        builder => $builder,
        check   => $mk_chk->(\&Data::Types::is_whole, 'whole number'),
    );

    Class::Meta::Type->add(
        key     => "integer",
        name    => "Integer",
        desc    => "Integer",
        builder => $builder,
        check   => $mk_chk->(\&Data::Types::is_int, 'integer'),
    );

    Class::Meta::Type->add(
        key     => "decimal",
        name    => "Decimal Number",
        desc    => "Decimal number",
        builder => $builder,
        check   => $mk_chk->(\&Data::Types::is_decimal, 'decimal number'),
    );

    Class::Meta::Type->add(
        key     => "real",
        name    => "Real Number",
        desc    => "Real number",
        builder => $builder,
        check   => $mk_chk->(\&Data::Types::is_real, 'real number'),
    );

    Class::Meta::Type->add(
        key     => "float",
        name    => "Floating Point Number",
        desc    => "Floating point number",
        builder => $builder,
        check   => $mk_chk->(\&Data::Types::is_float, 'floating point number'),
    );
}

1;
__END__
