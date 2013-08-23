package WWW::Scraper::ISBN::Pearson_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.13';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::Pearson_Driver - Search driver for the Pearson Education online book catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the Pearson Education's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
# Inheritence

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
# Modules

use WWW::Mechanize;

###########################################################################
# Constants

use constant	SEARCH	=> 'http://www.pearsoned.co.uk/Bookshop/';
use constant	DETAIL	=> 'http://www.pearsoned.co.uk/Bookshop/detail.asp?item=';

#--------------------------------------------------------------------------

###########################################################################
# Public Interface

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Pearson
Education server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn          (now returns isbn13)
  isbn10        
  isbn13
  ean13         (industry name)
  author
  title
  book_link
  image_link
  description
  pubdate
  publisher
  binding       (if known)
  pages         (if known)
  weight        (if known) (in grammes)
  width         (if known) (in millimetres)
  height        (if known) (in millimetres)

The book_link and image_link refer back to the Pearson Education UK website.

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
    $mechanize->agent_alias( 'Linux Mozilla' );
	$mechanize->get( SEARCH );

    return $self->handler("Pearson Education website appears to be unavailable.")
	    unless($mechanize->success());

	$mechanize->form_id('frmSearch');
	$mechanize->set_fields( 'txtSearch' => $isbn );
	$mechanize->submit();

	return $self->handler("Failed to find that book on Pearson Education website.")
	    unless($mechanize->success());

	# The Book page
    my $html = $mechanize->content();
#print STDERR "\n# content1=[\n$html\n]\n";

	return $self->handler("Failed to find that book on Pearson Education website.")
		if($html =~ m!<p>Your search for <b>\d+</b> returned 0 results. Please search again.</p>!si);

    my $data;
    ($data->{image},$data->{thumb})     = $html =~ m!<a href="(http://images.pearsoned-ema.com/jpeg/[^"]+)"><img src="(http://images.pearsoned-ema.com/jpeg/[^"]+)"!i;
    ($data->{title})                    = $html =~ m!<div class="biblio">\s*<h1 class="larger bold">(.*?)</h1>!i;
    ($data->{author},$data->{pubdate},$data->{binding},$data->{pages}) 
                                        = $html =~ m!<h2 class="body"><a title=[^>]+>(.*?)</a></h2>([^,]+),\s*([^,<]+)(?:,\s*([^<]+)pages)?<br />!i;
    ($data->{isbn13},$data->{isbn10})   = $html =~ m!ISBN13:\s*(\d+)\s*<br />ISBN10:\s*(\d+)!i;
    ($data->{description})              = $html =~ m!<div class="desc-text"><p><p>([^<]+)!is;
    ($data->{bookid})                   = $html =~ m!recommend.asp\?item=(\d+)!i;

#use Data::Dumper;
#print STDERR "\n# " . Dumper($data);

	return $self->handler("Could not extract data from Pearson Education result page.")
		unless(defined $data);

	# trim top and tail
	foreach (keys %$data) { next unless(defined $data->{$_});$data->{$_} =~ s/^\s+//;$data->{$_} =~ s/\s+$//; }

	my $bk = {
		'ean13'		    => $data->{isbn13},
		'isbn13'		=> $data->{isbn13},
		'isbn10'		=> $data->{isbn10},
		'isbn'			=> $data->{isbn13},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'book_link'		=> $mechanize->uri(),   #DETAIL . $data->{bookid},
		'image_link'	=> $data->{image},
		'thumb_link'	=> $data->{thumb},
		'description'	=> $data->{description},
		'pubdate'		=> $data->{pubdate},
		'publisher'		=> q!Pearson Education!,
		'binding'	    => $data->{binding},
		'pages'		    => $data->{pages},
		'weight'		=> $data->{weight},
		'width'		    => $data->{width},
		'height'		=> $data->{height}
	};

#use Data::Dumper;
#print STDERR "\n# book=".Dumper($bk);

    $self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

  Barbie, <barbie@cpan.org>
  Miss Barbell Productions, <http://www.missbarbell.co.uk/>

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2004-2010 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the Artistic Licence v2.

=cut
