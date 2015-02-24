package Command::BaseCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

sub new {
    my $class = shift;
    my $self = {request_message => shift};
    return bless $self, $class;
}

sub ws_client {
    return _set_object_field(shift, 'ws_client', shift);
}

sub online_clients {
    return _set_object_field(shift, 'online_clients', shift);
}

sub connection_shared_data {
    return _set_object_field(shift, 'connection_shared_data', shift);
}

sub _set_object_field {
    my $obj = shift;
    my $field_name = shift;
    my $field_value = shift;
    
    $obj->{$field_name} = $field_value if defined $field_value;

    return $obj->{$field_name};
}

1;
