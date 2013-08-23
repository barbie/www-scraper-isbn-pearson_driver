#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 38;

###########################################################

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 37   if(pingtest());

	$scraper->drivers("Pearson");

    # this ISBN doesn't exist
	my $isbn = "1234567890";
    my $record;
    eval { $record = $scraper->search($isbn); };
    if($@) {
        like($@,qr/Invalid ISBN specified/);
    }
    elsif($record->found) {
        ok(0,'Unexpectedly found a non-existent book');
    } else {
		like($record->error,qr/Failed to find that book on Pearson Education website/);
    }

	$isbn = "1932394508";
	$record = $scraper->search($isbn);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'Pearson');

		my $book = $record->book;
		is($book->{'isbn'},         '9781932394504'         ,'.. isbn found');
		is($book->{'isbn10'},       '1932394508'            ,'.. isbn10 found');
		is($book->{'isbn13'},       '9781932394504'         ,'.. isbn13 found');
		is($book->{'ean13'},        '9781932394504'         ,'.. ean13 found');
		is($book->{'title'},        'Minimal Perl'          ,'.. title found');
		is($book->{'author'},       'Tim Maher'             ,'.. author found');
		like($book->{'book_link'},  qr|http://.*?item=100000000120863|);
		is($book->{'image_link'},   'http://images.pearsoned-ema.com/jpeg/large/9781932394504.jpg');
		is($book->{'thumb_link'},   'http://images.pearsoned-ema.com/jpeg/small/9781932394504.jpg');
		like($book->{'description'},qr|Most books make Perl unnecessarily hard to learn by attempting|);
		is($book->{'pubdate'},      'Oct 2006'              ,'.. pubdate found');
		is($book->{'binding'},      'Paperback'             ,'.. binding found');
		is($book->{'pages'},        undef                   ,'.. pages found');
		is($book->{'width'},        undef                   ,'.. width found');
		is($book->{'height'},       undef                   ,'.. height found');
		is($book->{'weight'},       undef                   ,'.. weight found');
	}

	$isbn = "9780672320675";
	$record = $scraper->search($isbn);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'Pearson');

		my $book = $record->book;
		is($book->{'isbn'},         '9780672320675'         ,'.. isbn found');
		is($book->{'isbn10'},       '0672320673'            ,'.. isbn10 found');
		is($book->{'isbn13'},       '9780672320675'         ,'.. isbn13 found');
		is($book->{'ean13'},        '9780672320675'         ,'.. ean13 found');
		like($book->{'author'},     qr/Clinton Pierce/      ,'.. author found');
		is($book->{'title'},        q|Perl Developer's Dictionary|  ,'.. title found');
		like($book->{'book_link'},  qr|http://.*?item=246272|);
		is($book->{'image_link'},   'http://images.pearsoned-ema.com/jpeg/large/9780672320675.jpg');
		is($book->{'thumb_link'},   'http://images.pearsoned-ema.com/jpeg/small/9780672320675.jpg');
		like($book->{'description'},qr|In addition to providing a complete syntax reference for all core Perl functions|);
		is($book->{'pubdate'},      'Jul 2001'              ,'.. pubdate found');
		is($book->{'binding'},      'Paperback'             ,'.. binding found');
		is($book->{'pages'},        640                     ,'.. pages found');
		is($book->{'width'},        undef                   ,'.. width found');
		is($book->{'height'},       undef                   ,'.. height found');
		is($book->{'weight'},       undef                   ,'.. weight found');

        #use Data::Dumper;
        #diag("book=[".Dumper($book)."]");
	}
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
  system("ping -q -c 1 www.google.com >/dev/null 2>&1");
  my $retcode = $? >> 8;
  # ping returns 1 if unable to connect
  return $retcode;
}
