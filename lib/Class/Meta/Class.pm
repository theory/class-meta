package Class::Meta::Class;

# $Id: Class.pm,v 1.8 2003/11/19 03:57:46 david Exp $

use strict;
use Carp ();
use Class::Meta;
use Class::Meta::Attribute;
use Class::Meta::Method;

{
    # We'll keep the class specifications in here.
    my %specs;

    ##########################################################################
    sub new {
        my ($pkg, $spec) = @_;
        # Check to make sure that only Class::Meta or a subclass is
        # constructing a Class::Meta::Class object.
        my $caller = caller;
        Carp::croak("Package '$caller' cannot create ", __PACKAGE__,
                    " objects")
          unless grep { $_ eq 'Class::Meta' }
          $caller, eval '@' . $caller . "::ISA";

        # Check to make sure we haven't created this class already.
        Carp::croak("Class object for class '$spec->{class}' already exists")
          if $specs{$spec->{class}};

        # Save a reference to the spec hash ref.
        $specs{$spec->{class}} = $spec;

        # Okay, create the object.
        return bless { package => $spec->{class} }, ref $pkg || $pkg;
    }

    ##########################################################################
    # Basic accessors.
    sub my_package { $_[0]->{package}                 }
    sub my_key     { $specs{$_[0]->{package}}->{key}  }
    sub my_name    { $specs{$_[0]->{package}}->{name} }
    sub my_desc    { $specs{$_[0]->{package}}->{desc} }

    ##########################################################################
    # Check inheritance.
    sub isa { exists $specs{$_[0]->{package}}->{isa}{$_[1]} }

    ##########################################################################
    # Create accessors to get at the constructor, attribute, and method
    # objects.
    for my $t (qw(ctor attr meth)) {
        eval qq|
            sub my_${t}s {
                my \$self = shift;
                my \$objs = \$specs{\$_[0]->{package}}->{${t}s};
                my \$list = \@_
                  # Explicit list requested.
                  ? \\\@_
                  : \$specs{\$_[0]->{package}}->{isa}{scalar caller}
                  # List of protected interface objects.
                  ? \$specs{\$_[0]->{package}}->{prot_$t\_ord}
                  # List of public interface objects.
                  : \$specs{\$_[0]->{package}}->{$t\_ord};
                return \@\$list == 1
                  ? \$objs->{\$list->[0]}
                  : \@{\$objs}{\@\$list};
            }
        |;
    }
}

1;
__END__
