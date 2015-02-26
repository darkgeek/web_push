package Command::RegisterCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use Security::UniformIDGenerator qw(generate_endpoint);
use WebRender::JsonRender qw(convert_to_json);
use Service::MessageService;
use Utils::Constants;

my $message_service = Service::MessageService->new();

sub execute {
    my $this = shift;

    my $request_message = $this->{request_message};
    my $ws = $this->{ws_client};
    my $clients = $this->{online_clients};
    my $connection_shared_data = $this->{connection_shared_data};
    my $respond = {};
    my $request_channid = $request_message->{channelID};
    my $uaid = $connection_shared_data->{uaid};
    my $status = $message_service->add_chanid($request_channid, $uaid);
    my $endpoint = '';
    
    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    if (0 eq $status) {
        $status = Utils::Constants::STATUS_CODE_SUCCESS;
        $endpoint = generate_endpoint($request_channid);
    }
    elsif (1 eq $status) {
        $status = Utils::Constants::STATUS_CODE_INTERNAL_SERVER_ERROR;
    }
    elsif (2 eq $status) {
        $status = Utils::Constants::STATUS_CODE_CONFLICT_CHANNELID_ERROR;
    }
    
    $respond->{messageType} = $request_message->{messageType};
    $respond->{channelID} = $request_channid;
    $respond->{status} = $status;
    $respond->{pushEndpoint} = $endpoint;

    $ws->send(convert_to_json($respond));
}

1;
