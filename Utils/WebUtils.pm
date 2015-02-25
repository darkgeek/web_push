package Utils::WebUtils;

use warnings;
use strict;

use Exporter qw(import);
use JSON -convert_blessed_universally;

our @EXPORT_OK = qw/
                    json_to_ref
                    get_logger
                 /;

sub json_to_ref {
    my $raw_json = shift;
    my $json = JSON->new->allow_blessed->convert_blessed;
    my $ref = $json->decode($raw_json);

    return $ref;
}

sub get_logger {
    my $config = shift;
    my $log;  

    if (defined $config) {
        $log = Mojo::Log->new($config);
    }
    else {
        $log = Mojo::Log->new();
    }
    return $log;
}


1;
