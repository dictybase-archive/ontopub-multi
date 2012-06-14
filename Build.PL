#!/usr/bin/perl -w
use strict;
use warnings;
use Module::Build;


my $builder = Module::Build->new(
    module_name  => 'OntoPub',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '0.001',
    requires     => {
        'Mojolicious'                 => '1.21',
        'Plack'                       => '0.9941',
        'FCGI::Engine'                => '0.16',
        'Mojolicious::Plugin::Bundle' => '0.005',
        'List::MoreUtils'             => '0.30',
        'DBIx::Class'                 => '0.08127',
        'Math::BigInt'                => '1.99',
        'Math::Base36'                => '0.09',
        'DBI'                         => '1.51',
        'DBD::Oracle'                 => '1.27'
    },
    add_to_cleanup => ['OntoPub-*'],
    create_readme  => 1,
);

$builder->create_build_script();

