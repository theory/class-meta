package Class::Meta::Types::Boolean;

# $Id: Boolean.pm,v 1.5 2004/01/09 00:47:00 david Exp $

use strict;
use Class::Meta::Type;

sub import {
    my ($pkg, $builder) = @_;
    $builder ||= 'default';
    return if eval "Class::Meta::Type->new('boolean')";

    if ($builder eq 'default') {
        eval q|
sub build_attr_get {
    UNIVERSAL::can($_[0]->package, $_[0]->name);
}

*build_attr_set = \&build_attr_get;

sub build {
    my ($pkg, $attr, $create) = @_;
    $attr = $attr->name;

    no strict 'refs';
    if ($create == Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::$attr"} = sub { $_[0]->{$attr} };

    } elsif ($create == Class::Meta::SET) {
        # Create SET accessor.
        *{"${pkg}::$attr"} = sub { $_[0]->{$attr} = $_[1] ? 1 : 0 };

    } elsif ($create == Class::Meta::GETSET) {
        # Create GETSET accessor.
        *{"${pkg}::$attr"} = sub {
            my $self = shift;
            return $self->{$attr} unless @_;
            $self->{$attr} = $_[0] ? 1 : 0
        };
    } else {
        # Well, nothing I guess.
    }
}|
    } else {
        eval q|
sub build_attr_get {
    UNIVERSAL::can($_[0]->package, 'is_' . $_[0]->name);
}

sub build_attr_set {
    my $name = shift->name;
    eval "sub { \$_[1] ? \$_[0]->set_$name\_on : \$_[0]->set_$name\_off }";
}

sub build {
    my ($pkg, $attr, $create) = @_;
    $attr = $attr->name;

    no strict 'refs';
    if ($create >= Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::is_$attr"} = sub { $_[0]->{$attr} };
    }
    if ($create >= Class::Meta::SET) {
        # Create SET accessors.
        *{"${pkg}::set_$attr\_on"} = sub { $_[0]->{$attr} = 1 };
        *{"${pkg}::set_$attr\_off"} = sub { $_[0]->{$attr} = 0 };
    }
}|;
    }

    Class::Meta::Type->add(
        key     => "boolean",
        name    => "Boolean",
        desc    => "Boolean",
        alias   => 'bool',
        builder => __PACKAGE__
    );
}

1;
__END__
