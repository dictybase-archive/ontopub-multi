package OntoPub::Controller;

use strict;
use base 'Mojolicious::Controller';

# Other modules:

# Module implementation
#

sub has_db {
    my ( $self, $id ) = @_;
    return 1 if $id =~ /:/;
}

sub parse_id {
    my ( $self, $id ) = @_;
    return split /:/, $id;
}

sub get_resultset_from_query {
    my ($self) = @_;
    my $schema = $self->app->modware->handler;
    my $rs;
    my $id = $self->stash('id');
    if ( $self->has_db($id) ) {
        my ( $db, $id ) = $self->parse_id($id);
        $rs = $schema->resultset('Cv::Cvterm')->search(
            {   'db.name'          => $db,
                'dbxref.accession' => $id,
                'is_obsolete'      => 0
            },
            { join => { 'dbxref' => 'db' }, cache => 1 }
        );
    }
    else {
        $rs = $schema->resultset('Cv::Cvterm')->search(
            {   'dbxref.accession' => $self->stash('id'),
                'is_obsolete'      => 0
            },
            { join => 'dbxref', cache => 1 }
        );
    }
    return $rs;
}

1;    # Magic true value required at end of module

