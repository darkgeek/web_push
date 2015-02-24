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
            text => WebRender::JsonRender::generate_result(222)
        );
        return;
    }
    
    $client->send();
    $c->render(text => WebRender::JsonRender::generate_result(Utils::Constants::STATUS_CODE_SUCCESS));
};

websocket '/webpush' => sub {
    my $c = shift;
    my $ws = $c->tx;
    my $connection_shared_data = {};

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
      $command->connection_shared_data($connection_shared_data);
      $command->execute();
    });

    # Closed
    $c->on(finish => sub {
      my ($c, $code, $reason) = @_;

      delete $clients->{$connection_shared_data->{uaid}};
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
  <button id="hello-btn">Say hello</button>
  <button id="add-channel-btn" onclick="addChannel()">Add channel</button>
    <script>
      var ws = new WebSocket('<%= url_for('webpush')->to_abs %>');

      // Incoming messages
      ws.onmessage = function(event) {
        document.body.innerHTML += event.data + '<br/>';
      };

      // Outgoing messages
      window.setInterval(function () { ws.send('{"messageType": "hello","uaid":"fd52438f-1c49-41e0-a2e4-98e49833cc9c","channelIDs": ["431b4391-c78f-429a-a134-f890b5adc0bb", "a7695fa0-9623-4890-9c08-cce0231e4b36"]}') }, 4000);

      function addChannel() {
        ws.send('{"messageType": "register", "channelID": "d9b74644-4f97-46aa-b8fa-9393985cd6cd"}');
      }

      //document.getElementById('add-channel-btn').addEventListener("click", addChannel);
    </script>
  </body>
</html>
