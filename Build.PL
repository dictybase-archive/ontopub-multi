#!/usr/bin/perl -w
use strict;
use warnings;
use Module::Build;

my $test_code = q{sub ACTION_test {
    use File::Spec::Functions;
	my ($self) = @_;
	my $conf = catfile($self->base_dir, 'conf',  'test.yaml');
	die "***test.yaml*** must exist in conf folder:$!" if !-e $conf;
	my $exist_mode = $ENV{MOJO_MODE} if defined $ENV{MOJO_MODE};
	$ENV{MOJO_MODE} = 'test';
	$self->SUPER::ACTION_test(@_);
	$ENV{MOJO_MODE} = $exist_mode if defined $exist_mode;
}};

my $class = Module::Build->subclass(
    class => 'MyBuilder',
    code  => $test_code
);

my $builder = $class->new(
    module_name  => 'OntoPub',
    license      => 'perl',
    dist_author  => 'Siddhartha Basu <siddhartha-basu@northwestern.edu>',
    dist_version => '0.001',
    requires     => {
        'Mojolicious'                 => '1.21',
        'Plack'                       => '0.9941',
        'FCGI::Engine'                => '0.16',
        'Mojolicious::Plugin::Bundle' => '0.001',
        'List::MoreUtils'             => '0.30',
        'DBIx::Class'                 => '0.08127',
        'Math::BigInt'                => '1.99',
        'Math::Base36'                => '0.09',
        'DBD::Oracle'                 => '1.27'
    },
    add_to_cleanup => ['OntoPub-*'],
    create_readme  => 1,
);

$builder->create_build_script();

