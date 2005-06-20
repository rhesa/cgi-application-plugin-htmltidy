package CGI::Application::Plugin::HtmlTidy;

use 5.006;
use strict;
use warnings;
use Carp;
use CGI::Application 3.31;
use HTML::Tidy;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(htmltidy htmltidy_clean htmltidy_validate);

our $VERSION = '0.01';

sub htmltidy
{
	my $self = shift;
	my $opts =  $self->param('htmltidy_config') || {};
	htmltidy_config( $self, %$opts ) unless $self->{__PACKAGE__.'OPTIONS'};
	$self->{__PACKAGE__.'HTMLTIDY'} ||= HTML::Tidy->new($self->{__PACKAGE__.'OPTIONS'});
}

sub htmltidy_config {
	my $self = shift;
	my %opts = @_;
	$opts{config_file} ||= __find_config();
	$opts{action}      ||= 'validate';
	$self->{__PACKAGE__.'OPTIONS'} = \%opts;
}

sub htmltidy_clean {
	my ($self, $outputref) = @_;
	return unless __check_header($self);
	$$outputref = $self->htmltidy->clean($$outputref);
}

sub htmltidy_validate {
	my ($self, $outputref) = @_;
	return unless __check_header($self);
	$self->htmltidy->parse('why would i need to pass a file name if it isn\'t used?', $$outputref) or croak "Error parsing document: $@";
	if($self->htmltidy->messages) {
		my @msgs;
		my @output = map { {html=>$_} } split $/, $$outputref;
		foreach ( $self->htmltidy->messages() ) {
			push @{$output[$_->line-1]->{messages}},  {
				type	=> $_->type==TIDY_WARNING ? 'warning' : 'error',
				line	=> $_->line,
				column	=> $_->column,
				text	=> $_->text,
			};
		}
		my $t = $self->load_tmpl(__find_my_path().'/validate.tmpl', die_on_bad_params=>0, cache=>1);
		$t->param(output=>\@output);
		$$outputref = $t->output;
	}
}

sub __check_header {
	my $self = shift;
	
	return unless $self->header_type eq 'header'; # don't operate on redirects or 'none'
	
	my %props = $self->header_props;
	my ($type) = grep /type/i, keys %props;
	
	return 1 unless defined $type; # no type defaults to html, so we have work to do
	
	return $props{$type} =~ /html/i;
}

### find the config file
### 1. see if we can find the package version
### 2. fall back to /etc/tidy.conf
sub __find_config {
	my $inc = __find_my_path() . '/tidy.conf';
	return -f $inc ? $inc : '/etc/tidy.conf';
}

sub __find_my_path {
	my $inc = $INC{'CGI/Application/Plugin/HtmlTidy.pm'};
	$inc =~ s!\.pm$!!;
	return $inc;
}

1;

__END__

# design ideas
#
# 1. use an after_postrun callback to perform action:
#   sub cgiapp_postrun {
#     my ($self, $outputref) = @_;
#     ...
#     $self->call_hook('after_postrun', $outputref);
#   }
#   
# 2. possible actions: 
#	a) validate
#		this would parse the output, and report any warnings and/or errors.
#	b) clean
#		this would tidy up the output. This ensures valid (x)html.
# 
# 3. configuration
#	 this should be done in setup() or in the instance script.
#	 basic idea:
#		$self->param(htmltidy_config => {
#						config_file	=> '/my/tidy.conf',
#						action		=> 'clean',
#					});
#
# 4. implementation
#	 because the final action to perform is not known until runtime,
#	 we just install a generic hook at compile time.
#	 
# I'postponing the hook implementation till later. Let's see how this 
# version is received first.

=head1 NAME

CGI::Application::Plugin::HtmlTidy - Add HTML::Tidy support to CGI::Application

=head1 SYNOPSIS

  use CGI::Application::Plugin::HtmlTidy;
  
  sub cgiapp_postrun {
    my ($self, $contentref) = @_;

	# your post-process code here
	
    $self->htmltidy_validate($contentref);
    # or
    $self->htmltidy_clean($contentref);
  }

=head1 WARNING

This is the initial release. I welcome comments and discussion on the cgiapp
mailinglist. Note that it currently depends on a developer release
of L<HTML::Tidy> (namely version 1.05_02). I hope to persuade its author to
promote that release to an official one soon.

=head1 DESCRIPTION

This plugin is a wrapper around L<HTML::Tidy>. It exports two methods that
allow you to either validate or clean up the output of your cgiapp application.
They should be called at the end of your postrun method. 

The htmltidy_validate method is a helpful addition during development.
It generates a detailed report specifying the issues with your html.

The htmltidy_clean modifies your output to conform to the W3C standards.
It has been in use for quite some time on a largish site (generating
over 100,000 pages per day) and has proven to be quite stable and fast.
Every single page view was valid html, which makes many browsers happy :-)

=head2 CONFIGURATION

libtidy is extremely configurable. It has many options to influence how
it transforms your documents. HTML::Tidy communicates these options to
libtidy through a configuration file. In the future, it may also allow
programmatic access to all options.

You can specify the configuration using cgiapp's param() method, or in 
your instance script through the PARAM attribute. This plugin looks for 
a parameter named htmltidy_config, whose value should be a hash ref. 
This hash ref is then passed on directly to HTML::Tidy. Currently the only
supported parameter is "config_file".

Here's an example:

  sub setup {
    my $self = shift;
	$self->param( htmltidy_config => {
			    config_file => '/path/to/my/tidy.conf,
			});
  }

This plugin comes with a default configuration file with the following
settings:

	tidy-mark:      no
	wrap:           120
	indent:         auto
	output-xhtml:   yes
	char-encoding:  utf8
	doctype:        loose
	add-xml-decl:   yes
	alt-text:       [image]

=head2 EXPORT

=over 4

=item htmltidy

Direct access to the underlying HTML::Tidy object.

=item htmltidy_validate

Parses your output, and generates a detailed report if it doesn't conform
to standards. Your original output is returned only if there were no errors
or warnings.

=item htmltidy_clean

Parses and cleans your output to conform to standards.

=back

=head1 SEE ALSO

L<CGI::Application>, L<HTML::Tidy>.

The cgiapp mailing list can be used for questions, comments and reports.
The CPAN RT system can also be used.

=head1 AUTHOR

Rhesa Rozendaal, E<lt>rhesa@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Rhesa Rozendaal

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut

