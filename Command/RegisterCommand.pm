package Command::RegisterCommand;

use strict;
use warnings;

use Exporter qw(import);
use Utils::Constants;

sub new {
    my $class = shift;
     
    return bless {}, $class; 
}

sub execute {
    my $self = shift;
    my $client = shift;
    my $endpoint = shift;
    my $message_to_send = WebRender::JsonRender::generate_result(
        Utils::Constants::RESULT_CODE_SUCCESS, $endpoint);
    
    $client->send($message_to_send);
}

1;
