package Class::Meta::AccessorBuilder::SemiAffordance;

=head1 NAME

Class::Meta::AccessorBuilder::SemiAffordance - Semi-Affordance style accessor generation

=head1 SYNOPSIS

  package MyApp::TypeDef;

  use strict;
  use Class::Meta::Type;
  use IO::Socket;

  my $type = Class::Meta::Type->add(
      key     => 'io_socket',
      builder => 'semi-affordance',
      desc    => 'IO::Socket object',
      name    => 'IO::Socket Object'
  );

=head1 DESCRIPTION

This module provides a semi-affordance style accessor builder for Class::Meta.
Affordance accessors are attribute accessor methods that separate the getting
and setting of an attribute value into distinct methods. The approach both
eliminates the overhead of checking to see whether an accessor is called as a
getter or a setter, which is common for Perl style accessors, while also
creating a psychological barrier to accidentally misusing an attribute.


=head2 Accessors

Class::Meta::AccessorBuilder::SemiAffordance create two different types of
accessors: getters and setters. What makes the accessors generated by this
class "semi-affordance" rather than "affordance" accessors is that the getter
is simply named for the attribute, while the setter is prepended by C<set_>.
This approach differs from that of affordance accessors, where the getter is
prepended by C<get_>.

The type of accessors created depends on the value of the C<authz> attribute
of the Class::Meta::Attribute for which the accessor is being created.

For example, if the C<authz> is Class::Meta::RDWR, then two accessor methods
will be created:

  my $value = $obj->io_socket;
  $obj->set_io_socket($value);

If the value of C<authz> is Class::Meta::READ, then only the get method
will be created:

  my $value = $obj->io_socket;

And finally, if the value of C<authz> is Class::Meta::WRITE, then only the set
method will be created (why anyone would want this is beyond me, but I provide
for the sake of completeness):

  my $value = $obj->io_socket;

=head2 Data Type Validation

Class::Meta::AccessorBuilder::SemiAffordance uses all of the validation checks
passed to it to validate new values before assigning them to an attribute. It
also checks to see if the attribute is required, and if so, adds a check to
ensure that its value is never undefined. It does not currently check to
ensure that private and protected methods are used only in their appropriate
contexts, but may do so in a future release.

=head2 Class Attributes

If the C<context> attribute of the attribute object for which accessors are to
be built is C<Class::Meta::CLASS>, Class::Meta::AccessorBuilder will build
accessors for a class attribute instead of an object attribute. Of course,
this means that if you change the value of the class attribute in any
context--whether via a an object, the class name, or an an inherited class
name or object, the value will be changed everywhere.

For example, for a class attribute "count", you can expect the following to
work:

  MyApp::Custom->set_count(10);
  my $count = MyApp::Custom->count; # Returns 10.
  my $obj = MyApp::Custom->new;
  $count = $obj->count;             # Returns 10.

  $obj->set_count(22);
  $count = $obj->count;             # Returns 22.
  my $count = MyApp::Custom->count; # Returns 22.

  MyApp::Custom->set_count(35);
  $count = $obj->count;             # Returns 35.
  my $count = MyApp::Custom->count; # Returns 35.

Currently, class attribute accessors are not designed to be inheritable in the
way designed by Class::Data::Inheritable, although this might be changed in a
future release. For now, I expect that the current simple approach will cover
the vast majority of circumstances.

B<Note:> Class attribute accessors will not work accurately in multiprocess
environments such as mod_perl. If you change a class attribute's value in one
process, it will not be changed in any of the others. Furthermore, class
attributes are not currently shared across threads. So if you're using
Class::Meta class attributes in a multi-threaded environment (such as iThreads
in Perl 5.8.0 and later) the changes to a class attribute in one thread will
not be reflected in other threads.

=head1 Private and Protected Attributes

Any attributes that have their C<view> attribute set to Class::Meta::Private
or Class::Meta::Protected get additional validation installed to ensure that
they're truly private and protected. This includes when they are set via
parameters to constructors generated by Class::Meta. The validation is
performed by checking the caller of the accessors, and throwing an exception
when the caller isn't the class that owns the attribute (for private
attributes) or when it doesn't inherit from the class that owns the attribute
(for protected attributes).

