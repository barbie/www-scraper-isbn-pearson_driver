package WWW::Scraper::ISBN::Pearson_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.07';

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
use Template::Extract;

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
	return undef	unless($mechanize->success());

	$mechanize->form_name('frmSearch');
	$mechanize->set_fields( 'txtSearch' => $isbn );
	$mechanize->submit();

	return undef	unless($mechanize->success());

	# The Book page
	my $template = <<END;
	<TABLE width="450" border="0" cellpadding="0" cellspacing="0">[% ... %]
<a href="[% image %]"><img src="[% thumb %]" border="1" align="left" alt="[% ... %]"></a>[% ... %]
<span class='largerbodybold'>[% title %]</span><br><span class='body'>[% author %]</span><br><span class = 'body'>[% isbn %]</span><span class='body'>[% ... %]</span><span class='body'>&nbsp;[% pubdate %],</span>[% ... %]
<span class='bodybold'>Description</span>[% description %]<a href='#topofpage'>top</a>[% ... %]
voucher.asp?item=[% bookid %]&title=[% ... %]
END

#	print STDERR $mechanize->content();

	my $extract = Template::Extract->new;
    my $data = $extract->extract($template, $mechanize->content());

	return $self->handler("Could not extract data from Pearson Education result page.")
		unless(defined $data);

	$data->{author} =~ s/.*>//;

	my $bk = {
		'isbn'			=> $data->{isbn},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'book_link'		=> DETAIL.$data->{bookid},	#$mechanize->uri(),
		'image_link'	=> $data->{image},
		'thumb_link'	=> $data->{thumb},
		'description'	=> $data->{description},
		'pubdate'		=> $data->{pubdate},
		'publisher'		=> q!Pearson Education!,
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<WWW::Mechanize>

=item L<Template::Extract>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Scraper::ISBN>

=item L<WWW::Scraper::ISBN::Record>

=item L<WWW::Scraper::ISBN::Driver>

=back

=head1 AUTHOR

  Barbie, E<lt>barbie@cpan.orgE<gt>
  Miss Barbell Productions, L<http://www.missbarbell.co.uk/>

=head1 COPYRIGHT

  Copyright (C) 2004-2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut

