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
    my $this = shift;
    
    if (@_) {
        $this->{ws_client} = shift;
    }

    return $this->{ws_client};
}

sub online_clients {
    my $this = shift;
    
    if (@_) {
        $this->{online_clients} = shift;
    }

    return $this->{online_clients};
}

sub connection_shared_data {
    my $this = shift;
    
    if (@_) {
        $this->{connection_shared_data} = shift;
    }

    return $this->{connection_shared_data};
}

1;
