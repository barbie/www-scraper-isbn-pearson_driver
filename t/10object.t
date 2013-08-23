#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 21;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("Pearson");
	my $isbn = "0201795264";
	my $record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'Pearson');

		my $book = $record->book;
		is($book->{'isbn'},'0201795264');
		is($book->{'title'},'Perl Medic');
		is($book->{'author'},'Peter Scott');
		is($book->{'book_link'},'http://www.pearsoned.co.uk/Bookshop/detail.asp?item=303342');
		is($book->{'image_link'},'http://images.pearsoned-ema.com/jpeg/large/9780201795264.jpg');
		is($book->{'thumb_link'},'http://images.pearsoned-ema.com/jpeg/small/9780201795264.jpg');
		like($book->{'description'},qr|This book is about taking over Perl code, whether written by someone else or by yourself at an earlier time|);
		is($book->{'pubdate'},'Mar 2004');
	}

	$isbn = "0672320673";
	$record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

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
	}

###########################################################

