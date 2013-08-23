use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'WWW::Scraper::ISBN::Pearson_Driver',
    'VERSION_FROM'	=> 'lib/WWW/Scraper/ISBN/Pearson_Driver.pm',
    'PREREQ_PM'		=> {
		Test::More					=> 0.45,	# for testing
		WWW::Scraper::ISBN			=> 0.23,
		WWW::Scraper::ISBN::Driver	=> 0.16,
		WWW::Mechanize				=> 0,
		Template::Extract			=> 0,

	},
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => q|Search driver for Pearson Education's online catalog|,
       AUTHOR     => 'Barbie <barbie@cpan.org>') : ()),
);
