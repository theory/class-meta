package Class::Meta::AccessorBuilder::Affordance;

# $Id: Affordance.pm,v 1.5 2004/01/09 00:46:59 david Exp $

use strict;

use Class::Meta;

sub build_attr_get {
    UNIVERSAL::can($_[0]->package, 'get_' . $_[0]->name);
}

sub build_attr_set {
    UNIVERSAL::can($_[0]->package, 'set_' . $_[0]->name);
}

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
    if ($create >= Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::get_$name"} = sub { $_[0]->{$name} };

    }

    if ($create >= Class::Meta::SET) {
        # Create SET accessor.
        if (@checks) {
            *{"${pkg}::set_$name"} = sub {
                # Check the value passed in.
                $_->($_[1]) for @checks;
                # Assign the value.
                $_[0]->{$name} = $_[1];
            };
         } else {
            *{"${pkg}::set_$name"} = sub {
                # Assign the value.
                $_[0]->{$name} = $_[1];
            };
        }
    }
}

1;
__END__
