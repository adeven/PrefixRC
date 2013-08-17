#!$EPREFIX/bin/perl

use strict;
use warnings;

use 5.010;
use lib 'lib';

use Module::Build;
use Getopt::Long;

my $install = 0;
my $dist    = 0;
my $meta    = 0;
my @bin     = grep { -f and !-d } glob 'bin/*';

GetOptions(
    'install' => \$install,
    'dist'    => \$dist,
    'meta'    => \$meta,
);

my $build = Module::Build->new(
    module_name       => 'PrefixRC',
    dist_abstract     => 'A simple init replacement for Gentoo Prefix',
    dist_author       => 'Adeven GmbH <robert@adeven.com>',
    dist_version_from => 'lib/PrefixRC.pm',
    license           => 'mit',

    configure_requires => { 'Module::Build' => 0.38, },

    requires => {
        'Moo'          => 0,
        'Getopt::Long' => 0,
        'POSIX'        => 0,
    },

    build_requires => { 'Module::Build' => 0.38 },

    script_files => [@bin],

    add_to_cleanup => ['PrefixRC-* Build _build MYMETA.*'],

    meta_add => {
        release_status => 'beta',
    },

    meta_merge => {
        provides => {
            'PrefixRC' => {
                file => 'lib/PrefixRC.pm',
            },
            'PrefixRC::Start' => {
                file => 'lib/PrefixRC/Start.pm',
            },
            'PrefixRC::Stop' => {
                file => 'lib/PrefixRC/Stop.pm',
            },
            'PrefixRC::Status' => {
                file => 'lib/PrefixRC/Status.pm',
            },
        }
    },
);

if ($meta) {
    $build->dispatch('distmeta');
    exit 0;
}

if ($dist) {
    $build->dispatch('build');
    $build->dispatch('test');
    $build->dispatch('distmeta');
    $build->dispatch('dist');
    $build->create_build_script();
    exit 0;
}

if ($install) {
    $build->dispatch('build');
    $build->dispatch('test');
    $build->dispatch('install');
    $build->create_build_script();
    exit 0;
}

$build->create_build_script();
