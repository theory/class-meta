#!/usr/bin/perl -w

# $Id: Makefile.PL,v 1.6 2002/06/04 20:50:57 david Exp $

use strict;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile( NAME            => 'Class::Meta',
               VERSION_FROM    => 'lib/Class/Meta.pm', # finds $VERSION
               PREREQ_PM       => { Data::Types => 0.02,
                                    Time::Piece => 1.01,
                                    Time::Piece::ISO => 0.03,
                                    Class::ISA => 0.31,
                                  },
               LIBS            => [''], # e.g., '-lm'
               DEFINE          => '', # e.g., '-DHAVE_SOMETHING'
               # Insert -I. if you add *.h files later:
               INC             => '', # e.g., '-I/usr/include/other'
               ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
                ( ABSTRACT_FROM => 'lib/Class/Meta.pm', # retrieve abstract from module
                  AUTHOR        => 'David Wheeler <david@wheeler.net') : ()),
               # Un-comment this if you add C files to link with later:
               #OBJECT          => '$(O_FILES)', # link all the C files too
);
