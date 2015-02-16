package WebRender::JsonRender;

use strict;
use warnings;
use utf8;
use 5.010;

use Exporter qw(import);
use Utils::Constants;
use JSON -convert_blessed_universally;

our @EXPORT_OK = qw/
                    convert_to_json
                  /;

my $log = Mojo::Log->new;

sub convert_to_json {
	my $raw_object = shift;
	my $json_obj = JSON->new->allow_blessed->convert_blessed;
	my $json_string = $json_obj->encode($raw_object);

	return $json_string;
}

1;
