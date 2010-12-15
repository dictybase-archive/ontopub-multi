package OntoPub::Controller::Evidence;

use strict;
use base 'Mojolicious::Controller';

# Other modules:

# Module implementation
#

sub index {
    my ($self) = @_;
    $self->render('ontology/annotation/evidence');
}

1;    # Magic true value required at end of module

