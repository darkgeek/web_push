package Store::RedisStoreProvider;

use strict;
use warnings;
use 5.010;

use Redis;

use Exporter qw(import);

our @EXPORT_OK = qw/
                  get_connection  
                  commit_transaction
                  /;

sub get_connection {
    my $config = shift;
    my $redis = defined $config ? Redis->new($config) : Redis->new;

    return $redis;
}

sub commit_transaction {
    my $action = shift;
    my $conn = shift;

    $conn->multi;
    $action->();
    $conn->exec;
}

1;
