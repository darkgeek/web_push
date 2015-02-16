#!/usr/bin/env perl
use 5.010;
use strict;

use Mojolicious::Lite;
use WebRender::JsonRender;
use Command::CommandFactory;
use Utils::WebUtils;

my $log = Mojo::Log->new;
my $clients = {};

# Template with browser-side code
get '/' => 'index';

put '/push/:endpoint' => {endpoint => qr/\w+/} => sub {
    my $c = shift;
    my $endpoint = $c->stash('endpoint');
    my $validation = $c->validation;

    $validation->required('message')->size(1,50);

    my $message = $validation->param('message');
    my $client = $clients->{$endpoint};
    
    unless ($client) {
        $log->info("Endpoint $endpoint doesn't exist anymore. Cease here.");
        $c->render(
            text => WebRender::JsonRender::generate_result(Utils::Constants::RESULT_CODE_INVALID_ENDPOINT_ERROR)
        );
        return;
    }
    
    $client->send();
    $c->render(text => WebRender::JsonRender::generate_result(Utils::Constants::RESULT_CODE_SUCCESS));
};

websocket '/webpush' => sub {
    my $c = shift;
    my $ws = $c->tx;

    # Websocket connection opened
    $log->debug('WebSocket connection opened');

    # Increase inactivity timeout for connection a bit
    $c->inactivity_timeout(300);
    
    # Incoming message
    $c->on(message => sub {
      my ($c, $msg) = @_;
      my $request_message = Utils::WebUtils::json_to_ref($msg);
      my $command = Command::CommandFactory->create($request_message);

      $command->ws_client($ws);
      $command->online_clients($clients);
      $command->execute();
    });

    # Closed
    $c->on(finish => sub {
      my ($c, $code, $reason) = @_;

      delete $clients->{$endpoint};
      $c->app->log->debug("WebSocket closed with status $code");
    });
};

app->start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
  <head><title>Echo</title></head>
  <body>
    <script>
      var ws = new WebSocket('<%= url_for('webpush')->to_abs %>');

      // Incoming messages
      ws.onmessage = function(event) {
        document.body.innerHTML += event.data + '<br/>';
      };

      // Outgoing messages
      window.setInterval(function () { ws.send('{"messageType": "hello"}') }, 4000);
    </script>
  </body>
</html>
