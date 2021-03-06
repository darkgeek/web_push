package Command::HelloCommand;

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
    my $respond = {};

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    my $uaid = $request_message->{uaid};
    my $chanids = $request_message->{channelIDs};
    my @stored_chanids = $message_service->get_chanids_by_uaid($uaid);
    
    if (@stored_chanids) {
        for my $chanid (@$chanids) {
            my $index = 0;

            # Remove duplicated channel id from @stored_chanids
            for my $stored (@stored_chanids) {
                last if $stored eq $chanid;
                $index++;
            }

            if ($index < @stored_chanids) {
                get_logger()->debug("channel to remove: $index, $chanid");
                splice(@stored_chanids, $index, 1);
            }
            else {
                get_logger()->debug("channel to discard since it was not stored: $index, $chanid");
            }
        }
        # Remove the stored channels that are not listed in "channelIDs" field in this Hello Message
        for my $stored_chanid_to_be_removed (@stored_chanids) {
            $message_service->remove_chanid($stored_chanid_to_be_removed);
        }
    }
    else {
        # Grant a new uaid to client because there is no such uaid stored
        $uaid = generate_uaid();
    }

    $connection_shared_data->{uaid} = $uaid;
    $clients->{$uaid} = $ws;

    # Generate response message
    $respond->{messageType} = $request_message->{messageType};
    $respond->{uaid} = $uaid;

    $ws->send(convert_to_json($respond));

    # Get all versions of channels belonging to specified uaid, and send them to clients
    my @chanids = $message_service->get_chanids_by_uaid($uaid);
    
    for my $channel (@chanids) {
        my $version = $message_service->get_channel_version($channel);
        my $command = Command::NotificationCommand->new;

        $command->ws_client($ws);
        $command->chanid($channel);
        $command->version($version);
        $command->message_queue($this->message_queue);
        $command->execute();
    }
}

1;
