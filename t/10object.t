#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 22;

###########################################################

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 21   if(pingtest());

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
		is($book->{'isbn'},'1932394508');
		is($book->{'title'},'Minimal Perl');
		is($book->{'author'},'Tim Maher');
		is($book->{'book_link'},'http://www.pearsoned.co.uk/Bookshop/detail.asp?item=100000000120863');
		is($book->{'image_link'},'http://images.pearsoned-ema.com/jpeg/large/9781932394504.jpg');
		is($book->{'thumb_link'},'http://images.pearsoned-ema.com/jpeg/small/9781932394504.jpg');
		like($book->{'description'},qr|Most books make Perl unnecessarily hard to learn by attempting|);
		is($book->{'pubdate'},'Oct 2006');
	}

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'Pearson');

		my $book = $record->book;
		is($book->{'isbn'},'0672320673');
		is($book->{'title'},q|Perl Developer's Dictionary|);
		like($book->{'author'},qr/Clinton Pierce/);
		is($book->{'book_link'},'http://www.pearsoned.co.uk/Bookshop/detail.asp?item=246272');
		is($book->{'image_link'},'http://images.pearsoned-ema.com/jpeg/large/9780672320675.jpg');
		is($book->{'thumb_link'},'http://images.pearsoned-ema.com/jpeg/small/9780672320675.jpg');
		like($book->{'description'},qr|In addition to providing a complete syntax reference for all core Perl functions|);
		is($book->{'pubdate'},'Jul 2001');

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
