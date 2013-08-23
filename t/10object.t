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
		is($book->{'image_link'},'http://images.pearsoned-ema.com/jpeg/large/0201795264.jpg');
		is($book->{'thumb_link'},'http://images.pearsoned-ema.com/jpeg/small/0201795264.jpg');
		is($book->{'description'},q|<br><P><P>The first book to explain how to understand, maintain, update, and improve existing Perl code </P><UL><LI>Perl is especially susceptible to maintenance problems, because of its flexible style and ad hoc origins </LI><LI>Author uses a medical theme throughout, playing off the similarities of doctoring or healing broken code </LI><LI>Contains the most comprehensive treatment of testing Perl programs ever published, as well as the most comprehensive discussion of Perl version differences </LI></UL>This book is about taking over Perl code, whether written by someone else or by yourself at an earlier time. Developers regularly estimate that they spend 60 to 80 percent of their time working with existing code. Many problems of code inheritance are common to all languages, but the nature of the language makes Perl especially tricky. The reason why is that Perl is similar to English - bursting with irregular verbs, consistent only when it's convenient, borrowing terms from other languages, and providing many ways to say the same thing. In fact, Perl developers have a motto with the abbreviation TMTOWTDI: There's More Than One Way To Do It. While this flexibility is one of the language's strengths, it also makes it extremely difficult when you are faced with an existing piece of code. There are millions of lines of Perl code being used all over the Web; much of it was built on an ad hoc basis, the creators never imagining that the code would still be in use months or years later. This book will be the resource all Perl programmers need to understand someone else's code, even when it's bad; repair it; convert it to a better style; upgrade it to the latest version of Perl; maintain it; and find and fix its bugs.</p>|);
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
		is($book->{'image_link'},'http://images.pearsoned-ema.com/jpeg/large/0672320673.jpg');
		is($book->{'thumb_link'},'http://images.pearsoned-ema.com/jpeg/small/0672320673.jpg');
		is($book->{'description'},q|<br><DIV><DIV>&nbsp;</DIV><P>A well-organized, high-quality, comprehensive reference to the Perl language designed for experienced Perl programmers! </P><UL>  <LI>A complete, well-organized reference to the Perl language and environment,   including core syntax as well as Perl modules.   <LI>Extensively cross-referenced and indexed for optimal usability.   <LI>Fills a need in the market for a high-quality, complete language   reference. </LI></UL>In addition to providing a complete syntax reference for all core Perl functions, the <I>Perl Developers Dictionary</I> also provides quick access to language syntax, constructs, and other language issues for experienced developers. Each major section of the book is prefaced with a short introduction to provide background material on the subject at hand, and then is followed by a series of "dictionary" entries that cover exactly one topic, carefully cross-referenced and indexed with the rest of the book. <DIV>&nbsp;</DIV></DIV></p>|);
		is($book->{'pubdate'},'Jul 2001');
	}

###########################################################

