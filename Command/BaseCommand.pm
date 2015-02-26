package Command::BaseCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);
use Utils::WebUtils qw(set_object_field);

sub new {
    my $class = shift;
    my $self = {request_message => shift};
    return bless $self, $class;
}

sub ws_client {
    return set_object_field(shift, 'ws_client', shift);
}

sub online_clients {
    return set_object_field(shift, 'online_clients', shift);
}

sub connection_shared_data {
    return set_object_field(shift, 'connection_shared_data', shift);
}

1;
