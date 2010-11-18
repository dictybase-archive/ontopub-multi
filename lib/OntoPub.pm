package OntoPub;

use strict;
use warnings;
use base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    #yaml and bcs plugins
    $self->plugin('yml_config');
    $self->plugin('modware');

    # Routes
    my $r = $self->routes;

    ## -- routes
    # GET /publication - List of publication
    # POST /publication - Delete a publication from the list [xxxx]
    ## --
    # GET /publication/id - detail about publication
    # DELETE /publication/id - destroy that publication record xxxxxx
    # PUT /publication/id - update that publication xxxxx

    my $publication = $r->waypoint('/publication')->via('get')
        ->to('controller-publication#index');
    $publication->route('/:id')->via('get')
        ->to('controller-publication#show');

}

1;
