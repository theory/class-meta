#!/usr/bin/perl -w

# $Id: custom_types.t,v 1.7 2004/01/08 00:19:48 david Exp $

##############################################################################
# Set up the tests.
##############################################################################

use strict;
use Test::More tests => 7;

##############################################################################
# Create a simple class.
##############################################################################

package Class::Meta::TestIP;
use strict;
use Carp;

BEGIN {
    main::use_ok( 'Class::Meta');
    main::use_ok( 'Class::Meta::Type');
}

BEGIN {
    # Set up functions to verify and convert values.
    my $ip_chk = sub {
        croak "Value '$_' is not an IP address" unless  inet_ntoa($_);
    };

    my $ip_conv = sub { inet_aton(shift) };

    # Add the new data type.
    Class::Meta::Type->add( key  => 'ip_addr',
                            name => 'IP Address',
                            desc => 'IP Address data type.',
                            chk  => $ip_chk,
                            conv => $ip_conv
                        );

    # Build the class with the new data type as a attribute.
    my $c = Class::Meta->new(ip_test => __PACKAGE__);
    $c->add_ctor( name => 'new' );
    $c->add_attr( name  => 'name',
                  view   => Class::Meta::PUBLIC,
                  type  => 'string',
                  length   => 256,
                  label => 'Name',
                  field => 'text',
                  desc  => "The person's name.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->add_attr( name  => 'ip_address',
                  view   => Class::Meta::PUBLIC,
                  type  => 'ip_addr',
                  label => 'Age',
                  field => 'text',
                  desc  => "The person's age.",
                  required   => 0,
                  default   => undef,
                  create   => Class::Meta::GETSET
              );
    $c->build;
}

package main;

# Instantiate an object and test its accessors.
ok( my $t = Class::Meta::TestIP->new, 'Class::Meta::TestIP->new');

# Test string.
ok( $t->set_name('Theory'), 'set_name to "Theory"' );
is( $t->get_name, 'Theory', 'get_name is "Theory"' );

# Test the custom data type.
my $ip = "123.12.142.23";
my $pip = inet_aton($ip);
ok( $t->set_ip_address($pip), "Set IP address" );
is( $t->get_ip_address, $pip, "Properly returned IP Address.");
