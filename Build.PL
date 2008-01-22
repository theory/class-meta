use Module::Build;

my $build = Module::Build->new(
    module_name        => 'Class::Meta',
    license            => 'perl',
    create_makefile_pl => 'passthrough',
    configure_requires => { 'Module::Build' => '0.2701' },
    build_requires     => { 'Test::More'    => '0.17'   },
    recommends         => { 'Test::Pod'     => '1.20'   },
    requires           => {
        'Data::Types' => '0.05',
        'Class::ISA'  => '0.31',
    },
);
$build->create_build_script;
