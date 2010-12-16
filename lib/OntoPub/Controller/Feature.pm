package OntoPub::Controller::Feature;

use strict;
use base 'OntoPub::Controller';

# Other modules:

# Module implementation
#

sub index {
    my ($self) = @_;
    my $rs = $self->get_resultset_from_query;
    if ( !$rs->count ) {
        $self->render('no_record');
        return;
    }
    my $row = $rs->first;
    $self->stash( 'label' => $row->name );

    my $feature_rs = $rs->search_related( 'feature_cvterms', {} )
        ->search_related( 'feature', {}, { prefetch => 'dbxref' } );

    $self->stash( 'features' =>
            { map { $_->dbxref->accession, $_->name } $feature_rs->all } );

    $self->render('ontology/annotation/feature');
}

1;    # Magic true value required at end of module

