#!/usr/bin/env perl
use 5.010;
use strict;

use Mojolicious::Lite;
use WebRender::JsonRender qw(convert_to_json);
use Command::CommandFactory;
use Utils::WebUtils qw(get_logger);
use Security::UniformIDGenerator qw(parse_uaid);
use Command::NotificationCommand;
use Service::MessageService;
use Service::TaskService;
use Message::MessageQueue;

my $message_service = Service::MessageService->new;
my $message_queue = Message::MessageQueue->new;
my $task_service = Service::TaskService->new;
my $clients = {};

$task_service->start_message_resend_task($message_queue, $clients);
$task_service->start_new_message_listener_task();

# Template with browser-side code
get '/' => 'index';

put '/push/:endpoint' => {endpoint => qr/\w+/} => sub {
    my $c = shift;
    my $endpoint = $c->stash('endpoint');
    my $validation = $c->validation;

    $validation->required('version');

    my $version = $validation->param('version');
    my $chanid = parse_uaid($endpoint);
    my $uaid = $message_service->get_uaid_by_chanid($chanid);
    my $client = $clients->{$uaid};
    
    unless ($client) {
        get_logger()->info("Endpoint $endpoint doesn't exist anymore. Cease here.");
        $c->tx->res->code(Utils::Constants::STATUS_CODE_INTERNAL_SERVER_ERROR);
        $c->render(text => '');
        return;
    }

    my $command = Command::NotificationCommand->new;
    $command->ws_client($client);
    $command->chanid($chanid);
    $command->version($version);
    $command->message_queue($message_queue);
    $command->execute();

    $c->render(text => '');
};

websocket '/webpush' => sub {
    my $c = shift;
    my $ws = $c->tx;
    my $connection_shared_data = {};

    # Websocket connection opened
    get_logger()->debug('WebSocket connection opened');

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
      $command->message_queue($message_queue);
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
  <button id="hello-btn" onclick="hello()">Say hello</button>
  <button id="add-channel-btn" onclick="addChannel()">Add channel</button>
  <button id="remove-channel-btn" onclick="unregister()">Remove channel</button>
  <button id="ack-btn" onclick="ack()">Ack</button><input />
    <script>
      var ws = new WebSocket('<%= url_for('webpush')->to_abs %>');

      // Incoming messages
      ws.onmessage = function(event) {
        console.log("Get: " + event.data);
      };

      // Outgoing messages
      window.setInterval(function () { ws.send('{}') }, 4000);

      function addChannel() {
       ws.send('{"messageType": "register", "channelID": "d9b74644-4f97-46aa-b8fa-9393985cd6cd"}');
      }

      function hello() {
       ws.send('{"messageType": "hello","uaid":"fd52438f-1c49-41e0-a2e4-98e49833cc9c","channelIDs": ["d9b74644-4f97-46aa-b8fa-9393985cd6cd", "a7695fa0-9623-4890-9c08-cce0231e4b36", "fd52438f-1c49-41e0-a2e4-98e49833cc9c"]}') 
      }

      function unregister() {
       ws.send('{"messageType": "unregister","channelID": "431b4391-c78f-429a-a134-f890b5adc0bb"}') 
      }

      function ack() {
       ws.send('{"messageType": "ack","updates": [{ "channelID": "d9b74644-4f97-46aa-b8fa-9393985cd6cd", "version": 23 }]}') 
      }
    </script>
  </body>
</html>
