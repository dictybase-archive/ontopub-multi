package OntoPub::Controller::Annotation;

use warnings;
use strict;
use Modware::Publication::DictyBase;
use base 'Mojolicious::Controller';

# Other modules:

# Module implementation
#

sub index {
    my ($self) = @_;
    my $schema = $self->app->modware->handler;
    my $rs     = $schema->resultset('Cv::Cvterm')->search(
        {   'db.name'          => uc $self->stash('name'),
            'dbxref.accession' => $self->stash('id'),
            'is_obsolete'      => 0
        },
        { join => { 'dbxref' => 'db' }, cache => 1 }
    );

    if ( !$rs->count ) {
        $self->render('no_record');
        return;
    }

    my $row = $rs->first;
    $self->stash(
        'full_id' => uc $self->stash('name') . ':' . $self->stash('id') );
    $self->stash( 'label'      => $row->name );
    $self->stash( 'definition' => $row->definition );
    $self->stash( 'ontology'   => $row->cv->name );

    my $fcvterm_rs = $schema->resultset('Sequence::FeatureCvterm')
        ->search( { 'cvterm_id' => $row->cvterm_id } );
    $self->stash( 'gene_count' => $fcvterm_rs->count );

    my $anno_stack;
    while ( my $fcvterm = $fcvterm_rs->next ) {
        my $stack;
        push @$stack, $fcvterm->feature->name;
        my $pub = Modware::Publication::DictyBase->find( $fcvterm->pub_id );
        $self->setup_citation( $pub, $stack );
        $self->setup_evcode( $fcvterm, $stack );
        push @$anno_stack, $stack;
    }

    $self->stash( 'anno_stack' => $anno_stack );
    $self->render('ontology/annotation');

}

sub setup_citation {
    my ( $self, $pub, $anno_stack ) = @_;
    my $author_count = $pub->total_authors;
    my ( $author_str, $citation_stack );
    if ($author_count) {
        if ( $author_count == 1 ) {
            $author_str = $pub->get_from_authors(0)->last_name;
        }
        elsif ( $author_count == 2 ) {
            $author_str = $pub->get_from_authors(0)->last_name . ' & '
                . $pub->get_from_authors(1)->last_name;
        }
        else {
            my $penultimate = $author_count - 2;
            for my $i ( 0 .. $penultimate ) {
                if ( $i == $penultimate ) {
                    $author_str
                        .= $pub->get_from_authors($i)->last_name . ' & ';
                    next;
                }
                $author_str .= $pub->get_from_authors($i)->last_name . ', ';
            }
            $author_str .= $pub->get_from_authors(-1)->last_name;
        }
        $citation_stack->{formatted_authors} = $author_str;
    }

    $citation_stack->{year} = $pub->year;
    for my $method (qw/abbreviation volume title/) {
        my $check = 'has_' . $method;
        if ( $pub->$check ) {
            $citation_stack->{$method} = $pub->$method;
        }
    }

    if ( $pub->has_pages ) {
        ( my $pages = $pub->pages ) =~ s/\-\-/-/;
        $citation_stack->{pages} = $pages;
    }

    if ( $pub->id !~ /^PUB/ or $pub->id =~ /^\d+/ ) {
        $citation_stack->{pubmed_id} = $pub->id;
    }
    $citation_stack->{full_text_url} = $pub->full_text_url
        if $pub->has_full_text_url;
    $citation_stack->{dictybase_id} = $pub->pub_id;
    push @$anno_stack, $citation_stack;
}

sub setup_evcode {
    my ( $self, $rs, $anno_stack ) = @_;
    my $prop_rs = $rs->feature_cvtermprops->search_related(
        'type',
        { 'cv.name' => { -like => 'evidence_code%' } },
        { join      => 'cv' }
        )->search_related(
        'cvtermsynonym_cvterms',
        { 'type_2.name' => { -in => [qw/EXACT RELATED/] } },
        { join          => 'type' }
        );
    push @$anno_stack, $prop_rs->first->synonym_;
}

1;    # Magic true value required at end of module