As an implementation note, this validation is performed for parameters passed
to constructors created by Class::Meta by ignoring looking for the first
caller that isn't Class::Meta::Constructor:

  my $caller = caller;
  # Circumvent generated constructors.
  for (my $i = 1; $caller eq 'Class::Meta::Constructor'; $i++) {
      $caller = caller($i);
  }

This works because Class::Meta::Constructor installs the closures that become
constructors, and thus, when those closures call accessors to set new values
for attributes, the caller is Class::Meta::Constructor. By going up the stack
until we find another package, we correctly check to see what context is
setting attribute values via a constructor, rather than the constructor method
itself being the context.

This is a bit of a hack, but since Perl uses call stacks for checking security
in this way, it's the best I could come up with. Other suggestions welcome. Or
see L<Class::Meta::Type|Class::Meta::Type/"Custom Accessor Building"> to
create your own accessor generation code

=head1 INTERFACE

The following functions must be implemented by any Class::Meta accessor
generation module.

=head2 Functions

=head3 build_attr_get

  my $code = Class::Meta::AccessorBuilder::SemiAffordance::build_attr_get();

This function is called by C<Class::Meta::Type::make_attr_get()> and returns a
code reference that can be used by the C<get()> method of
Class::Meta::Attribute to return the value stored for that attribute for the
object passed to the code reference.

=head3 build_attr_set

  my $code = Class::Meta::AccessorBuilder::SemiAffordance::build_attr_set();

This function is called by C<Class::Meta::Type::make_attr_set()> and returns a
code reference that can be used by the C<set()> method of
Class::Meta::Attribute to set the value stored for that attribute for the
object passed to the code reference.

=head3 build

  Class::Meta::AccessorBuilder::SemiAffordance::build(
    $pkg, $attribute, $create, @checks
  );

This method is called by the C<build()> method of Class::Meta::Type, and does
the work of actually generating the accessors for an attribute object. The
arguments passed to it are:

=over 4

=item $pkg

The name of the class to which the accessors will be added.

=item $attribute

The Class::Meta::Attribute object that specifies the attribute for which the
accessors will be created.

=item $create

The value of the C<create> attribute of the Class::Meta::Attribute object,
which determines what accessors, if any, are to be created.

=item @checks

A list of code references that validate the value of an attribute. These will
be used in the set accessor (mutator) to validate new attribute values.

=back

=cut

use strict;
use Class::Meta;
use base 'Class::Meta::AccessorBuilder::Affordance';
our $VERSION = '0.67';

sub build_attr_get {
    UNIVERSAL::can($_[0]->package, $_[0]->name);
}

sub build {
    my ($pkg, $attr, $name, $get, $set) = __PACKAGE__->_build(@_);
    # Install the accessors.
    no strict 'refs';
    *{"${pkg}::$name"} = $get if $get;
    *{"${pkg}::set_$name"} = $set if $set;
}

1;
__END__

=head1 SUPPORT

This module is stored in an open L<GitHub
repository|http://github.com/theory/class-meta/>. Feel free to fork and
contribute!

Please file bug reports via L<GitHub
Issues|http://github.com/theory/class-meta/issues/> or by sending mail to
L<bug-Class-Meta@rt.cpan.org|mailto:bug-Class-Meta@rt.cpan.org>.

=head1 AUTHOR

David E. Wheeler <david@justatheory.com>

=head1 SEE ALSO

=over 4

=item L<Class::Meta|Class::Meta>

This class contains most of the documentation you need to get started with
Class::Meta.

=item L<Class::Meta::AccessorBuilder|Class::Meta::AccessorBuilder>

This module generates Perl style accessors.

=item L<Class::Meta::Type|Class::Meta::Type>

This class manages the creation of data types.

=item L<Class::Meta::Attribute|Class::Meta::Attribute>

This class manages Class::Meta class attributes, most of which will have
generated accessors.

=back

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2002-2011, David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
