package Message::Message;

use strict;
use warnings;
use 5.010;

use Utils::WebUtils qw(set_object_field);
use Utils::Constants;
use Exporter qw(import);

use parent 'Base';

sub uaid {
    return set_object_field(shift, 'uaid', shift);
}

sub version {
    return set_object_field(shift, 'version', shift);
}

sub is_acked {
    return set_object_field(shift, 'is_acked', shift);
}

sub next_send_time {
    return set_object_field(shift, 'next_send_time', shift);
}

sub is_client_gone_away {
    return set_object_field(shift, 'is_client_gone_away', shift);
}

sub add_event_listener {
    my $this = shift;

    my $queue = shift;

    $queue->on(Utils::Constants::MESSAGE_QUEUE_EVENT_ACK => sub {
        my ($message_queue, $ack) = @_;
        
    });
}

1;
