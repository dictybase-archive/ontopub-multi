#!/usr/bin/env perl

use strict;
use warnings;
use Test::Mojo;

use_ok('OntoPub');

# Test
my $t = Test::Mojo->new(app => 'OntoPub');
my $app = $t->get_ok('/publication/pubmed/21356102');
$app->status_is(200);
$app->content_type_is('text/html');
$app->text_is('html head title' => 'Publication record',  'It matches the title');
