package Command::HelloCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use Security::UniformIDGenerator qw(generate_uaid);
use WebRender::JsonRender qw(convert_to_json);

sub execute {
    my $this = shift;
    my $request_message = $this->{request_message};
    my $ws = $this->{ws_client};
    my $clients = $this->{online_clients};
    my $respond = {};

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    my $uaid = generate_uaid();
    $respond->{messageType} = $request_message->{messageType};
    $respond->{uaid} = $uaid;

    $clients->{$uaid} = $ws;

    $ws->send(convert_to_json($respond));
}

1;
