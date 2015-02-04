package Utils::WebUtils;

use warnings;
use strict;

use Exporter qw(import);
use JSON -convert_blessed_universally;

sub json_to_ref {
    my $raw_json = shift;
    my $json = JSON->new->allow_blessed->convert_blessed;
    my $ref = $json->decode($raw_json);

    return $ref;
}

1;
