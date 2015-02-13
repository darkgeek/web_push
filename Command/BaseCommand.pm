package Command::BaseCommand;

use strict;
use warnings;

use Exporter qw(import);

my $_ws_client;

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
