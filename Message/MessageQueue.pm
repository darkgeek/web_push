package Message::MessageQueue;

use Mojo::Log;
use Mojo::Base -base 'Mojo::EventEmitter';
use Utils::Constants

has queue => [];

sub add {
    my $this = shift;

    my $item = shift;
    my $queue = $this->queue;

    $item->add_event_listener($this);

    push @$queue, $item; 
}

sub remove {
    my $this = shift;

    my $queue = $this->queue;

    shift @$queue;
}

sub peek {
    my $this = shift;

    my $queue = $this->queue;
    my $item;

    $item = $queue->[@$queue - 1] if @$queue > 1;

    return $item;
}

sub ack {
    my $this = shift;

    my $uaid = shift;
    my $version = shift;

    $this->emit(Utils::Constants::MESSAGE_QUEUE_EVENT_ACK => {uaid => $uaid, version => $version});
}

1;
