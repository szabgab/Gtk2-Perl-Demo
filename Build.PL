use strict;
use warnings;
use Module::Build;

if (-e 'create_glade') {
    system "$^X -I lib create_glade";
}

my $build = Module::Build->new(
    module_name        => 'App::Gtk2Demo',
    dist_version_from  => 'lib/App/Gtk2Demo.pm',
    license            => 'perl',
    create_makefile_pl => 'traditional',
    script_files       => 'bin/gtk2demo.pl',
    requires           => {
            'Gtk2'                   => '1.080',
#            'Gtk2::GladeXML'         => '0',

            'Carp'                   => '0',
            'Cwd'                    => '0',
            'File::Spec'             => '0',
    },
    build_requires     => {
            'Test::More'             => '0',
    },
);

$build->create_build_script;

