use Module::Build;
my $build = Module::Build->new(
    module_name => 'Test::HTTP::WAF',
    license     => 'bsd',
    requires    => {
        'perl'           => 0,
        'Test::Base'     => 0,
        'LWP::UserAgent' => 0,
        'Carp'           => 0,
    },
    create_makefile_pl => 'traditional',
    dist_author        => 'Tomoyuki Sakurai <cherry@trombik.org>',
);
$build->create_build_script;
