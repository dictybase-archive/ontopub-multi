#!/usr/bin/env perl

use strict;
use warnings;
use Test::More qw/no_plan/;
use Test::Mojo;

BEGIN {
	$ENV{MOJO_LOG_LEVEL} = 'fatal';
}

use_ok('OntoPub');

# Test
my $t = Test::Mojo->new(app => 'OntoPub');
my $app = $t->get_ok('/publication/pubmed/21356102');
$app->status_is(200);
$app->content_type_like(qr/html/,  'It has html document');
$app->text_is('html head title' => 'Publication record',  'It matches the title');
