package Command::PingCommand;

use strict;
use warnings;
use 5.010;

use Exporter qw(import);

use parent 'Command::BaseCommand';

use WebRender::JsonRender qw(convert_to_json);
use Service::MessageService;

my $message_service = Service::MessageService->new();

sub execute {
    my $this = shift; 

    my $ws = $this->{ws_client};
    my $respond = {};

    unless (defined $ws) {
        say "{ws_client} is needed and shouldn't be empty. Aborted.";
        return;
    }
    
    $ws->send(convert_to_json($respond));
}

1;
