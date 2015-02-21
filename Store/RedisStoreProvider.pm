package Store::RedisStoreProvider;

use strict;
use warnings;
use 5.010;

use Redis;

use Exporter qw(import);

our @EXPORT_OK = qw/
                  get_connection  
                  /;

sub get_connection {
    my $config = shift;
    my $redis = defined $config ? Redis->new($config) : Redis->new;

    return $redis;
}

1;
