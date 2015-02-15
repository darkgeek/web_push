package Command::HelloCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use Security::UniformIDGenerator qw(generate_uaid);

sub execute {
    my $this = shift;
    my $request_message = $this->{request_message};
    my $ws = $this->{ws_client};
    my $clients = $this->{online_clients};

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }

    $ws->send(generate_uaid());
    say "get: ".$request_message->{messageType};
}

1;
