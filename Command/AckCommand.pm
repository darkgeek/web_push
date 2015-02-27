package Command::AckCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use Security::UniformIDGenerator qw(generate_uaid);
use WebRender::JsonRender qw(convert_to_json);
use Service::MessageService;
use Utils::WebUtils qw(get_logger);

my $message_service = Service::MessageService->new();

sub execute {
    my $this = shift;

    my $request_message = $this->{request_message};
    my $ws = $this->{ws_client};
    my $clients = $this->{online_clients};
    my $connection_shared_data = $this->{connection_shared_data};
    my $updates = $request_message->{updates};
    my $message_queue = $this->{message_queue};
    my $respond = {};

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }

    for my $ack_req (@$updates) {
        $message_queue->ack($ack_req->{channelID}, $ack_req->{version});
    }
}

1;
