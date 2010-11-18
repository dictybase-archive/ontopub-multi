package OntoPub::Controller::Publication;

use strict;
use warnings;
use Modware::Publication::DictyBase;
use List::MoreUtils qw/firstidx/;
use Data::Dumper;
use base 'Mojolicious::Controller';

# This action will render a template
sub show {
    my $self   = shift;
    my $id     = $self->stash('id');
    my $source = $self->param('source');
    my $pub;
    if ( defined $source and $source =~ /pubmed/i ) {
        $pub = Modware::Publication::DictyBase->find_by_pubmed_id($id);
    }
    else {
        $pub = Modware::Publication::DictyBase->find($id);
    }
    if ($pub) {
        $self->setup_citation($pub);
        $self->setup_linkouts($pub);
        $self->setup_body($pub);
        $self->included_genes($pub);
        $self->topics($pub);
        $self->render('show');
    }
    else {
        $self->render('no_record');
    }
}

sub setup_citation {
    my ( $self, $pub ) = @_;
    if ( $pub->has_authors ) {
        my $author_str;
        for my $author ( $pub->authors ) {
            $author_str
                .= $author->last_name . ', ' . $author->first_name . ', ';
        }
        $author_str =~ s/\,$//;
        $self->stash( 'formatted_authors' => $author_str );
    }

    $self->stash( 'year' => $pub->year );

    for my $method (qw/abbreviation volume/) {
        my $check = 'has_' . $method;
        if ( $pub->$check ) {
            $self->stash( $method => $pub->$method );
        }
    }

    if ( $pub->has_title ) {
        $self->stash( 'pub_title' => $pub->title );
    }

    if ( $pub->has_pages ) {
        ( my $pages = $pub->pages ) =~ s/\-\-/-/;
        $self->stash( 'pages' => $pages );
    }

}

sub setup_linkouts {
    my ( $self, $pub ) = @_;
    if ( $pub->id !~ /^PUB/ or $pub->id =~ /^\d+/ ) {
        $self->stash( 'pubmed_id' => $pub->id );
    }
    $self->stash( 'full_text_url' => $pub->full_text_url )
        if $pub->has_full_text_url;

}

sub setup_body {
    my ( $self, $pub ) = @_;
    $self->stash( 'abstract' => $pub->abstract ) if $pub->has_abstract;
    for my $method (qw/status type source/) {
        $self->stash( 'pub_' . $method => $pub->$method );
    }

}

sub included_genes {
    my ( $self, $pub ) = @_;
    my $rs
        = $pub->dbrow->search_related( 'feature_pubs', {} )->search_related(
        'feature',
        { 'type.name' => 'gene' },
        { join        => 'type' }
        );
    my $genes = [ map { $_->uniquename } $rs->all ];
    return if !@$genes;
    $self->stash( 'genes' => [ sort @$genes ] );
}

sub topics {
    my ( $self, $pub ) = @_;
    return if not defined $self->stash('genes');
    my $genes  = $self->stash('genes');
    my $pub_id = $pub->pub_id;
    my $schema = $pub->chado;
    my $topic2genes;
    for my $name (@$genes) {
        my $keywords = [
            map { $_->name }
                $schema->resultset('Sequence::Feature')
                ->search( { 'uniquename' => $name } )
                ->search_related( 'feature_pubs', { pub_id => $pub_id } )
                ->search_related( 'feature_pubprops',
                { 'value' => { 'like', 1 } } )->search_related(
                'type',
                { 'cv.name' => 'dictyBase_literature_topic' },
                { join      => 'cv' }
                )
        ];

    WORD:
        for my $word (@$keywords) {
            next WORD if $word eq 'Curated';
            if ( not defined $topic2genes->{$word} ) {
                push @{ $topic2genes->{$word} }, 'none'
                    for 0 .. scalar @$genes - 1;
                my $idx = firstidx { $_ eq $name } @$genes;
                if ( defined $idx and $idx >= 0 ) {
                    my @array = @{ $topic2genes->{$word} };
                    $array[$idx] = $name;
                    $topic2genes->{$word} = \@array;
                }
            }
            else {
                my $idx = firstidx { $_ eq $name } @$genes;
                if ( defined $idx and $idx >= 0 ) {
                    my @array = @{ $topic2genes->{$word} };
                    $array[$idx] = $name;
                    $topic2genes->{$word} = \@array;
                }
            }
        }
    }

    if ( defined $topic2genes ) {
        if ( defined $topic2genes->{'Not yet curated'} ) {
            my $curated_genes = $topic2genes->{'Not yet curated'};
            delete $topic2genes->{'Not yet curated'};
            $self->stash( 'uncurated_genes' => $curated_genes );
        }
        $self->stash( 'topic2genes' => $topic2genes ) if keys %$topic2genes > 0;
    }

}

1;
