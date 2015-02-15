package Security::UniformIDGenerator;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);
our @EXPORT_OK = qw/
                generate_endpoint
                generate_channelid
                generate_uaid
              /;

use UUID::Tiny ':std';

sub generate_uaid {
    my $uaid = create_uuid_as_string(UUID_V4);
    
    return $uaid;
}

sub generate_channelid {
    my $channel_id = create_uuid_as_string(UUID_V4);

    return $channel_id;
}

sub generate_endpoint {

}

1;
