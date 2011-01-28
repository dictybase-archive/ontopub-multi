package OntoPub::Controller::Annotation;

use strict;
use Modware::Publication::DictyBase;
use base 'OntoPub::Controller';

# Other modules:

# Module implementation
#

sub index {
    my ($self) = @_;
    my $rs     = $self->get_resultset_from_query;
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

    $self->setup_synonym($row);

	my $schema = $rs->result_source->schema;
    my $fcvterm_rs = $schema->resultset('Sequence::FeatureCvterm')->search(
        { 'cvterm_id' => $row->cvterm_id, 'me.is_not' => 0 },
        {   prefetch => 'feature',
            cache    => 1,
            order_by => { -asc => 'feature.name' }
        }
    );

    $self->stash(
        'gene_count' => $fcvterm_rs->search_related( 
            'feature', {}, { group_by => 'me.feature_id' }
        )->count
    );

    my $fcvterm_negated_rs
        = $schema->resultset('Sequence::FeatureCvterm')->search(
        { 'cvterm_id' => $row->cvterm_id, 'me.is_not' => 1 },
        {   prefetch => 'feature',
            cache    => 1,
        }
        );

    $self->stash(
        'negated_count' => $fcvterm_negated_rs->count(
            'feature', {}, { group_by => 'me.feature_id' }
        )
    );

    if ( $self->stash('page') ) {
        my $row_per_page = $self->app->config->{rows};
        $fcvterm_rs = $schema->resultset('Sequence::FeatureCvterm')->search(
            { 'cvterm_id' => $row->cvterm_id, 'me.is_not' => 0 },
            {   rows     => $row_per_page,
                page     => $self->stash('page'),
                prefetch => 'feature',
                order_by => { -asc => 'feature.name' }
            }
        );
        my $total = $fcvterm_rs->pager->total_entries;
        $self->stash( 'pager' => $fcvterm_rs->pager )
            if $total >= $row_per_page;
    }

    $self->setup_annotation( $fcvterm_rs,         'anno_stack' );
    $self->setup_annotation( $fcvterm_negated_rs, 'negated_stack' );
    $self->render('ontology/annotation');
}

sub setup_annotation {
    my ( $self, $rs, $key ) = @_;
    my $anno_stack;
    while ( my $fcvterm = $rs->next ) {
        my $name = $fcvterm->feature->name;
        my $pub  = Modware::Publication::DictyBase->find( $fcvterm->pub_id );
        push @{ $anno_stack->{$name}->{pub} },    $self->get_citation($pub);
        push @{ $anno_stack->{$name}->{evcode} }, $self->get_evcode($fcvterm);
    }
    $self->stash( $key => $anno_stack ) if $anno_stack;
}

sub setup_synonym {
    my ( $self, $row ) = @_;
    my $rs = $row->cvtermsynonym_cvterms;
    if ( $rs->count ) {
        $self->stash( 'synonyms' => [ map { $_->synonym_ } $rs->all ] );
    }

}

sub get_citation {
    my ( $self, $pub ) = @_;
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
        my $pages = $pub->pages;
        $pages =~ s/\-\-/-/;
        $citation_stack->{pages} = $pages;
    }

    if ( $pub->id !~ /^PUB/ or $pub->id =~ /^\d+/ ) {
        $citation_stack->{pubmed_id} = $pub->id;
    }
    $citation_stack->{full_text_url} = $pub->full_text_url
        if $pub->has_full_text_url;
    $citation_stack->{dictybase_id} = $pub->pub_id;
    return $citation_stack;
}

sub get_evcode {
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
    return $prop_rs->first->synonym_;
}

1;    # Magic true value required at end of module

