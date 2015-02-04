package Command::PingCommand;

use strict;
use warnings;

use Exporter qw(import);

use Utils::Constants;
use WebRender::JsonRender;

sub new {
    my $class = shift;
     
    return bless {}, $class; 
}

sub execute {
    my $self = shift;
    my $client = shift;
    my $message_to_send = WebRender::JsonRender::generate_result(
        Utils::Constants::RESULT_CODE_SUCCESS, Utils::Constants::PING_COMMAND_RESPOND);

    $client->send($message_to_send);
}

1;
