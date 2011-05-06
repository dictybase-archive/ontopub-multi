#!/usr/bin/env perl

use strict;
use Test::More qw/no_plan/;
use Test::Mojo;

BEGIN {
    $ENV{MOJO_LOG_LEVEL} = 'fatal';
}

use_ok('OntoPub');

# Test
my $t = Test::Mojo->new( app => 'OntoPub' );
my $app = $t->get_ok('/publication/pubmed/21356102');
$app->status_is(200);
$app->content_type_like( qr/html/, 'It has html document' );
$app->text_is(
    'html head title' => 'Publication record',
    'It matches the title'
);
$app->text_is(
    'tr:nth-child(2) td:nth-last-of-type(2) font[size=-1] b' => 'PubMed ID:',
    'It matches the text before pubmed id'
);
$app->text_is(
    'tr:nth-child(2) td:last-child font[size=-1]' => '21356102',
    'It matches the pubmed id'
);
