package Class::Meta::AccessorBuilder::Affordance;

use strict;

use Class::Meta;

sub build_attr_get { eval "sub { shift->get_$_[0] }" }
sub build_attr_set { eval "sub { shift->set_$_[0](\@_) }" }

sub build {
    my ($pkg, $attr, $create, @checks) = @_;

    no strict 'refs';
    if ($create >= Class::Meta::GET) {
        # Create GET accessor.
        *{"${pkg}::get_$attr"} = sub { $_[0]->{$attr} };

    }

    if ($create >= Class::Meta::SET) {
        # Create SET accessor.
        if (@checks) {
            *{"${pkg}::set_$attr"} = sub {
                # Check the value passed in.
                $_->($_[1]) for @checks;
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            };
         } else {
            *{"${pkg}::set_$attr"} = sub {
                # Assign the value.
                $_[0]->{$attr} = $_[1];
            };
        }
    }
}

1;
__END__
