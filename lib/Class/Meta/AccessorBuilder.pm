package Class::Meta::AccessorBuilder;

use strict;
use Class::Meta;

sub build_attr_get { eval "sub { shift->$_[0] }" }

sub build_attr_set { eval "sub { shift->$_[0](\@_) }" }

sub build {
    my ($pkg, $attr, $create, @checks) = @_;

    no strict 'refs';
    if ($create == Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::$attr"} = sub { $_[0]->{$attr} };

    } elsif ($create == Class::Meta::SET) {
        # Create SET accessor.
        if (@checks) {
            *{"${pkg}::$attr"} = sub {
                # Check the value passed in.
                $_->($_[1]) for @checks;
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            };
        } else {
            *{"${pkg}::$attr"} = sub {
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            };
        }

    } elsif ($create == Class::Meta::GETSET) {
        # Create GETSET accessor(s).
        if (@checks) {
            *{"${pkg}::$attr"} = sub {
                my $self = shift;
                return $self->{$attr} unless @_;
                # Check the value passed in.
                $_->($_[0]) for @checks;
                # Assign the value.
                return $self->{$attr} = $_[0];
            };
        } else {
            *{"${pkg}::$attr"} = sub {
                my $self = shift;
                return $self->{$attr} unless @_;
                # Assign the value.
                return $self->{$attr} = shift;
            };
        }
    } else {
        # Well, nothing I guess.
    }
}

1;
__END__
