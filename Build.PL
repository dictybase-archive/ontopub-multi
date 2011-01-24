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
        'Mojolicious'            => '0.999938',
        'Plack'                       => '0.9941',
        'FCGI::Engine'                => '0.16',
        'Mojolicious::Plugin::Bundle' => '0.001',
        'List::MoreUtils'             => '0.30'
    },
    add_to_cleanup => ['OntoPub-*'],
    create_readme  => 1,
);

$builder->create_build_script();

