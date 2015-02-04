package EndPoint::EndPointGenerator;

use strict;
use warnings;
use utf8;

use Exporter qw(import);

use Data::UUID;

our @EXPORT = qw/
		/;

my $log = Mojo::Log->new;

sub generate {
    my $ug = Data::UUID->new;

    return $ug->create_b64();
}

1;
