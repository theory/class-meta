package Class::Meta::AccessorBuilder;

# $Id: AccessorBuilder.pm,v 1.4 2004/01/09 00:46:59 david Exp $

use strict;
use Class::Meta;

sub build_attr_get {
    UNIVERSAL::can($_[0]->package, $_[0]->name);
}

*build_attr_set = \&build_attr_get;

my $croak = sub {
    require Carp;
#    our @CARP_NOT = qw(Class::Meta);
    Carp::croak(@_);
};

my $req_chk = sub {
    $croak->("Attribute must be defined") unless defined $_[0];
};

sub build {
    my ($pkg, $attr, $create, @checks) = @_;
    unshift @checks, $req_chk if $attr->required;
    my $name = $attr->name;

    # XXX Do I need to add code to check the caller and throw an exception for
    # private and protected methods?

    no strict 'refs';
    if ($create == Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::$name"} = sub { $_[0]->{$name} };

    } elsif ($create == Class::Meta::SET) {
        # Create SET accessor.
        if (@checks) {
            *{"${pkg}::$name"} = sub {
                # Check the value passed in.
                $_->($_[1]) for @checks;
                # Assign the value.
                $_[0]->{$name} = $_[1];
            };
        } else {
            *{"${pkg}::$name"} = sub {
                # Assign the value.
                $_[0]->{$name} = $_[1];
            };
        }

    } elsif ($create == Class::Meta::GETSET) {
        # Create GETSET accessor(s).
        if (@checks) {
            *{"${pkg}::$name"} = sub {
                my $self = shift;
                return $self->{$name} unless @_;
                # Check the value passed in.
                $_->($_[0]) for @checks;
                # Assign the value.
                return $self->{$name} = $_[0];
            };
        } else {
            *{"${pkg}::$name"} = sub {
                my $self = shift;
                return $self->{$name} unless @_;
                # Assign the value.
                return $self->{$name} = shift;
            };
        }
    } else {
        # Well, nothing I guess.
    }
}

1;
__END__
