package Store::DataAccessFacade;

use strict;
use warnings;
use 5.010;

use Store::RedisStoreProvider qw(get_connection);

use Exporter qw(import);

use parent 'Base';

sub update_channel {
    my $this = shift;

    my $chanid = shift;
    my $uaid = shift;
    my $version = shift;
    my $conn = get_connection();
    
    $conn->hmset("chanid:$chanid", 'uaid' => $uaid, 'version' => $version);
}

sub update_chanid_list_for_uaid {
    my $this = shift;
    
}

1;
