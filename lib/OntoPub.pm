package OntoPub;

use strict;
use warnings;
use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    #yaml and bcs plugins
    $self->plugin('yml_config');
    $self->plugin('modware-oracle');

    # Routes
    my $r = $self->routes;

    ## -- routes
    # GET /publication - List of publication
    # POST /publication - Add publication from the list [xxxx]
    ## --
    # GET /publication/id - detail about publication
    # DELETE /publication/id - destroy that publication record xxxxxx
    # PUT /publication/id - update that publication xxxxx

    my $publication = $r->waypoint('/publication')->via('get')
        ->to('controller-publication#index');
    $publication->route('/:id')->via('get')
        ->to('controller-publication#show');

	# GET /ontology - List of ontology [xxxx]
    # POST /ontology - Add ontology list [xxxx]
	my $onto = $r->waypoint('/ontology')->via('get')
        ->to('controller-ontology#index');

    # GET /ontology/:namespace - Detail about ontology,  including list of terms [xxxxx]
    my $name = $onto->waypoint('/:name')->via('get')
        ->to('controller-ontology#show');

    # GET /ontology/:namespace/:id - detail about term  in that ontology [xxxxx]
    my $term = $name->waypoint('/:id')->via('get')
        ->to('controller-term#show');

    # GET /ontology/:namespace/:id/annotation - annotation associated with that term in that ontology 
    $term->route('/annotation')->via('get')->to('controller-annotation#index');

}

1;
