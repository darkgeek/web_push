package Security::UniformIDGenerator;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);
our @EXPORT_OK = qw/
                generate_endpoint
                generate_uaid
                parse_uaid
              /;

use UUID::Tiny ':std';
use Utils::Constants;

sub generate_uaid {
    my $uaid = create_uuid_as_string(UUID_V4);
    
    return $uaid;
}

sub generate_endpoint {
    my $chanid = shift;

    return Utils::Constants::SERVER_ADDRESS.$chanid;
}

sub parse_uaid {
    my $endpoint = shift;

    return $endpoint;
}

1;
