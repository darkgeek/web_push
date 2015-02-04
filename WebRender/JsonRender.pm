package WebRender::JsonRender;

use strict;
use warnings;
use utf8;

use Exporter qw(import);
use Utils::Constants;
use JSON -convert_blessed_universally;

my $log = Mojo::Log->new;

sub convert_to_json {
	my $raw_object = shift;
	my $json_obj = JSON->new->allow_blessed->convert_blessed;
	my $json_string = $json_obj->encode($raw_object);

	return $json_string;
}

sub generate_result {
	my $result_code = shift;
    my $result_content = shift;
	my @res = ();

    $result_content = '' unless defined $result_content;
	my %result = (
		Utils::Constants::RESULT_CODE_NAME =>  $result_code,
        Utils::Constants::RESULT_CONTENT_NAME => $result_content,
	);
	
	push @res, \%result;

	return convert_to_json(\@res);
}

1;
