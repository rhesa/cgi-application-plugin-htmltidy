package CGI::Application::Plugin::HtmlTidy;

use 5.006;
use strict;
use warnings;
use CGI::Application 3.21;
use HTML::Tidy 1.05;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    htmltidy
    htmltidy_config
    clean
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.01';



1;
__END__

=head1 NAME

CGI::Application::Plugin::HtmlTidy - Add HTML::Tidy support to CGI::Application

=head1 SYNOPSIS

  use CGI::Application::Plugin::HtmlTidy;
  
  # in setup()
  
  $self->htmltidy_config( options => settings );
  
  # in normal code
  
  $self->htmltidy->parse($content);
  

=head1 DESCRIPTION

Stub documentation for CGI::Application::Plugin::HtmlTidy, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
