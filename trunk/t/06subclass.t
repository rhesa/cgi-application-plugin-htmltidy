
use strict;

use Test::More tests => 4;

use lib './t';

use CleanSubApp;
use ValidateSubApp;

$ENV{CGI_APP_RETURN_ONLY} = 1;
$ENV{REQUEST_METHOD} = 'GET';

my $app = CleanSubApp->new(PARAMS=> {
                htmltidy_config => {
					config_file => './t/tidy.conf',
				}
		});
my $out = $app->run;

like($out, qr/<meta name="generator" content="HTML Tidy/,  'output cleaned');
like($out, qr!valid!, 'content ok');

my $app2 = ValidateSubApp->new;
$app2->start_mode('valid_html');

unlike($app2->run, qr/validation results/, 'valid html');

$app2 = ValidateSubApp->new();
$app2->start_mode('invalid_html');

like ($app2->run, qr/validation results/ , 'First error message');


