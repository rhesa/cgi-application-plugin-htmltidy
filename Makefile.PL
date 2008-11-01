use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'CGI::Application::Plugin::HtmlTidy',
    VERSION_FROM      => 'lib/CGI/Application/Plugin/HtmlTidy.pm', # finds $VERSION
    LICENSE           => 'perl',
    PREREQ_PM         => {
            CGI::Application => 4.01,
            HTML::Tidy       => 1.08,
        }, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/CGI/Application/Plugin/HtmlTidy.pm', # retrieve abstract from module
       AUTHOR         => 'Rhesa Rozendaal <rhesa@cpan.org>') : ()),
);
