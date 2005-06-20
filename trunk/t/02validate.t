
use strict;

use Test::More tests => 3;

use lib './t';

use ValidateApp;

$ENV{CGI_APP_RETURN_ONLY} = 1;
$ENV{REQUEST_METHOD} = 'GET';
my $app = ValidateApp->new;

can_ok($app, 'htmltidy_validate');
like($app->run, qr/valid/, 'valid html');

my $app2 = ValidateApp->new();
$app2->start_mode('invalid_html');

like ($app2->run, qr/missing .*DOCTYPE.* declaration/ , 'First error message');

