package Utils::WebUtils;

use warnings;
use strict;

use Exporter qw(import);
use JSON -convert_blessed_universally;

our @EXPORT_OK = qw/
                    json_to_ref
                    get_logger
                    set_object_field
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

sub set_object_field {
    my $obj = shift;
    my $field_name = shift;
    my $field_value = shift;
    
    $obj->{$field_name} = $field_value if defined $field_value;

    return $obj->{$field_name};
}

1;
