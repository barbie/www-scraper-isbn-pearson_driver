package WWW::Scraper::ISBN::Pearson_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.09';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::Pearson_Driver - Search driver for Pearson Education's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the Pearson Education's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
#Inheritence		                                                      #
###########################################################################

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Mechanize;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	SEARCH	=> 'http://www.pearsoned.co.uk/Bookshop/';
use constant	DETAIL	=> 'http://www.pearsoned.co.uk/Bookshop/detail.asp?item=';

#--------------------------------------------------------------------------

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the Pearson 
Education server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn13
  isbn
  author
  title
  book_link
  image_link
  description
  pubdate
  publisher

The book_link and image_link refer back to the Pearson Education UK website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $mechanize = WWW::Mechanize->new();
	$mechanize->get( SEARCH );

    return $self->handler("Pearson Education website appears to be unavailable.")
	    unless($mechanize->success());

	$mechanize->form_name('frmSearch');
	$mechanize->set_fields( 'txtSearch' => $isbn );
	$mechanize->submit();

	return $self->handler("Failed to find that book on Pearson Education website.")
	    unless($mechanize->success());

	# The Book page
    my $html = $mechanize->content();
#print STDERR "\n# content1=[\n$html\n]\n";

	return $self->handler("Failed to find that book on Pearson Education website.")
		if($html =~ m!Your search for <b>\d+</b> returned 0 results!si);

    my $data;
    ($data->{image},$data->{thumb})    = $html =~ m!<a href="(http://images.pearsoned-ema.com/jpeg/[^"]+)"><img src="(http://images.pearsoned-ema.com/jpeg/[^"]+)"!i;
    ($data->{title})                   = $html =~ m!<H1 class='largerbodybold'>(.*?)</H1>!i;
    ($data->{author},$data->{pubdate}) = $html =~ m!<H2 class='body' ><a title=[^>]+>(.*?)</a></H2><span class='body'>(.*?)</span>!i;
    ($data->{isbn13},$data->{isbn10})  = $html =~ m!ISBN13: ([\d]+)</span><br><span class = 'body'>ISBN10: ([-\d]+)</span>!i;
    ($data->{description})             = $html =~ m!<a name='Description'></a><span class='bodybold'>Description</span><br>(.*?)</td>!is;
    ($data->{bookid})                  = $html =~ m!recommend.asp\?item=(\d+)!i;

    if($data->{description}) {
        $data->{description} =~ s!^.*?<P>(.*?)</P>.*!$1!gis;
        $data->{description} =~ s!\s+$!!gis;
    }

	return $self->handler("Could not extract data from Pearson Education result page.")
		unless(defined $data);

	my $bk = {
		'isbn13'		=> $data->{isbn13},
		'isbn'			=> $data->{isbn10},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'book_link'		=> DETAIL.$data->{bookid},	#$mechanize->uri(),
		'image_link'	=> $data->{image},
		'thumb_link'	=> $data->{thumb},
		'description'	=> $data->{description},
		'pubdate'		=> $data->{pubdate},
		'publisher'		=> q!Pearson Education!,
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

  Copyright (C) 2004-2007 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

The full text of the licenses can be found in the F<Artistic> file included 
with this module, or in L<perlartistic> as part of Perl installation, in 
the 5.8.1 release or later.

=cut
