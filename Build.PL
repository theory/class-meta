use Module::Build;

my $build = Module::Build->new(
    module_name        => 'Class::Meta',
    license            => 'perl',
    requires            => { Data::Types => '0.05',
                             DateTime    => '0.18',
                           },
    build_requires     => { Test::Simple => '0.17',
                            IO::Handle   => 0,
                            IO::Socket   => 0,
                            Socket       => 0,
                          },
    create_makefile_pl => 'passthrough',
);
$build->create_build_script;
