package Message::Message;

use strict;
use warnings;
use 5.010;

use Utils::WebUtils qw(set_object_field get_logger);
use Utils::Constants;
use Exporter qw(import);

use parent 'Base';

sub chanid {
    return set_object_field(shift, 'chanid', shift);
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

sub _ack_event_callback {
    return set_object_field(shift, '_ack_event_callback', shift);
}

sub listen_on {
    my $this = shift;

    my $queue = shift;
    my $cb = sub {
        my ($message_queue, $ack) = @_;
        my $chanid = $ack->{chanid};
        my $version = $ack->{version};
        
        get_logger()->info("Get Ack Message: chanid => $chanid, version => $version");
        if ($this->chanid eq $chanid and $this->version le $version) {
            get_logger()->info("My chanid is ".$this->chanid.", version is ".$this->version.", so it's acked.");
            $this->is_acked(1);
        }
    };

    $queue->on(Utils::Constants::MESSAGE_QUEUE_EVENT_ACK => $cb);
    $this->_ack_event_callback($cb);
}

sub stop_listen_on {
    my $this = shift;

    my $queue = shift;
    my $cb = $this->_ack_event_callback;

    $queue->unsubscribe(Utils::Constants::MESSAGE_QUEUE_EVENT_ACK => $cb);
}

1;
