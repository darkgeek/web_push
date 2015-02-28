package Command::NotificationCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use WebRender::JsonRender qw(convert_to_json);
use Service::MessageService;
use Utils::WebUtils qw(set_object_field get_logger);
use Message::Message;
use DateTime;
use DateTime::Duration;

my $message_service = Service::MessageService->new();

sub chanid {
    return set_object_field(shift, 'chanid', shift);
}

sub version {
    return set_object_field(shift, 'version', shift);
}

sub execute {
    my $this = shift; 

    my $ws = $this->{ws_client};
    my $message_queue = $this->{message_queue};
    my $respond = {};
    my $update = {};
    my $updates = [];
    my $message = Message::Message->new;
    my $time = DateTime->now;
    my $time_duration = DateTime::Duration->new(minutes => 5);

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    $update->{channelID} = $this->chanid;
    $update->{version} = $this->version;

    push @$updates, $update;
    $respond->{messageType} = 'notification';
    $respond->{updates} = $updates;
    
    # Send new notification to client ASAP
    $ws->send(convert_to_json($respond));
    get_logger()->info("Send message [chanid => ".$this->chanid.", version => ".$this->version."]");

    # Add this unacked message to the message_queue
    $message->chanid($this->chanid);
    $message->version($this->version);
    $message->is_acked(0);
    $message->next_send_time($time->add_duration($time_duration));

    $message_queue->add($message);
}

1;
