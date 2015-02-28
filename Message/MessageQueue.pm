package Message::MessageQueue;

use Mojo::Log;
use Mojo::Base 'Mojo::EventEmitter';
use Utils::Constants;

my $queue = [];

sub add {
    my $this = shift;

    my $item = shift;

    $item->listen_on($this);

    push @$queue, $item; 
}

sub remove {
    my $this = shift;

    my $item = shift @$queue;

    if (defined $item) {
        $item->stop_listen_on($this);
    }

    return $item;
}

sub peek {
    my $this = shift;

    my $item;

    $item = $queue->[@$queue - 1] if @$queue > 1;

    return $item;
}

sub ack {
    my $this = shift;

    my $chanid = shift;
    my $version = shift;

    $this->emit(Utils::Constants::MESSAGE_QUEUE_EVENT_ACK => {chanid => $chanid, version => $version});
}

1;
