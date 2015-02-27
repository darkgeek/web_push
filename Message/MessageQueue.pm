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
    say "after add, queue has ".@$queue." items.";
}

sub remove {
    my $this = shift;

    my $item = shift @$queue;

    $item->stop_listen_on($this);
    say "after remove, queue has ".@$queue." items.";
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
