package Command::UnregisterCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use WebRender::JsonRender qw(convert_to_json);
use Service::MessageService;
use Utils::Constants;

my $message_service = Service::MessageService->new();

sub execute {
    my $this = shift; 

    my $ws = $this->{ws_client};
    my $request_message = $this->{request_message};
    my $request_channid = $request_message->{channelID};
    my $respond = {};
    my $result = $message_service->remove_chanid($request_channid);
    my $status = Utils::Constants::STATUS_CODE_SUCCESS;
    
    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    if (1 eq $result) {
        $status = Utils::Constants::STATUS_CODE_INTERNAL_SERVER_ERROR;
    }
    
    $respond->{messageType} = $request_message->{messageType};
    $respond->{channelID} = $request_channid;
    $respond->{status} = $status;

    $ws->send(convert_to_json($respond));
}

1;
